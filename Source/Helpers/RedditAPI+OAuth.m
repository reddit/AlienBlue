#import "RedditAPI+OAuth.h"
#import "RedditAPI+Account.h"

#import "SFHFKeychainUtils.h"
#import <Lockbox/Lockbox.h>
#import "ReachabilityCoordinator.h"

#define kRedditAPIOAuthKeychainPrefix @"reddit_oauth"
#define kRedditAPIOAuthKeyLastModifiedDateSuffix @"_last_modified"
#define kRedditAPIOAuthKeyExpiresInInterval @"expires_in"
#define kRedditAPIOAuthExpiryMarginToTriggerRefreshMinutes 15

#define kRedditAPIOAuthClientID @""
#define kRedditAPIServerForAuthenticatedRequests @"https://oauth.reddit.com"
#define kRedditAPIServerForUnauthenticatedRequests @"https://www.reddit.com"
#define kRedditAPIServerForTokenRequests @"https://www.reddit.com"

@interface RedditAPI (OAuth_)
@property BOOL authenticated;
@property (strong) NSString *authenticatedUser;
@property (strong) NSTimer *tokenRefreshTimer;
@property (readonly) NSString *activeUsername;
@property NSDate *lastSuccessfulAuthenticatedUserDetailsRetrievalTimestamp;
@property NSDate *mostRecentAuthenticationAttemptTimestamp;
@end

@implementation RedditAPI (OAuth)

SYNTHESIZE_ASSOCIATED_STRONG(NSTimer, tokenRefreshTimer, TokenRefreshTimer);
SYNTHESIZE_ASSOCIATED_STRONG(NSDate, lastSuccessfulAuthenticatedUserDetailsRetrievalTimestamp, LastSuccessfulAuthenticatedUserDetailsRetrievalTimestamp);
SYNTHESIZE_ASSOCIATED_STRONG(NSDate, mostRecentAuthenticationAttemptTimestamp, MostRecentAuthenticationAttemptTimestamp);

- (void)setActiveUsername:(NSString *)username
{
  [UDefaults setObject:username forKey:@"username"];
}

- (NSString *)activeUsername;
{
  return [UDefaults objectForKey:@"username"];
}

- (NSString *)recommendedServerForActiveUser;
{
  BOOL useOAuthServer = !JMIsEmpty(RedditOAuthAccessTokenForUsername(self.activeUsername));
  return useOAuthServer ? kRedditAPIServerForAuthenticatedRequests : kRedditAPIServerForUnauthenticatedRequests;
}

- (BOOL)hasAuthenticatableUser;
{
  return !JMIsEmpty(self.activeUsername) && !JMIsEmpty(RedditOAuthAccessTokenForUsername(self.activeUsername));
}

#pragma mark -
#pragma mark - Authentication

- (void)authenticateAndPersistTokensWithUsername:(NSString *)username password:(NSString *)password onComplete:(JMAction)onComplete onFailure:(JMOnErrorAction)onError
{
  NSDictionary *params = @{
                           @"grant_type" : @"password",
                           @"duration" : @"permanent",
                           @"username" : [username jm_escaped],
                           @"password" : [password jm_escaped],
                           @"device_id" : [NSUUID UUID].UUIDString,
                           };
  
  BSELF(RedditAPI);
  void(^onSuccessfulAuthenticationAction)(NSDictionary *) = ^(NSDictionary *oauthResponse){
    StoreRedditOAuthSettingsForUsername(username, oauthResponse);
    RedditAPIDeleteLegacyKeychainPasswordForUsername(username);
    [blockSelf setActiveUsername:username];
    blockSelf.authenticatedUser = username;
    blockSelf.authenticated = YES;
    [blockSelf retrieveAndUpdateAuthenticatedUserDetailsOnComplete:^{
      [blockSelf scheduleNextTokenRefreshForAuthenticatedUser];
      onComplete();
    } onError:^(NSString *errorReason) {
      onError(errorReason);
    }];
  };
  
  void(^onAuthenticationFailureAction)(NSString *) = ^(NSString *errorReason){
    NSString *friendlyErrorMessage = [NSString stringWithFormat:@"Unable to authenticate your account (%@), please verify your username and password in Settings -> Accounts", errorReason];
    if (onError)
    {
      onError(friendlyErrorMessage);
    }
  };
  
  NSString *tokenRequestUrl = [NSString stringWithFormat:@"%@/api/fp/1/auth/access_token", kRedditAPIServerForTokenRequests];
  [self performBasicAuthorizedPostRequestWithUrl:tokenRequestUrl parameters:params httpBodyData:nil onComplete:^(NSDictionary *JSON) {
    if (!RedditOAuthJSONResponseHasValidTokenExpiry(JSON))
    {
      onError(@"Invalid token credentials received (no expiry)");
      return;
    }
    onSuccessfulAuthenticationAction(JSON);
  } onError:onAuthenticationFailureAction];
}

