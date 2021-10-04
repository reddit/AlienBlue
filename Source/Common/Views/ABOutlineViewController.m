#import "ABOutlineViewController.h"
#import "AlienBlueAppDelegate.h"
#import "ABAnalyticsManager.h"

@interface ABOutlineViewController()
@property BOOL styleChanged;
- (void)respondToStyleChange;
@end

@implementation ABOutlineViewController

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextSizeChangeNotification object:nil];
}

- (id)init;
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToStyleChangeNotification) name:kNightModeSwitchNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToStyleChangeNotification) name:kTextSizeChangeNotification object:nil];        
    }
    return self;
}

- (void)loadView;
{
    [super loadView];
    [self respondToStyleChange];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    if (self.styleChanged)
    {
        [self respondToStyleChange];
    }
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  [self reportScreenAppearanceToAnalytics];
}

- (void)respondToStyleChangeNotification;
{
    self.styleChanged = YES;
}

- (void)respondToStyleChange;
{
    self.tableView.backgroundColor = [UIColor colorForBackground];
    [self reload];
    self.styleChanged = NO;
}

- (ABCustomOutlineNavigationBar *)navigationBar;
{
  return (ABCustomOutlineNavigationBar *)self.attachedCustomNavigationBar;
}

#pragma mark - Analytics

- (NSString *)customScreenNameForAnalytics;
{
  return nil;
}

- (void)reportScreenAppearanceToAnalytics;
{
  NSString *screenName = self.customScreenNameForAnalytics;
  if (JMIsEmpty(screenName))
  {
    screenName = self.title;
  }
  [ABAnalyticsManager trackEntryIntoScreen:screenName];
}

@end
