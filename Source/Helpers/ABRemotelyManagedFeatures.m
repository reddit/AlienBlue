#import "ABRemotelyManagedFeatures.h"

#define kABRemotelyManagedFeaturesPersistenceKey @"kABRemotelyManagedFeaturesPersistenceKey"

#define kABRemotelyManagedFeatureKeyMoPubEnabled @"feature_mopub_enabled"
#define kABRemotelyManagedFeatureKeyMoPubSubredditWhitelist @"feature_mopub_subreddit_whitelist"
#define kABRemotelyManagedFeatureKeyMoPubAllowAdvertisingIdentifierUsage @"feature_mopub_use_idfa"
#define kABRemotelyManagedFeatureKeyMoPubAllowForPRO @"feature_mopub_allow_for_pro"
#define kABRemotelyManagedFeatureKeyMoPubProductionIdentifier @"feature_mopub_production_ident"
#define kABRemotelyManagedFeatureKeyMoPubUnreleasedIdentifier @"feature_mopub_unreleased_ident"
#define kABRemotelyManagedFeatureKeyCurrentStoreVersion @"version"

#define kABRemotelyManagedFeaturesTimeoutLeisure 400.

#define kABRemotelyManagedFeaturesVersionComparisonMaxTokensToCompare 10

#define kABRemotelyManagedFeaturesDefaultMoPubIdentifierProductionIPAD @""
#define kABRemotelyManagedFeaturesDefaultMoPubIdentifierUnreleasedIPAD @""
#define kABRemotelyManagedFeaturesDefaultMoPubIdentifierProductionIPHONE @""
#define kABRemotelyManagedFeaturesDefaultMoPubIdentifierUnreleasedIPHONE @""

@implementation ABRemotelyManagedFeatures

+ (NSString *)applicationIdentifier;
{
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  bundleIdentifier = [bundleIdentifier jm_removeOccurrencesOfString:@".enterprise"];
  return bundleIdentifier;
}

+ (NSString *)applicationVersion;
{
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSTimeInterval)recommendedTimeOutToAvoidLaunchDelay;
{
  BOOL alreadyHaveStoredFeatures = !JMIsNull([self availableRemoteFeaturesDictionary]);
  return alreadyHaveStoredFeatures ? 2.5 : 5;
}

+ (void)fetchRemotelyControlledFeatureDisctionaryWithTimeOut:(CGFloat)timeOut onComplete:(void(^)(NSDictionary *remoteFeatures))onComplete onFailure:(void(^)(NSError *error))onFailure;
{
  NSString *url = [NSString stringWithFormat:@"https://www.reddit.com/api/features/ios:%@/%@.json", [self applicationIdentifier], [self applicationVersion]];
  NSURLRequest *request = [NSURLRequest requestWithURL:[url URL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:timeOut];
  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                       {
                                         if (JMIsClass(JSON, NSDictionary) && JSON[@"features"] && JSON[@"upgrade"])
                                         {
                                           NSMutableDictionary *remoteFeatures = [NSMutableDictionary new];
                                           [remoteFeatures addEntriesFromDictionary:JSON[@"features"]];
                                           [remoteFeatures addEntriesFromDictionary:JSON[@"upgrade"]];
                                           onComplete(remoteFeatures);
                                         }
                                         else if (onFailure)
                                         {
                                           onFailure(nil);
                                         }
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                         if (onFailure)
                                         {
                                           onFailure(error);
                                         }
                                       }];
  [operation start];
}

+ (void)updateManagedFeaturesForAppLaunchOnComplete:(JMAction)onComplete;
{
  NSTimeInterval startTime = CACurrentMediaTime();
  [self fetchRemotelyControlledFeatureDisctionaryWithTimeOut:[self recommendedTimeOutToAvoidLaunchDelay] onComplete:^(NSDictionary *remoteFeatures){
    [UDefaults setObject:remoteFeatures forKey:kABRemotelyManagedFeaturesPersistenceKey];
    NSTimeInterval endTime = CACurrentMediaTime();
    NSTimeInterval deltaTime = endTime - startTime;
    DLog(@"Received features : %@ in %f seconds", remoteFeatures, deltaTime);
    onComplete();
  } onFailure:^(NSError *error){
    if (error && error.code == NSURLErrorTimedOut)
    {
      [self leisurelyFetchManagedFeaturesInBackground];
    }
    else
    {
      DLog(@"failed to retrieve remote features due to error: %@", error.localizedDescription);
    }
    onComplete();
  }];
}

+ (void)leisurelyFetchManagedFeaturesInBackground;
{
  [self fetchRemotelyControlledFeatureDisctionaryWithTimeOut:kABRemotelyManagedFeaturesTimeoutLeisure onComplete:^(NSDictionary *remoteFeatures) {
    [UDefaults setObject:remoteFeatures forKey:kABRemotelyManagedFeaturesPersistenceKey];
  } onFailure:^(NSError *error) {
    DLog(@"failed to retrieve managed features (at leisure) : %@", error.localizedDescription);
  }];
}

+ (id)storedFeatureForKey:(NSString *)keyName;
{
  NSDictionary *features = [self availableRemoteFeaturesDictionary];

  if (JMIsNull(features) || JMIsNull([features objectForKey:keyName]))
  {
    return nil;
  }

  return [features objectForKey:keyName];
}

