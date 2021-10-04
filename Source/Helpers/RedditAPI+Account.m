#import "RedditAPI+Account.h"
#import "RedditAPI+DeprecationPatches.h"
#import "RedditAPI+Posts.h"
#import "SFHFKeychainUtils.h"

@interface RedditAPI (Account_)
@property BOOL authenticated;
@property (strong) NSString *authenticatedUser;
@property (strong) NSString *userIdent;

@property (ab_weak) id userInfoCallBackTarget;
@property (ab_weak) id loginResultCallBackTarget;
@property (ab_weak) id runAfterLoginTarget;
@property SEL runAfterLoginMethod;
@property (ab_weak) id runAfterUserCheckTarget;
@property SEL runAfterUserCheckMethod;
@end

@implementation RedditAPI (Account)

SYNTHESIZE_ASSOCIATED_BOOL(isMod, IsMod);
SYNTHESIZE_ASSOCIATED_BOOL(hasMail, HasMail);
SYNTHESIZE_ASSOCIATED_BOOL(hasModMail, HasModMail);
SYNTHESIZE_ASSOCIATED_BOOL(isOver18, IsOver18);
SYNTHESIZE_ASSOCIATED_BOOL(isGold, IsGold);
SYNTHESIZE_ASSOCIATED_BOOL(currentlyAuthenticating, CurrentlyAuthenticating);
SYNTHESIZE_ASSOCIATED_BOOL(authenticated, Authenticated);
SYNTHESIZE_ASSOCIATED_INTEGER(base10Id, Base10Id);
SYNTHESIZE_ASSOCIATED_STRONG(NSString, authenticatedUser, AuthenticatedUser);
SYNTHESIZE_ASSOCIATED_STRONG(NSString, userIdent, UserIdent);
SYNTHESIZE_ASSOCIATED_SIGNED_INTEGER(karmaLink, KarmaLink);
SYNTHESIZE_ASSOCIATED_SIGNED_INTEGER(karmaComment, KarmaComment);

SYNTHESIZE_ASSOCIATED_WEAK(NSObject, userInfoCallBackTarget, UserInfoCallBackTarget);
SYNTHESIZE_ASSOCIATED_WEAK(NSObject, loginResultCallBackTarget, LoginResultCallBackTarget);
SYNTHESIZE_ASSOCIATED_WEAK(NSObject, runAfterLoginTarget, RunAfterLoginTarget);
SYNTHESIZE_ASSOCIATED_SELECTOR(runAfterLoginMethod, RunAfterLoginMethod);
SYNTHESIZE_ASSOCIATED_WEAK(NSObject, runAfterUserCheckTarget, RunAfterUserCheckTarget);
SYNTHESIZE_ASSOCIATED_SELECTOR(runAfterUserCheckMethod, RunAfterUserCheckMethod);

- (void)prepareDefaultUserState;
{
  self.karmaLink = 0;
  self.karmaComment = 0;
  self.hasMail = NO;
  self.isMod = NO;
  self.isGold = [UDefaults boolForKey:@"is_gold"];
  self.authenticatedUser = [UDefaults objectForKey:@"username"];
  if (!self.authenticatedUser) {
    self.authenticatedUser = @"";
  }
  self.authenticated = NO;
}

- (void)updateUserStateWithDictionary:(NSDictionary *)response;
{
  if (!response || !JMIsKindClassOrNil(response, NSDictionary))
    return;
  
  if (!JMIsNull([response objectForKey:@"has_mail"]))
  {
    [RedditAPI shared].hasMail = [[response valueForKey:@"has_mail"] boolValue];
    self.authenticated = YES;
  }
  
  if (!JMIsNull([response objectForKey:@"is_mod"]))
  {
    [RedditAPI shared].isMod = [[response valueForKey:@"is_mod"] boolValue];
  }
  
  if (!JMIsNull([response objectForKey:@"has_mod_mail"]))
  {
    [RedditAPI shared].hasModMail = [[response valueForKey:@"has_mod_mail"] boolValue];
  }
  
  if (!JMIsNull([response objectForKey:@"comment_karma"]))
  {
    [RedditAPI shared].karmaComment = [[response valueForKey:@"comment_karma"] intValue];
  }
  
  if (!JMIsNull([response objectForKey:@"link_karma"]))
  {
    [RedditAPI shared].karmaLink = [[response valueForKey:@"link_karma"] intValue];
  }

  if (!JMIsNull([response objectForKey:@"is_gold"]))
  {
    [RedditAPI shared].isGold = [[response valueForKey:@"is_gold"] boolValue];
    [UDefaults setBool:[RedditAPI shared].isGold forKey:@"is_gold"];
  }

  if (!JMIsNull([response objectForKey:@"over_18"]))
  {
    [RedditAPI shared].isOver18 = [[response valueForKey:@"over_18"] boolValue];
  }
  
  if (!JMIsNull([response objectForKey:@"id"]))
  {
    NSString *uIdent = [response valueForKey:@"id"];
    SET_IF_EMPTY(uIdent, @"");
    self.userIdent = [NSString stringWithFormat:@"t2_%@", uIdent];
    self.base10Id = [self intFromBase36String:uIdent];
  }
}

#pragma mark - User Details

- (void)apiUserInfoResponse:(id)sender
{
  JMJSONParser *parser = [[JMJSONParser alloc] init];
  NSData *data = (NSData *)sender;
  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSDictionary *response = [[parser objectWithString:responseString error:nil] objectForKey:@"data"];
  
  if (self.userInfoCallBackTarget)
  {
    [self.userInfoCallBackTarget rd_performSelector:@selector(userInfoResponse:) withObject:response];
  }
}

- (void)fetchUserInfo:(NSString *)username withCallback:(id)target
{
  if (!username)
    return;
  
  NSString * userInfoUrl = [[NSString alloc] initWithFormat:@"%@/user/%@/about.json", self.server, username];
  self.userInfoCallBackTarget = target;
  [self doGetURL:userInfoUrl withConnectionCategory:kConnectionCategoryUser callBackTarget:self callBackMethod:@selector(apiUserInfoResponse:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)resetConnectionsForUserDetails;
{
  self.loadingPosts = NO;
  self.userInfoCallBackTarget = nil;
  [self clearConnectionsWithCategory:kConnectionCategoryUser];
}

#pragma mark - private

- (NSUInteger)intFromBase36String:(NSString *)base36 {
  base36 = [base36 lowercaseString];
  NSUInteger result = 0;
  NSUInteger placeMultiplier = 1;
  for (NSUInteger i = 1; i <= base36.length; i++) {
    unichar digit = [base36 characterAtIndex:base36.length - i];
    if (digit >= '0' && digit <= '9') {
      result += (digit - '0') * placeMultiplier;
    } else if (digit >= 'a' && digit <= 'z') {
      result += ((digit - 'a') + 10) * placeMultiplier;
    } else {
      NSAssert(NO, @"Bad character in base36 number: %c", digit);
    }
    placeMultiplier *= 36;
  }
  return result;
}

@end