- (void)retrieveAndUpdateAuthenticatedUserDetailsOnComplete:(JMAction)onComplete onError:(JMOnErrorAction)onError;
{
  // small optimisation to avoid hitting the server twice (once for token check, and another to retrieve inbox/user details)
  // if we've just received that data successfully a moment ago
  NSTimeInterval timeSinceLastRetrieval = -1 * [self.lastSuccessfulAuthenticatedUserDetailsRetrievalTimestamp timeIntervalSinceNow];
  BOOL shouldUseCachedResponse = self.lastSuccessfulAuthenticatedUserDetailsRetrievalTimestamp != nil && timeSinceLastRetrieval < 0.005;
  if (shouldUseCachedResponse)
  {
    onComplete();
    return;
  }
  
  NSString *urlWithParameters = [NSString stringWithFormat:@"%@/api/v1/me", kRedditAPIServerForAuthenticatedRequests];
  NSMutableURLRequest *request = [NSMutableURLRequest new];
  request.URL = [urlWithParameters URL];
  request.HTTPMethod = @"GET";

  [request setAllHTTPHeaderFields:[self generateOAuthAuthenticationHeadersForRedditRequest]];
  
  BSELF(RedditAPI);
  AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    [blockSelf updateUserStateWithDictionary:JSON];
    blockSelf.lastSuccessfulAuthenticatedUserDetailsRetrievalTimestamp = [NSDate new];
    onComplete();
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    NSString *friendlyErrorMessage = [NSString stringWithFormat:@"Unable to retrieve your account details (%@) [%ld]", error.localizedDescription, response.statusCode];
    onError(friendlyErrorMessage);
  }];
  
  [op start];
}

- (void)establishAuthenticationForCurrentUserOnComplete:(JMAction)onComplete onFailure:(void(^)(NSString *errorMessage, BOOL isSupercededByNewerAttempt))onFailure;
{
  NSString *activeUsernameToAuthenticate = self.activeUsername;
  NSDate *attemptTimestamp = [NSDate new];
  self.mostRecentAuthenticationAttemptTimestamp = attemptTimestamp;
  
  BOOL skipAuthentication = JMIsEmpty(activeUsernameToAuthenticate);
  if (skipAuthentication)
  {
    onComplete();
    return;
  }
  
  BSELF(RedditAPI);
  JMOnErrorAction onErrorAction = ^(NSString *errorReason){
    NSString *friendlyErrorMessage = [@"Authentication Failed : " stringByAppendingString:errorReason];
    BOOL isSupercededByNewerAttempt = blockSelf.mostRecentAuthenticationAttemptTimestamp != attemptTimestamp;
    onFailure(friendlyErrorMessage, isSupercededByNewerAttempt);
  };
  
  NSTimeInterval startTime = CACurrentMediaTime();
  
  JMAction establishAuthenticatedConnectionAction = ^{
    blockSelf.authenticated = NO;
    [blockSelf refreshTokenIfNecessaryOnComplete:^{
      [blockSelf retrieveAndUpdateAuthenticatedUserDetailsOnComplete:^{
        blockSelf.authenticatedUser = activeUsernameToAuthenticate;
        blockSelf.authenticated = YES;
        [blockSelf scheduleNextTokenRefreshForAuthenticatedUser];
        NSTimeInterval endTime = CACurrentMediaTime();
        NSTimeInterval deltaTime = endTime - startTime;
        DLog(@"Time taken to authenticate & validate authentication : %f seconds", deltaTime);
        onComplete();
      } onError:onErrorAction];
    } onError:onErrorAction];
  };
  
  BOOL needsLegacyAccountMigration = RedditAPIHasLegacyKeychainPasswordForUsername(activeUsernameToAuthenticate) && JMIsEmpty(RedditOAuthAccessTokenForUsername(activeUsernameToAuthenticate));
  
  if (needsLegacyAccountMigration)
  {
    [self migrateLegacyKeychainAccountToOAuthForUsername:activeUsernameToAuthenticate onComplete:establishAuthenticatedConnectionAction onFailure:onErrorAction];
    return;
  }
  
  establishAuthenticatedConnectionAction();
}