+ (id)featuredObjectWithKey:(NSString *)keyName defaultToValue:(id)defaultValue;
{
  id storedFeature = [self storedFeatureForKey:keyName];
  return storedFeature ?: defaultValue;
}

+ (BOOL)featureBooleanWithKey:(NSString *)keyName defaultToValue:(BOOL)defaultValue;
{
  id storedFeature = [self storedFeatureForKey:keyName];

  if (!storedFeature)
  {
    return defaultValue;
  }
  
  return [storedFeature boolValue];
}

+ (BOOL)isMoPubEnabled;
{
  return [self featureBooleanWithKey:kABRemotelyManagedFeatureKeyMoPubEnabled defaultToValue:YES];
}

+ (BOOL)isAllowedToUseDeviceAdvertisingIdentifier;
{
  return [self featureBooleanWithKey:kABRemotelyManagedFeatureKeyMoPubAllowAdvertisingIdentifierUsage defaultToValue:YES];
}

+ (BOOL)allowsMoPubForPRO;
{
  return [self featureBooleanWithKey:kABRemotelyManagedFeatureKeyMoPubAllowForPRO defaultToValue:NO];
}

+ (NSString *)productionMoPubIdentifier;
{
  NSString *defaultProductionMoPubIdentifier = JMIsIpad() ? kABRemotelyManagedFeaturesDefaultMoPubIdentifierProductionIPAD : kABRemotelyManagedFeaturesDefaultMoPubIdentifierProductionIPHONE;
  return [self featuredObjectWithKey:kABRemotelyManagedFeatureKeyMoPubProductionIdentifier defaultToValue:defaultProductionMoPubIdentifier];
}

+ (NSString *)unreleasedMoPubIdentifier;
{
  NSString *defaultUnreleasedMoPubIdentifier = JMIsIpad() ? kABRemotelyManagedFeaturesDefaultMoPubIdentifierUnreleasedIPAD : kABRemotelyManagedFeaturesDefaultMoPubIdentifierUnreleasedIPHONE;
  return [self featuredObjectWithKey:kABRemotelyManagedFeatureKeyMoPubUnreleasedIdentifier defaultToValue:defaultUnreleasedMoPubIdentifier];
}

+ (NSArray *)mopubSubredditWhitelist;
{
  NSString *whiteListCommaSeparated = [self featuredObjectWithKey:kABRemotelyManagedFeatureKeyMoPubSubredditWhitelist defaultToValue:@"front page, all subreddits"];
  NSArray *whiteListedSubreddits = [[whiteListCommaSeparated componentsSeparatedByString:@","] map:^id(NSString *subreddit) {
    return [subreddit jm_trimmed];
  }];
  return whiteListedSubreddits;
}

+ (NSString *)mopubIdentifier;
{
  return [self isReleasedToMarket] ? [self productionMoPubIdentifier] : [self unreleasedMoPubIdentifier];
}

+ (NSDictionary *)availableRemoteFeaturesDictionary;
{
  return [UDefaults objectForKey:kABRemotelyManagedFeaturesPersistenceKey];
}

NSArray *JMGeneratePaddedVersionNumbersFromString(NSString *versionString)
{
  NSArray *versionStringTokens = [versionString componentsSeparatedByString:@"."];

  NSArray *versionNumbers = [versionStringTokens bk_map:^id(NSString *token) {
    NSString *sanitizedVersionString = [token stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
    return @([sanitizedVersionString integerValue]);
  }];
  
  NSMutableArray *paddedVersionNumbers = [NSMutableArray arrayWithArray:versionNumbers];
  while (paddedVersionNumbers.count < kABRemotelyManagedFeaturesVersionComparisonMaxTokensToCompare)
  {
    [paddedVersionNumbers addObject:@(0)];
  }
  
  return paddedVersionNumbers;
}

NSComparisonResult JMCompareVersions(NSString *version1, NSString *version2)
{
  NSArray *v1Tokens = JMGeneratePaddedVersionNumbersFromString(version1);
  NSArray *v2Tokens = JMGeneratePaddedVersionNumbersFromString(version2);
  
  for (NSUInteger tokenIndex = 0; tokenIndex < kABRemotelyManagedFeaturesVersionComparisonMaxTokensToCompare; tokenIndex++)
  {
    NSUInteger v1TokenVersion = [v1Tokens[tokenIndex] integerValue];
    NSUInteger v2TokenVersion = [v2Tokens[tokenIndex] integerValue];
    
    if (v1TokenVersion < v2TokenVersion)
    {
      return NSOrderedAscending;
    }
    else if (v1TokenVersion > v2TokenVersion)
    {
      return NSOrderedDescending;
    }
  }
  return NSOrderedSame;
}

+ (BOOL)isReleasedToMarket;
{
  NSString *currentMarketVersion = [self featuredObjectWithKey:kABRemotelyManagedFeatureKeyCurrentStoreVersion defaultToValue:@""];
  if (JMIsEmpty(currentMarketVersion))
  {
    // in the absence of the availability of this remote feature, we'll assume that
    // we are running the market version to avoid accidentally presenting pre-release
    // data to users
    return YES;
  }
  
  NSString *applicationVersion = [self applicationVersion];
  NSComparisonResult versionComparison = JMCompareVersions(applicationVersion, currentMarketVersion);
  return versionComparison != NSOrderedDescending;
}

@end
