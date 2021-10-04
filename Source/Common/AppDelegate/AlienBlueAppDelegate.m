//
//  AlienBlueAppDelegate.m
//  Alien Blue :: http://alienblue.org
//
//  Created by Jason Morrissey on 28/03/10.
//  Copyright The Design Shed 2010. All rights reserved.
//

#import "AlienBlueAppDelegate.h"

#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>

#import "AlienBlueAppDelegate+UAT.h"
#import "RedditAPI.h"
#import "RedditAPI+Announcements.h"
#import "Resources.h"
#import "SplashView.h"
#import "AFNetworking.h"
#import "DiscoveryAddController.h"
#import "SyncManager+AlienBlue.h"
#import "ABShareConfigurator.h"
#import "JMDiskCache.h"
#import "UIApplication+ABAdditions.h"
#import "Subreddit+Moderation.h"
#import "ABPlaceholderNavigationController.h"
#import "ABNotificationManager.h"
#import "SessionManager+Authentication.h"
#import "ReachabilityCoordinator.h"
#import "AppSchemeCoordinator.h"
#import "SHKConfiguration.h"
#import "MKStoreManager.h"
#import "Announcement.h"
#import "ABRemotelyManagedFeatures.h"

@interface AlienBlueAppDelegate()
@property BOOL isActiveInForeground;
@end

@implementation AlienBlueAppDelegate

- (id)init;
{
  JM_SUPER_INIT(init);

  // iOS calls willResignActive, but will not call didBecomeActive/willEnterForeground on the app
  // delegate when dismissing the Control Center. Only a notification fires when dismissing
  // the Control Center.
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(i_handleBecomingActive) name:UIApplicationDidBecomeActiveNotification object:nil];
  
  return self;
}

- (void)initWindow
{
  self.navigationManager = [UNIVERSAL(NavigationManager) new];
#if ALIEN_BLUE
  [self.window addSubview:self.navigationManager.postsNavigation.view];
  [[self.navigationManager postsNavigation] setToolbarHidden:NO animated:YES];
  [self.window setRootViewController:self.navigationManager.postsNavigation];
#endif
}

- (void)i_handleBecomingActive;
{
  if (self.isActiveInForeground)
  {
    // Protect against repeated invocations, as we are also listening to UIApplicationDidBecomeActiveNotification
    // in addition to direct calls on the app delegate (to workaround Control Center not calling didBecomeActive
    // when dismissing).
    return;
  }
  
  self.isActiveInForeground = YES;
	if (![UDefaults boolForKey:kABSettingKeyShouldPasswordProtect])
	{
    [AppSchemeCoordinator handleApplicationDidBecomeActive];
	}

  [DiscoveryAddController resetDontAskOption];
  [[ABNotificationManager manager] applicationDidBecomeActive];
  [Announcement checkAnnouncements];
  
  [[ReachabilityCoordinator shared] handleApplicationBecomingActiveDoWhenReachable:^{
    [[SessionManager manager] handleAuthenticationForApplicationDidBecomeActive];
    [ABAnalyticsManager trackEventWithCategory:kABAnalyticsCategoryApplication action:@"Became Active"];
    
    if ([ABRemotelyManagedFeatures isMoPubEnabled])
    {
      [[NSNotificationCenter defaultCenter] postNotificationName:@"MPCustomApplicationBecameActiveNotification" object:nil];
    }
  }];
}

- (void)i_handleAfterBackgroundingTimeRemaining:(NSTimeInterval)timeRemaining
{
  [[NavigationManager shared] saveState];
  [[JMDiskCache shared] fastFlushDiskCache];
};

- (void)applicationDidEnterBackground:(UIApplication *)application;
{
  [[ABNotificationManager manager] applicationDidEnterBackground];
  [[SessionManager manager] handleAuthenticationForApplicationDidEnterBackground];
  [[NavigationManager shared] showScreenLockIfNecessary];
  
  JMAction backgroundValidationAction = ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      if (backgroundTask != UIBackgroundTaskInvalid)
      {
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
      }
    });
  };

  backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
    backgroundValidationAction();
  }];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self i_handleAfterBackgroundingTimeRemaining:[application backgroundTimeRemaining]];
    backgroundValidationAction();
  });
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
{
  [[ABNotificationManager manager] handleLocalNotification:notification];
}

