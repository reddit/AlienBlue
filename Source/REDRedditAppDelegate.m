//  REDRedditAppDelegate.m
//  RedditApp

#import "RedditApp/REDRedditAppDelegate.h"

#import "Common/Views/ABWindow.h"
#import "RedditApp/REDRedditMainTabBarController.h"

@interface REDRedditAppDelegate ()
@property(nonatomic, strong) REDRedditMainTabBarController *mainTabBarController;
@end

@implementation REDRedditAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [super applicationDidFinishLaunching:application];

  self.mainTabBarController = [[REDRedditMainTabBarController alloc] init];
  self.window = [[ABWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self.window setRootViewController:self.mainTabBarController];
  [self.window makeKeyAndVisible];

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
