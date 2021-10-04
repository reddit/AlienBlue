#import "BrowserViewController_iPhone.h"
#import "JMOptimalContentCoordinator.h"
#import "Resources.h"

#import "JMOptimalToolbarCoordinator.h"
#import "JMOptimalContentCoordinator.h"
#import "JMOptimalGestureCoordinator.h"

#import "JMGalleryFocusMediaView.h"
#import "JMImageContentOptimizer.h"
#import "JMYouTubeContentOptimizer.h"
#import "JMArticleContentOptimizer.h"
#import "JMAlbumContentOptimizer_iPhone.h"
#import "BrowserNavigationBar.h"
#import "JMOptimalProgressBar.h"

#import "JMYouTubeContentOptimizer.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "ABCustomOutlineNavigationBar.h"
#import "NavigationManager+Deprecated.h"

@interface BrowserViewController() <JMOptimalGestureCoordinatorDelegate>
@property (readonly) BOOL shouldHookGestureListener;
- (void)contentOptimizerDidSucceed:(JMContentOptimizer *)optimizer;
- (void)contentOptimizerDidFail:(JMContentOptimizer *)optimizer;
- (void)contentOptimizer:(JMContentOptimizer *)optimizer didProgress:(CGFloat)progress;
- (void)contentOptimizer:(JMContentOptimizer *)optimizer didRecommendContentSize:(CGSize)size;
- (void)contentOptimizer:(JMContentOptimizer *)optimizer didRecommendAnotherOptimizer:(JMContentOptimizer *)anotherOptimizer;
- (void)contentCoordinatorStandardBrowserDidStartLoading:(JMOptimalContentCoordinator *)contentCoordinator;
- (void)contentCoordinatorStandardBrowserDidFinishLoading:(JMOptimalContentCoordinator *)contentCoordinator;
- (BOOL)contentCoordinatorStandardBrowser:(JMOptimalContentCoordinator *)contentCoordinator shouldLoadRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
@property (strong) JMOptimalContentCoordinator *contentCoordinator;
@property (strong) JMOptimalToolbarCoordinator *toolbarCoordinator;
@property (strong) JMOptimalGestureCoordinator *gestureCoordinator;
@end

@interface BrowserViewController_iPhone ()
@property CGPoint scrollViewOffsetPriorToPanGesture;
@property BOOL userDidHideCustomNavigationBarManually;
@end

@implementation BrowserViewController_iPhone

- (void)viewDidLoad;
{
  [super viewDidLoad];
  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:nil action:nil];
}

- (void)loadView;
{
  [super loadView];
  [self.loadingIndicator removeFromSuperview];
}

- (void)contentCoordinatorStandardBrowserDidFinishLoading:(JMOptimalContentCoordinator *)contentCoordinator;
{
  if (![Resources useActionMenu])
    return [super contentCoordinatorStandardBrowserDidFinishLoading:contentCoordinator];
  

  [super contentCoordinatorStandardBrowserDidFinishLoading:contentCoordinator];
  [[NavigationManager shared] interactionIconsNeedUpdate];
  
  if ([Resources useActionMenu] && self.contentView.top == 0.)
  {
    self.contentView.top = self.attachedCustomNavigationBar.height;
  }
}

#pragma mark - Action Menu Compatibility Patches

- (UIScrollView *)affectedWebScrollViewInsideContentView;
{
  BOOL isWebContent = !self.isShowingOptimal || JMIsClass(self.optimizer, JMArticleContentOptimizer);
  if (!isWebContent)
    return nil;
  
  UIWebView *webView = (UIWebView *)[self.contentView jm_firstSubviewOfClass:[UIWebView class]];
  if (webView)
  {
    UIScrollView *scrollview = webView.scrollView;
    return scrollview;
  }
  return nil;
}

- (BOOL)gestureCoordinatorShouldSnapAfterRepositioningOptimalBar;
{
  if (![Resources useActionMenu])
    return [super gestureCoordinatorShouldSnapAfterRepositioningOptimalBar];

  return NO;
}

- (void)gestureCoordinatorWillRepositionOptimalBar;
{
  if (![Resources useActionMenu])
    return [super gestureCoordinatorWillRepositionOptimalBar];
  
  self.scrollViewOffsetPriorToPanGesture = [self affectedWebScrollViewInsideContentView].contentOffset;
}