- (void)applicationWillResignActive:(UIApplication *)application;
{
  self.isActiveInForeground = NO;
  [[ReachabilityCoordinator shared] handleApplicationBecomingInactive];
  [[ABNotificationManager manager] applicationWillResignActive];
  [[NavigationManager shared] purgeMemory];
  [[RedditAPI shared] clearAnnouncementCheckCallbacks];
  [ABAnalyticsManager trackEventWithCategory:kABAnalyticsCategoryApplication action:@"Entered Background"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [[NavigationManager shared] saveState];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  [self i_handleBecomingActive];
}

- (void)splashViewWillHide;
{
  [UIApplication ab_updateStatusBarTint];
}

- (void)i_postLaunchSetup;
{
  NSTimeInterval startTime = CACurrentMediaTime();
  [self enableAcceptanceTestingIfNecessary];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [ABSettings generateDefaultsIfNecessary];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self initWindow];

      // moves the existing SplashView from the placeholder rootViewController
      // to the newly created rootViewController
#if ALIEN_BLUE
      [SplashView show];
#endif

//      [[SessionManager manager] handleAuthenticationForApplicationLaunching];
      [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

      [[SyncManager manager] addAlienBlueSyncHandlers];
      [[SyncManager manager] start];
      
      [[NavigationManager shared] restoreState];
      [[NavigationManager shared] showEULA];
   
      [self splashViewWillHide];
      [SplashView hide];
      [[NavigationManager shared] showScreenLockIfNecessary];
      
      [self i_handleBecomingActive];
           
      NSTimeInterval endTime = CACurrentMediaTime();
      NSTimeInterval deltaTime = endTime - startTime;
      DLog(@"Post-Launch Setup Duration: %f", deltaTime);
    });
  });
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
  NSTimeInterval startTime = CACurrentMediaTime();
  [[NSURLCache sharedURLCache] setDiskCapacity:1024*1024*50];

  [Fabric with:@[[Crashlytics class]]];

	[MKStoreManager sharedManager];
  if (JMIsIOS7())
  {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:(5. * 60)];
  }
	
  ABPlaceholderNavigationController *placeholderNavController = [ABPlaceholderNavigationController new];
  placeholderNavController.navigationBarHidden = YES;
  [self.window setRootViewController:placeholderNavController];
  [[self window] makeKeyAndVisible];
  [UIApplication ab_enableEdgePanning];
  
  [SplashView show];

  DefaultSHKConfigurator *configurator = [[ABShareConfigurator alloc] init];
  [SHKConfiguration sharedInstanceWithConfigurator:configurator];
  
  [[SessionManager manager] handleAuthenticationForApplicationLaunching];
  [ABRemotelyManagedFeatures updateManagedFeaturesForAppLaunchOnComplete:^{
    [self performSelector:@selector(i_postLaunchSetup) withObject:nil afterDelay:0.];
  }];

  NSTimeInterval endTime = CACurrentMediaTime();
  NSTimeInterval deltaTime = endTime - startTime;
  DLog(@"Launch Duration: %f", deltaTime);
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
{
  [[ABNotificationManager manager] handleRedditNotificationsOnComplete:^(BOOL hasNewData) {
    UIBackgroundFetchResult result = hasNewData ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData;
    completionHandler(result);
  }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
{
  return [AppSchemeCoordinator handleSchemeWithURL:url];
}

#pragma mark -
#pragma mark - Pro Upgrade Hooks (Legacy)

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  // handles alerts fired by MKStoreManager
  if(alertView.tag == kABProUpgradeAlertTagIdent && buttonIndex == 1)
  {
    [[NavigationManager shared] showProUpgradeScreen];
  }
}

- (void)stopPurchaseIndicator
{
  [[NSNotificationCenter defaultCenter] postNotificationName:kProUpgradeNotification object:nil];
}

- (void)proVersionUpgraded
{
  [PromptManager addPrompt:@"PRO Activated"];
  [[NSNotificationCenter defaultCenter] postNotificationName:kProUpgradeNotification object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:kRedditGroupsDidChangeNotification object:nil];
}

@end
