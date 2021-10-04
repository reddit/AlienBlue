//  REDPostViewController.m
//  RedditApp

#import "RedditApp/REDPostViewController.h"

#import "Common/Views/ABOutlineViewController.h"

@interface REDPostViewController ()
@property(nonatomic, strong) ABOutlineViewController *createPostViewController;
@property(nonatomic, strong) ABCustomOutlineNavigationBar *navigationBar;
@end

@implementation REDPostViewController

- (instancetype)init {
  if (self = [super init]) {
    self.createPostViewController = [[ABOutlineViewController alloc] init];

    self.navigationBar = [[ABCustomOutlineNavigationBar alloc] initWithFrame:CGRectZero];
    [self.navigationBar setTitleLabelText:NSLocalizedString(@"POST", nil)];
    [self.createPostViewController attachCustomNavigationBarView:self.navigationBar];

    [self addChildViewController:self.createPostViewController];
  }
  return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBarHidden = YES;
  [self.view addSubview:self.createPostViewController.view];
  [self setTabBarIconWithImageName:@"tab_submit" selectedImageName:@"tab_submit_dn"];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
