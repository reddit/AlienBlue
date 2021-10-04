#import "ABAnalyticsManager.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import "Resources.h"

#define kABAnalyticsManagerGoogleAnalyticsDispatchIntervalSeconds 20
#define kABAnalyticsManagerGoogleAnalyticsUACode @""

@implementation ABAnalyticsManager

+ (ABAnalyticsManager *)shared;
{
  JM_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

- (id)init;
{
  JM_SUPER_INIT(init);
  [self activateAnalyticsPackage];
  return self;
}

- (void)activateAnalyticsPackage;
{
  [GAI sharedInstance].dispatchInterval = kABAnalyticsManagerGoogleAnalyticsDispatchIntervalSeconds;
  [[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
  [[GAI sharedInstance] trackerWithTrackingId:kABAnalyticsManagerGoogleAnalyticsUACode];
}

- (void)sendAnalyticsEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
{
  if (![UDefaults boolForKey:kABSettingKeyAllowAnalytics] && ![category jm_matches:kABAnalyticsCategoryAdvertorial])
    return;

  NSDictionary *eventDictionary = [[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build];
  [[[GAI sharedInstance] defaultTracker] send:eventDictionary];
}

- (void)sendScreenTrackingEventForScreenName:(NSString *)screenName;
{
  if (![UDefaults boolForKey:kABSettingKeyAllowAnalytics])
    return;
  
  id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
  [defaultTracker set:kGAIScreenName value:screenName];
  
  NSDictionary *eventDictionary = [[GAIDictionaryBuilder createAppView] build];
  [defaultTracker send:eventDictionary];
}

+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action;
{
  [[self class] trackEventWithCategory:category action:action label:nil value:nil];
}

+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label;
{
  [[self class] trackEventWithCategory:category action:action label:label value:nil];
}

+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
{
  [[ABAnalyticsManager shared] sendAnalyticsEventWithCategory:category action:action label:label value:value];
}

+ (void)trackEntryIntoScreen:(NSString *)screenName;
{
  [[ABAnalyticsManager shared] sendScreenTrackingEventForScreenName:screenName];
}

+ (void)pixelTrackResponse:(NSHTTPURLResponse *)response;
{
  if (![UDefaults boolForKey:kABSettingKeyAllowAnalytics])
  {
    return;
  }
  
  NSString *trackingUrl = response.allHeaderFields[@"x-reddit-tracking"];
  if (JMIsNull(trackingUrl))
  {
    return;
  }
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[trackingUrl URL]];
  AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
  }];
  [op start];
}

@end