#pragma mark -
#pragma mark - Managing Token Refresh / Expiry

- (void)refreshTokenIfNecessaryOnComplete:(JMAction)onComplete onError:(JMOnErrorAction)onError
{
  [self checkIfAccessTokenIsStillValid:^(BOOL isValid) {
    if (isValid)
    {
      onComplete();
    }
    else
    {
      [self performTokenRefreshForAuthenticatedUserOnComplete:onComplete onError:onError];
    }
  }];
}

- (void)checkIfAccessTokenIsStillValid:(void(^)(BOOL isValid))onComplete;
{
  NSTimeInterval secondsLeftUntilTokenExpires = RedditOAuthSecondsUntilTokenExpiresForUser(self.activeUsername);
  if (secondsLeftUntilTokenExpires <= 0)
  {
    onComplete(NO);
    return;
  }
  
  // if within expiry date, also double check by attempting a request
  // just in case the user has reset their clock or timezone shift has
  // taken place and we are incorrectly assuming the token is still
  // within date
  [self retrieveAndUpdateAuthenticatedUserDetailsOnComplete:^{
    onComplete(YES);
  } onError:^(NSString *errorMessage) {
    onComplete(NO);
  }];
}

- (void)cancelTokenRefreshTimers;
{
  [self.tokenRefreshTimer invalidate];
  self.tokenRefreshTimer = nil;
}

- (void)scheduleNextTokenRefreshForAuthenticatedUser;
{
  [self.tokenRefreshTimer invalidate];
  
  if (!RedditOAuthHasValidTokenExpiryIntervalForUser(self.authenticatedUser))
  {
    // protect from recursively hammering the server if we receive bad token expiry data
    return;
  }
  
  NSTimeInterval timeTilTokenExpiry = RedditOAuthSecondsUntilTokenExpiresForUser(self.authenticatedUser);
  NSTimeInterval timeTilTokenRefresh = MAX(0., timeTilTokenExpiry - (kRedditAPIOAuthExpiryMarginToTriggerRefreshMinutes * 60.));
  
  BSELF(RedditAPI);
  self.tokenRefreshTimer = [NSTimer bk_scheduledTimerWithTimeInterval:timeTilTokenRefresh block:^(NSTimer *timer) {
    [blockSelf performTokenRefreshForAuthenticatedUserOnComplete:^{
      [blockSelf scheduleNextTokenRefreshForAuthenticatedUser];
    } onError:^(NSString *errorMessage) {
      DLog(@"Failed to refresh token invoked from timer : %@", errorMessage);
    }];
  } repeats:NO];
}

- (void)performTokenRefreshForAuthenticatedUserOnComplete:(JMAction)onComplete onError:(JMOnErrorAction)onError
{
  NSString *activeUsernameToAuthenticate = self.activeUsername;
  
  NSDictionary *persistedTokenSettingsForUser = RedditOAuthSettingsForUser(activeUsernameToAuthenticate);
  if (!persistedTokenSettingsForUser || ![persistedTokenSettingsForUser valueForKey:@"refresh_token"])
  {
    onComplete();
    return;
  }
  
  NSString *refreshToken = [persistedTokenSettingsForUser valueForKey:@"refresh_token"];
  NSDictionary *params = @{
                           @"grant_type" : @"refresh_token",
                           @"duration" : @"permanent",
                           @"refresh_token" : refreshToken,
                           };
  
  NSString *tokenRequestUrl = [NSString stringWithFormat:@"%@/api/v1/access_token", kRedditAPIServerForTokenRequests];
  
  [self performBasicAuthorizedPostRequestWithUrl:tokenRequestUrl parameters:params httpBodyData:nil onComplete:^(NSDictionary *JSON) {
    if (!RedditOAuthJSONResponseHasValidTokenExpiry(JSON))
    {
      onError(@"Invalid token credentials received (no expiry)");
      return;
    }
    
    NSMutableDictionary *updatedTokenSettings = [NSMutableDictionary dictionaryWithDictionary:persistedTokenSettingsForUser];
    [updatedTokenSettings addEntriesFromDictionary:JSON];
    StoreRedditOAuthSettingsForUsername(activeUsernameToAuthenticate, updatedTokenSettings);
    onComplete();
  } onError:^(NSString *errorReason) {
    onError([@"Failed to refresh authentication token : " stringByAppendingString:errorReason]);
  }];
}

#pragma mark -
#pragma mark - Logging Out / Token Revocation

