//  REDHomeViewController.m
//  RedditApp

#import "RedditApp/REDHomeViewController.h"

#import "RedditApp/Listing/REDListingViewController.h"
#import "RedditApp/REDNavigationBar.h"

@interface REDHomeViewController ()
@property(nonatomic, strong) REDListingViewController *listingViewController;
@end

@implementation REDHomeViewController

- (instancetype)init {
  if (self = [super init]) {
    self.listingViewController =
        [[REDListingViewController alloc] initWithSubreddit:@"" title:@"Front Page"];
    [self.listingViewController hideTitle];

    REDNavigationBar *navigationBar = [[REDNavigationBar alloc] initWithFrame:CGRectZero];
    navigationBar.titleView =
        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_reddit"]];
    [self.listingViewController attachCustomNavigationBarView:navigationBar];

    [self addChildViewController:self.listingViewController];
  }
  return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBarHidden = YES;
  [self.view addSubview:self.listingViewController.view];
  [self setTabBarIconWithImageName:@"tab_home" selectedImageName:@"tab_home_dn"];
}

@end