- (void)gestureCoordinatorDidRepositionOptimalBarWithOffsetDelta:(CGFloat)optimalBarPostionOffsetDelta andAdjustedInternalScrollViewWithOffsetDelta:(CGFloat)scrollViewOffsetDelta;
{
  if (![Resources useActionMenu])
    return [super gestureCoordinatorDidRepositionOptimalBarWithOffsetDelta:optimalBarPostionOffsetDelta andAdjustedInternalScrollViewWithOffsetDelta:scrollViewOffsetDelta];
  
  JMOutlineCustomNavigationBar *navbar = self.attachedCustomNavigationBar;
  CGFloat visibleOptimalToolbarHeight = self.toolbarCoordinator.view.height + self.toolbarCoordinator.view.top + optimalBarPostionOffsetDelta;
  CGFloat proposedNavbarHeight = JM_LIMIT(navbar.minimumBarHeight, navbar.maximumBarHeight, visibleOptimalToolbarHeight);

  if (self.shouldUseCompactNavigationBar)
  {
    proposedNavbarHeight = navbar.minimumBarHeight;
  }

  UIScrollView *affectedScrollView = [self affectedWebScrollViewInsideContentView];
  if (affectedScrollView != nil)
  {
    CGFloat contentViewDeltaFromDefault = self.contentView.top - proposedNavbarHeight;
    self.contentView.top -= contentViewDeltaFromDefault;
    CGFloat adjustedScrollOffsetY = affectedScrollView.contentOffset.y - contentViewDeltaFromDefault;
    affectedScrollView.contentOffset = CGPointMake(affectedScrollView.contentOffset.x, adjustedScrollOffsetY);
    
    if (affectedScrollView.contentOffset.y < 0. && affectedScrollView.isDragging && !self.shouldUseCompactNavigationBar)
    {
      CGFloat proposedNavbarHeightToFillBounceGap = proposedNavbarHeight + (-1 * affectedScrollView.contentOffset.y);
      proposedNavbarHeight = JM_LIMIT(navbar.minimumBarHeight, navbar.maximumBarHeight, proposedNavbarHeightToFillBounceGap);
    }
    affectedScrollView.contentInset = UIEdgeInsetsMake(0., 0, navbar.minimumBarHeight, 0.);
  }
  [navbar setHeight:proposedNavbarHeight];
  self.toolbarCoordinator.view.height = navbar.height;
  if (affectedScrollView.contentSize.height > self.view.bounds.size.height && affectedScrollView.contentOffset.y > 200)
  {
    self.contentView.height = self.view.bounds.size.height - self.contentView.top;
  }
}

- (BOOL)gestureCoordinatorShouldCurrentlySupressRepositioningWhilePanGestureIsActive;
{
  if (![Resources useActionMenu])
    return [super gestureCoordinatorShouldCurrentlySupressRepositioningWhilePanGestureIsActive];
  
  return NO;
}

- (BOOL)gestureCoordinatorShouldRequireScrollViewsWithZeroVerticalOffsetToTrigger;
{
  if (![Resources useActionMenu])
    return [super gestureCoordinatorShouldRequireScrollViewsWithZeroVerticalOffsetToTrigger];

  return NO;
}

- (BOOL)gestureCoordinatorShouldOffsetTallImagesToAvoidOverlap;
{
  if (![Resources useActionMenu])
    return [super gestureCoordinatorShouldOffsetTallImagesToAvoidOverlap];

  return NO;
}

- (BOOL)gestureCoordinatorShouldAutoHideOptimalBarForTallImage:(BOOL)isTallImage;
{
  if (![Resources useActionMenu])
    return [super gestureCoordinatorShouldAutoHideOptimalBarForTallImage:isTallImage];

  return isTallImage ? YES : NO;
}

- (void)patchForOutlineTableProxyIfNecessary;
{
  if (![Resources useActionMenu])
    return;
  
  if (self.tableView.hidden)
    return;
  
  self.tableView.hidden = YES;
  self.toolbarCoordinator.view.hidden = YES;
  self.toolbarCoordinator.view.height = self.attachedCustomNavigationBar.defaultBarHeight;
  [self gestureCoordinatorDidRepositionOptimalBarWithOffsetDelta:0. andAdjustedInternalScrollViewWithOffsetDelta:0.];
  
  if (JMIsClass(self.optimizer, JMArticleContentOptimizer))
  {
    UIView *largeProgressView = [self.optimizer.view jm_firstSubviewOfClass:[JMOptimalProgressBar class]];
    largeProgressView.top -= self.attachedCustomNavigationBar.defaultBarHeight;
  }
}

- (BOOL)gestureCoordinatorOverrideOptimalBarHideBehavior:(BOOL)hidden animated:(BOOL)animated;
{
  if (![Resources useActionMenu])
    return [super gestureCoordinatorOverrideOptimalBarHideBehavior:hidden animated:animated];

  BOOL isImageOptimal = self.isShowingOptimal && JMIsClass(self.optimizer, JMImageContentOptimizer);

  if (isImageOptimal && !self.userDidHideCustomNavigationBarManually)
  {
    [self setCustomNavigationBarHidden:hidden animated:animated];
  }

  return YES;
}

