#import <Foundation/Foundation.h>

@interface ABNotificationManager : NSObject

+ (ABNotificationManager *)manager;

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;

- (void)handleRedditNotificationsOnComplete:(void(^)(BOOL hasNewData))onComplete;
- (BOOL)handleLocalNotification:(UILocalNotification *)localNotification;

- (void)askPermissionForLocalNotificationsIfNecessary;

@end
