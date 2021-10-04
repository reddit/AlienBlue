#import "SubredditSidebarViewController.h"
#import "RedditAPI.h"
#import "RedditAPI+Subreddits.h"
#import "MBProgressHUD.h"
#import "NavigationManager.h"
#import "JMArticleContentOptimizer.h"
#import "GTMNSString+HTML.h"
#import "ABOptimalBrowserConfiguration.h"
#import "Post.h"
#import "AlienBlueAppDelegate.h"
#import "BrowserViewController.h"

@interface SubredditSidebarViewController() <UIWebViewDelegate>
@property (copy) NSString *subredditName;
@property (strong) UIActivityIndicatorView *activityIndicator;
@property BOOL sidebarViewIsDismissing;
@end

@implementation SubredditSidebarViewController

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextSizeChangeNotification object:nil];
}

- (void)hookToStyleChangeNotifications;
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyThemeSettings) name:kNightModeSwitchNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyThemeSettings) name:kTextSizeChangeNotification object:nil];
}

- (id)initWithSubredditNamed:(NSString *)subredditName;
{
  self = [super initWithUrl:nil];
  if (self)
  {
    self.subredditName = subredditName;
    self.hidesBottomBarWhenPushed = YES;
    [self hookToStyleChangeNotifications];
  }
  return self;
}

- (void)loadView;
{
  [super loadView];
  [JMOptimalBrowserConfiguration setConfiguration:[ABOptimalBrowserConfiguration new]];
  self.view.backgroundColor = [UIColor colorForBackground];
  
  UIActivityIndicatorViewStyle indicatorStyle = JMIsNight() ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];
  [self.view addSubview:self.activityIndicator];
  [self.activityIndicator centerInSuperView];
  self.activityIndicator.autoresizingMask = JMFlexibleMarginMask;
}

-(void)viewDidLoad;
{
  [super viewDidLoad];
  [self setNavbarTitle:[self.subredditName stringByAppendingString:@" Sidebar"]];
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  [self loadSidebarInformation];
}

- (void)loadSidebarInformation;
{
  [self.activityIndicator startAnimating];
  [[RedditAPI shared] subredditInfoForSubredditName:self.subredditName callBackTarget:self];
}

-(void)close;
{
  [[NavigationManager mainViewController] dismissModalViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated;
{
  [MBProgressHUD hideHUDForView:self.view animated:YES];
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated;
{
  if (!self.isViewLoaded)
  {
    self.sidebarViewIsDismissing = YES;
  }
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
  return [[NavigationManager shared] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

+ (UINavigationController *)viewControllerWithNavigatonForSubredditName:(NSString *)subredditName;
{
  SubredditSidebarViewController * viewController = [[UNIVERSAL(SubredditSidebarViewController) alloc] initWithSubredditNamed:subredditName];
  ABNavigationController *navController = [[ABNavigationController alloc] initWithRootViewController:viewController];
  navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  navController.modalPresentationStyle = UIModalPresentationFormSheet;
  return navController;
}

- (void)didFinishRetrievingDescriptionHTML:(NSString *)descriptionHTML;
{
  if (self.sidebarViewIsDismissing)
    return;
  
  [self.activityIndicator stopAnimating];
  NSString *content;
  
  if (JMIsEmpty(descriptionHTML))
  {
    content = @"<p>This subreddit has an empty sidebar.</p>";
  }
  else
  {
    content = [descriptionHTML gtm_stringByUnescapingFromHTML];
  }
  [self updateWithStaticHTML:content];
}

- (void)applyThemeSettings;
{
  self.view.backgroundColor = [UIColor colorForBackground];
  [self loadSidebarInformation];
}

#pragma mark -

- (void)apiSubredditsResponse:(id)sender;
{
  NSMutableDictionary *data = (NSMutableDictionary *) sender;
  if (data)
  {
    NSMutableDictionary * subredditData = [data objectForKey:@"data"];
    if (subredditData)
    {
      NSString *descriptionHTML = [subredditData objectForKey:@"description_html"];
      if (descriptionHTML)
      {
        [self didFinishRetrievingDescriptionHTML:descriptionHTML];
      }
    }
  }
}

@end
