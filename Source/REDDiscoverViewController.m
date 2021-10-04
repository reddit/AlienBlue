//  REDDiscoverViewController.m
//  RedditApp

#import "RedditApp/REDDiscoverViewController.h"

#import "Sections/Reddits/RedditsViewController.h"

@interface REDDiscoverViewController ()
@property(nonatomic, strong) ABNavigationController *abNavigationController;
@property(nonatomic, strong) RedditsViewController *redditsViewController;
@end

@implementation REDDiscoverViewController

- (instancetype)init {
  if (self = [super init]) {
    self.redditsViewController = [[RedditsViewController alloc] init];
    self.abNavigationController =
        [[ABNavigationController alloc] initWithRootViewController:self.redditsViewController];
    [self addChildViewController:self.abNavigationController];
  }
  return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBarHidden = YES;
  [self.view addSubview:self.abNavigationController.view];
  [self setTabBarIconWithImageName:@"tab_discover" selectedImageName:@"tab_discover_dn"];
}

@end
