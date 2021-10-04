#import "BrowserViewController_iPad.h"
#import "BrowserHeaderView_iPad.h"
#import "BrowserFooterView_iPad.h"
#import "UIViewController+JMFoldingNavigation.h"
#import "AppDelegate_iPad.h"
#import "NavigationManager_iPad.h"
#import "Resources.h"
#import "JMOptimalContentCoordinator.h"
#import "BrowserViewController_iPad+OptimalImage.h"
#import "ABWindow.h"
#import "UIApplication+ABAdditions.h"

@interface JMOptimalBrowserController(iPad_Private)
- (void)setShowOptimal:(BOOL)optimal animated:(BOOL)animated;
- (void)contentOptimizerDidFail:(JMContentOptimizer *)optimizer;
- (void)contentOptimizer:(JMContentOptimizer *)optimizer didRecommendContentSize:(CGSize)size;
@end

@interface BrowserViewController_iPad() <UIGestureRecognizerDelegate>
@property (strong) BrowserHeaderView_iPad *headerView;
@property (strong) BrowserFooterView_iPad *footerView;
@end

@implementation BrowserViewController_iPad

- (CGFloat)pageWidth;
{
    CGFloat width = JMPortrait() ? 640. : 540.;
    if ([Resources compactPortrait])
    {
        UIViewController *priorController = [self.foldingNavigationController controllerBeforeController:self];
        if ([NSStringFromClass(priorController.class) contains:@"Posts"])
            width = 396.;
        else
            width = 640.;
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:kABSettingKeyIpadUseLegacyPostPaneSize] && JMLandscape())
    {
        width += 70.;
    }

    if (![NavigationManager_iPad foldingNavigation].showingSidePane)
        width += kSidePaneWidth;
    
    return width;
}

- (void)setShowOptimal:(BOOL)optimal animated:(BOOL)animated;
{
  [super setShowOptimal:optimal animated:animated];
  self.contentView.frame = CGRectMake(0., 50., self.view.width, self.view.height - 100.);
  self.footerView.optimalButton.selected = optimal;
  [self configureContentViewForImageIfNecessary];
}

- (void)viewWillLayoutSubviews;
{
  [super viewWillLayoutSubviews];
  self.headerView.expandButtonOverlay.selected = self.fullScreen;    
  self.loadingIndicator.bottom = self.view.height - 14.;
  [self.loadingIndicator centerHorizontallyInSuperView];
  [self.view bringSubviewToFront:self.loadingIndicator];
  
  self.contentView.frame = CGRectMake(0., 50., self.view.width, self.view.height - 100.);
  [self configureContentViewForImageIfNecessary];  
}

- (void)loadView;
{
  [super loadView];
  
  BSELF(BrowserViewController_iPad);

  [self.view addSubview:self.loadingIndicator];

  self.headerView = [[BrowserHeaderView_iPad alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 55.)];
  self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:self.headerView];
  [self.headerView updateWithPost:self.post];
  
  self.headerView.expandButtonOverlay.onTap = ^(CGPoint touchPoint){
      blockSelf.headerView.expandButtonOverlay.selected = !blockSelf.fullScreen;
      [blockSelf toggleFullscreen];
  };
  self.headerView.expandButtonOverlay.selected = blockSelf.fullScreen;
  
  self.footerView = [[BrowserFooterView_iPad alloc] initWithFrame:CGRectMake(0, self.view.height - 50., self.view.width, 55.)];
  self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  [self.view addSubview:self.footerView];

  self.footerView.backButtonOverlay.onTap = ^(CGPoint p) {
      [blockSelf browserBack];
  };
  self.footerView.forwardButtonOverlay.onTap = ^(CGPoint p) {
      [blockSelf browserForward];
  };
  self.footerView.refreshButtonOverlay.onTap = ^(CGPoint p) {
      [blockSelf browserRefresh];
  };    
  
  self.headerView.actionButton.onTap = ^(CGPoint touchPoint) {
      [blockSelf popupExtraOptionsActionSheet:blockSelf.headerView.actionBarButtonItemProxy];
  };
  
  self.footerView.optimalButton.selected = self.isShowingOptimal;
  [self.footerView.optimalButton addEventHandler:^(id sender) {
      // when the user triggers this (as opposed to automatic triggering), we should remember it for later
        [blockSelf userDidSwitchOptimalToggle];
  } forControlEvents:UIControlEventTouchUpInside];
  
  BOOL showsOptimalSettingsButton = self.isShowingOptimal && self.optimizer.hasSettings;
  self.footerView.optimalSettingsButton.hidden = !showsOptimalSettingsButton;
  [self.footerView.optimalSettingsButton addEventHandler:^(id sender) {
    [blockSelf.optimizer showSettings];
  } forControlEvents:UIControlEventTouchUpInside];

  self.footerView.optimalButton.enabled = self.optimizer != nil;
}

- (void)userDidSwitchOptimalToggle;
{
  [self setShowOptimal:!self.isShowingOptimal animated:YES];
  BOOL showsOptimalSettingsButton = self.isShowingOptimal && self.optimizer.hasSettings;
  self.footerView.optimalSettingsButton.hidden = !showsOptimalSettingsButton;
}

- (void)contentOptimizerDidFail:(JMContentOptimizer *)optimizer;
{
  if (optimizer.disablesOptimalSwitchOnFailure)
  {
    self.footerView.optimalButton.enabled = NO;
    self.footerView.optimalSettingsButton.hidden = YES;
  }
  [super contentOptimizerDidFail:optimizer];
}

- (NSMutableDictionary *)postDictionary;
{
  return self.post.legacyDictionary;
}

#pragma mark -
#pragma mark Link Handling

- (void)userDidTapOnLinkToPost:(Post *)p;
{
  [(NavigationManager_iPad *)[NavigationManager_iPad shared] showCommentsForPost:p contextId:p.contextCommentIdent fromController:self];
}

- (void)userDidTapOnSubredditLink:(NSString *)subreddit;
{
  NSString *title = [subreddit convertToSubredditTitle];
  [(NavigationManager_iPad *)[NavigationManager_iPad shared] showPostsForSubreddit:subreddit title:title fromController:self];
}

- (void)userDidTapOnUserLink:(NSString *)username;
{
  [(NavigationManager_iPad *)[NavigationManager_iPad shared] showUserDetails:username];
}

- (void)userDidTapOnExternalLink:(NSString *)externalLink;
{
  BrowserViewController_iPad * browserView = [[BrowserViewController_iPad alloc] initWithUrl:externalLink];
  [self.foldingNavigationController pushViewController:browserView afterPoppingToController:self];
}

- (void)handleStatusBarDisplayOrHidingIfNecessary
{
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  BOOL isShowingFullscreenMedia = !JMIsClass(keyWindow, ABWindow);
  [UIApplication sharedApplication].statusBarHidden = isShowingFullscreenMedia;
  if (!isShowingFullscreenMedia)
  {
    [UIApplication ab_updateStatusBarTint];
  }
}

@end
