//  REDRedditMainTabBarController.m
//  RedditApp

#import "RedditApp/REDRedditMainTabBarController.h"

#import "RedditApp/REDHomeViewController.h"
#import "RedditApp/REDDiscoverViewController.h"
#import "RedditApp/REDPostViewController.h"
#import "RedditApp/REDInboxViewController.h"
#import "RedditApp/REDUserViewController.h"

@implementation REDRedditMainTabBarController

- (instancetype)init {
  if (self = [super initWithNibName:nil bundle:nil]) {
    self.navigationController.navigationBar.translucent = NO;
    NSArray *viewControllerClasses = @[
      [REDHomeViewController class],
      [REDDiscoverViewController class],
      [REDPostViewController class],
      [REDInboxViewController class],
      [REDUserViewController class]
    ];
    NSMutableArray *navigationControllers =
        [NSMutableArray arrayWithCapacity:viewControllerClasses.count];
    for (Class class in viewControllerClasses) {
      UINavigationController *navigationController =
          [[UINavigationController alloc] initWithRootViewController:[[class alloc] init]];
      [navigationController.topViewController view];
      [navigationControllers addObject:navigationController];
    }
    self.viewControllers = navigationControllers;
    self.tabBar.translucent = NO;
  }
  return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  NSAssert(NO, @"Invalid initializer.");
  self = [self init];
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  NSAssert(NO, @"Invalid initializer.");
  self = [self init];
  return self;
}

@end