- (void)deauthenticateUsername:(NSString *)username;
{
  [self performTokenRevokeForUsername:username onComplete:^{
    RedditOAuthDeleteSettingsFromKeychainForUser(username);
  }];
  
  if (!JMIsEmpty(self.activeUsername) && [username jm_matches:self.activeUsername])
  {
    self.authenticatedUser = @"";
    self.authenticated = NO;
    [self setActiveUsername:@""];
  }
}

- (void)performTokenRevokeForUsername:(NSString *)username onComplete:(JMAction)onComplete
{
  if (JMIsEmpty(username) || JMIsEmpty(RedditOAuthAccessTokenForUsername(username)))
  {
    onComplete();
    return;
  }
  
  NSString *bodyString = [NSString stringWithFormat:@"token=%@&token_type_hint=access_token", RedditOAuthAccessTokenForUsername(username)];
  NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
  
  NSString *tokenRevokeUrl = [NSString stringWithFormat:@"%@/api/v1/revoke_token", kRedditAPIServerForTokenRequests];
  [self performBasicAuthorizedPostRequestWithUrl:tokenRevokeUrl parameters:nil httpBodyData:bodyData onComplete:^(NSDictionary *JSON) {
    onComplete();
  } onError:^(NSString *errorReason) {
    onComplete();
  }];
}

#pragma mark -
#pragma mark - OAuth Token Persistence

static NSString * RedditOAuthKeychainKeyForUsername(NSString *username)
{
  return [NSString stringWithFormat:@"%@_%@", kRedditAPIOAuthKeychainPrefix, username];
}

static NSString * RedditOAuthLastModifiedKeychainKeyForUsername(NSString *username)
{
  return [RedditOAuthKeychainKeyForUsername(username) stringByAppendingString:kRedditAPIOAuthKeyLastModifiedDateSuffix];
}

static NSDictionary * RedditOAuthSettingsForUser(NSString *username)
{
  return [Lockbox dictionaryForKey:RedditOAuthKeychainKeyForUsername(username)];
}

static void RedditOAuthDeleteSettingsFromKeychainForUser(NSString *username)
{
  [Lockbox setDictionary:nil forKey:RedditOAuthKeychainKeyForUsername(username)];
  [Lockbox setDate:nil forKey:RedditOAuthLastModifiedKeychainKeyForUsername(username)];
}

static void StoreRedditOAuthSettingsForUsername(NSString *username, NSDictionary *oauthDictionary)
{
  [Lockbox setDictionary:oauthDictionary forKey:RedditOAuthKeychainKeyForUsername(username)];
  [Lockbox setDate:[NSDate date] forKey:RedditOAuthLastModifiedKeychainKeyForUsername(username)];
}

static BOOL RedditOAuthHasValidTokenExpiryIntervalForUser(NSString *username)
{
  NSDictionary *oauthSettings = RedditOAuthSettingsForUser(username);
  NSTimeInterval expiresInterval = [oauthSettings[kRedditAPIOAuthKeyExpiresInInterval] doubleValue];
  return expiresInterval > 0;
}

static BOOL RedditOAuthHasValidRefreshTokenForUser(NSString *username)
{
  NSDictionary *persistedTokenSettingsForUser = RedditOAuthSettingsForUser(username);
  if (!persistedTokenSettingsForUser)
    return NO;
  
  return !JMIsEmpty([persistedTokenSettingsForUser valueForKey:@"refresh_token"]);
}

static NSTimeInterval RedditOAuthSecondsUntilTokenExpiresForUser(NSString *username)
{
  NSDictionary *oauthSettings = RedditOAuthSettingsForUser(username);
  
  NSDate *lastModifiedTokenDate = [Lockbox dateForKey:RedditOAuthLastModifiedKeychainKeyForUsername(username)];
  
  NSTimeInterval expiresInterval = [oauthSettings[kRedditAPIOAuthKeyExpiresInInterval] doubleValue];
  NSDate *expectedExpiryDate = [lastModifiedTokenDate dateByAddingTimeInterval:expiresInterval];
  
  NSTimeInterval secondsRemaining = [expectedExpiryDate timeIntervalSinceNow];
  return secondsRemaining;
}

static NSString * RedditOAuthAccessTokenForUsername(NSString *username)
{
  NSDictionary *oauthSettings = RedditOAuthSettingsForUser(username);
  return oauthSettings[@"access_token"];
}

#pragma mark -
#pragma mark - Convenience Request Generators

