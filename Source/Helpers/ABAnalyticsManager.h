#define kABAnalyticsCategoryApplication @"Application"
#define kABAnalyticsCategoryAdvertorial @"Advertorial"

@interface ABAnalyticsManager : NSObject

+ (void)trackEntryIntoScreen:(NSString *)screenName;
+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action;
+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label;
+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
+ (void)pixelTrackResponse:(NSHTTPURLResponse *)response;

@end
