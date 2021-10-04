@interface ABRemotelyManagedFeatures : NSObject

+ (void)updateManagedFeaturesForAppLaunchOnComplete:(JMAction)onComplete;

+ (BOOL)isMoPubEnabled;
+ (BOOL)isAllowedToUseDeviceAdvertisingIdentifier;
+ (NSArray *)mopubSubredditWhitelist;
+ (BOOL)allowsMoPubForPRO;
+ (NSString *)mopubIdentifier;

@end