static NSString * RedditBasicAuthorizationHeaderValue()
{
  NSString *baseString = [kRedditAPIOAuthClientID stringByAppendingString:@":"];
  NSData *base64Data = [baseString dataUsingEncoding:NSUTF8StringEncoding];
  NSString *base64String = [base64Data base64EncodedStringWithOptions:0];
  return [NSString stringWithFormat:@"Basic %@", base64String];
}

static NSString * RedditAPIDictionaryToParamsString(NSDictionary *dictionary)
{
  NSMutableString *params = [NSMutableString new];
  [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [params appendFormat:@"%@=%@&", key, obj];
  }];
  return params;
}

static BOOL RedditOAuthJSONResponseHasValidTokenExpiry(NSDictionary *OAuthJSONResponse)
{
  if (!JMIsClass(OAuthJSONResponse, NSDictionary))
    return NO;
  
  BOOL hasValidExpiry = [OAuthJSONResponse objectForKey:@"expires_in"] != nil && [[OAuthJSONResponse objectForKey:@"expires_in"] intValue] > 0;
  return hasValidExpiry;
}

- (NSDictionary *)generateOAuthAuthenticationHeadersForRedditRequest;
{
  if (JMIsEmpty(self.activeUsername))
    return nil;
  
  NSString *accessToken = RedditOAuthAccessTokenForUsername(self.activeUsername);
  if (JMIsEmpty(accessToken))
    return nil;
  
  return @{ @"Authorization" : [NSString stringWithFormat:@"bearer %@", accessToken] };
}

- (void)performBasicAuthorizedPostRequestWithUrl:(NSString *)url parameters:(NSDictionary *)parameters httpBodyData:(NSData *)httpBodyData onComplete:(void(^)(NSDictionary *JSON))onComplete onError:(void(^)(NSString *errorReason))onError
{
  NSString *paramsString = RedditAPIDictionaryToParamsString(parameters);
  NSString *urlWithParameters = [NSString stringWithFormat:@"%@?%@", url, paramsString];
  
  NSMutableURLRequest *request = [NSMutableURLRequest new];
  request.URL = [urlWithParameters URL];
  request.HTTPMethod = @"POST";
  
  [request setHTTPBody:httpBodyData];
  [request setValue:RedditBasicAuthorizationHeaderValue() forHTTPHeaderField:@"Authorization"];
  
  AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    onComplete(JSON);
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    NSString *errorReason;
    if (JSON && [JSON valueForKey:@"error"])
    {
      errorReason = [JSON valueForKey:@"error"];
    }
    else
    {
      errorReason = error.localizedDescription;
    }
    
    if (!JMIsClass(errorReason, NSString))
    {
      errorReason = @"";
    }
    
    NSString *errorWithCode = [errorReason stringByAppendingFormat:@" [%ld]", response.statusCode];
    onError(errorWithCode);
  }];
  [op start];
}

#pragma mark -
#pragma mark - Legacy Keychain Password Helpers

- (void)migrateLegacyKeychainAccountToOAuthForUsername:(NSString *)username onComplete:(JMAction)onComplete onFailure:(JMOnErrorAction)onFailure
{
  NSString *keychainPassword = RedditAPILegacyKeychainPasswordForUsername(username);
  
  [self authenticateAndPersistTokensWithUsername:username password:keychainPassword onComplete:^{
    [UDefaults removeObjectForKey:@"cookie"];
    [UDefaults removeObjectForKey:@"modhash"];
    RedditAPIDeleteLegacyKeychainPasswordForUsername(username);
    onComplete();
  } onFailure:^(NSString *errorMessage) {
    onFailure([@"Failed to migrate legacy account : " stringByAppendingString:errorMessage]);
  }];
}

static NSString * RedditAPILegacyKeychainPasswordForUsername(NSString *username)
{
  return [SFHFKeychainUtils getPasswordForUsername:username andServiceName:@"AlienBlue" error:nil];
}

static void RedditAPIDeleteLegacyKeychainPasswordForUsername(NSString *username)
{
  [SFHFKeychainUtils deleteItemForUsername:username andServiceName:@"AlienBlue" error:nil];
}

static BOOL RedditAPIHasLegacyKeychainPasswordForUsername(NSString *username)
{
  return !JMIsEmpty(RedditAPILegacyKeychainPasswordForUsername(username));
}

- (void)deleteLegacyKeychainItemForUsername:(NSString *)username;
{
  RedditAPIDeleteLegacyKeychainPasswordForUsername(username);
}

@end