- (void)contentOptimizerDidSucceed:(JMContentOptimizer *)optimizer;
{
  [super contentOptimizerDidSucceed:optimizer];
  if (![Resources useActionMenu])
    return;

  [self configureContentViewForArticleIfNecessary];
  [self configureContentViewForImageIfNecessary];
  [self configureContentViewForYouTubeIfNecessary];
  [self configureContentViewForAlbumIfNecessary];
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  [self patchForOutlineTableProxyIfNecessary];
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
}

- (void)setCustomNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
{
  ABCustomOutlineNavigationBar *navbar = (ABCustomOutlineNavigationBar *)self.attachedCustomNavigationBar;
  [navbar setHidden:hidden animated:animated];
}

- (void)configureContentViewForArticleIfNecessary;
{
  if (!JMIsClass(self.optimizer, JMArticleContentOptimizer))
    return;

//  UIWebView *webView = (UIWebView *)[self.contentView jm_firstSubviewOfClass:[UIWebView class]];
//  if (webView)
//  {
//    webView.backgroundColor = [UIColor colorForBackground];
////    UIScrollView *scrollview = webView.scrollView;
////    return scrollview;
//  }

}

- (void)configureContentViewForImageIfNecessary;
{
  BOOL isImageOptimal = self.isShowingOptimal && JMIsClass(self.optimizer, JMImageContentOptimizer);
  if (!isImageOptimal)
    return;
  
  self.contentView.top = 0.;
  
  BSELF(BrowserViewController_iPhone);
  [self focusMediaView].onSingleTapAction = ^{
    BOOL isNavbarHidden = blockSelf.attachedCustomNavigationBar.alpha == 0.;
    if (!isNavbarHidden)
    {
      blockSelf.userDidHideCustomNavigationBarManually = YES;
    }
    [blockSelf setCustomNavigationBarHidden:!isNavbarHidden animated:YES];
  };
  
  [self focusMediaView].backgroundColor = [UIColor colorForBackground];
}

- (void)configureContentViewForAlbumIfNecessary;
{
  BOOL isAlbumOptimal = self.isShowingOptimal && JMIsClass(self.optimizer, JMAlbumContentOptimizer_iPhone);
  if (!isAlbumOptimal)
    return;
  
  self.contentView.top = 0.;
  
  JMAlbumContentOptimizer_iPhone *albumOptimizer = JMCastOrNil(self.optimizer, JMAlbumContentOptimizer_iPhone);
  
  BSELF(BrowserViewController_iPhone);
  albumOptimizer.customOnSingleTapAction = ^{
    BOOL isNavbarHidden = blockSelf.attachedCustomNavigationBar.alpha == 0.;
    if (!isNavbarHidden)
    {
      blockSelf.userDidHideCustomNavigationBarManually = YES;
    }
    [blockSelf setCustomNavigationBarHidden:!isNavbarHidden animated:YES];
  };
}

- (void)configureContentViewForYouTubeIfNecessary;
{
  BOOL isVideoOptimal = self.isShowingOptimal && JMIsClass(self.optimizer, JMYouTubeContentOptimizer);
  if (!isVideoOptimal)
    return;
  
  self.contentView.top = 0.;
}

- (void)userDidToggleOptimalSwitch:(BOOL)didChangeToOptimal;
{
  [self configureContentViewForArticleIfNecessary];
  [self configureContentViewForImageIfNecessary];
  [self configureContentViewForYouTubeIfNecessary];
  [self configureContentViewForAlbumIfNecessary];
}

- (JMGalleryFocusMediaView *)focusMediaView;
{
  JMGalleryFocusMediaView *mediaView = (JMGalleryFocusMediaView *)[self.optimizer.view jm_firstSubviewOfClass:[JMGalleryFocusMediaView class]];
  return mediaView;
}

- (void)handleStatusBarDisplayOrHidingIfNecessary
{
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  BOOL isCurrentlyShowingVideo = [keyWindow jm_subviewsMatchingValidation:^BOOL(UIView *view) {
    return [NSStringFromClass(view.class) hasPrefix:@"AVPlayer"];
  }].count > 0;
  
  BOOL isVideoContent = JMIsClass(self.optimizer, JMYouTubeContentOptimizer);
  BOOL layoutSupportsStatusBar = ([Resources useActionMenu] && !(self.attachedCustomNavigationBar.height == self.attachedCustomNavigationBar.minimumBarHeight)) || (![Resources useActionMenu] && ![[NavigationManager shared] deprecated_isFullscreen]);
  BOOL needToRedisplayStatusBar = isVideoContent && !isCurrentlyShowingVideo && layoutSupportsStatusBar && self.isShowingOptimal;
  if (needToRedisplayStatusBar)
  {
    JMAnimateStatusBarHidden(NO);
  }
}

@end
