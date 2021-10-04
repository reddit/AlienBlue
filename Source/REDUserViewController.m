//  REDUserViewController.m
//  RedditApp

#import "RedditApp/REDUserViewController.h"

#import "Common/Navigation/ABNavigationController.h"
#import "Sections/Settings/SettingsViewController.h"

@interface REDUserViewController ()
@property(nonatomic, strong) SettingsViewController *settingsViewController;
@property(nonatomic, strong) ABNavigationController *abNavigationController;
@end

@implementation REDUserViewController

- (instancetype)init {
  if (self = [super init]) {
    self.settingsViewController =
        [[SettingsViewController alloc] initWithSettingsSection:SettingsSectionRedditAccounts];

    self.abNavigationController =
        [[ABNavigationController alloc] initWithRootViewController:self.settingsViewController];

    [self addChildViewController:self.abNavigationController];
  }
  return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBarHidden = YES;
  [self.view addSubview:self.abNavigationController.view];
  [self setTabBarIconWithImageName:@"tab_user" selectedImageName:@"tab_user_dn"];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
