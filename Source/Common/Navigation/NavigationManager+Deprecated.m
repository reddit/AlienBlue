#import "NavigationManager+Deprecated.h"

#import "ABEventLogger.h"
#import "BrowserViewController.h"
#import "CommentsViewController+PopoverOptions.h"
#import "MessagesViewController.h"
#import "MKStoreManager.h"
#import "NSString+ABLegacyLinkTypes.h"
#import "Post.h"
#import "PostsViewController+PopoverOptions.h"
#import "RedditAPI+Account.h"
#import "RedditsViewController.h"
#import "Resources.h"
#import "SettingsViewController.h"
#import "TransparentToolbar.h"
#import "UserDetailsViewController.h"

@interface NavigationManager (Deprecated_)
@property (strong) UIButton *exitFullscreenButton;
@property (strong) UIButton *backFullscreenButton;
@property BOOL isFullscreen;
@end

@implementation NavigationManager (Deprecated)

SYNTHESIZE_ASSOCIATED_STRONG(UIButton, exitFullscreenButton, ExitFullscreenButton);
SYNTHESIZE_ASSOCIATED_STRONG(UIButton, backFullscreenButton, BackFullscreenButton);
SYNTHESIZE_ASSOCIATED_BOOL(isFullscreen, IsFullscreen);
SYNTHESIZE_ASSOCIATED_STRONG(NSMutableDictionary, deprecated_legacyPostDictionary, Deprecated_legacyPostDictionary);

#pragma mark -
#pragma mark - Fullscreen Support

- (void)drawFullScreenBackButton
{
  [self.backFullscreenButton removeFromSuperview];
  BOOL canGoBack = [NavigationManager shared].postsNavigation.viewControllers.count > 1;
  if (canGoBack)
  {
    CGRect bounds = [[self.postsNavigation view] bounds];
    self.backFullscreenButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.backFullscreenButton setFrame:CGRectMake(0, bounds.size.height - 31, 43, 31)];
    [self.backFullscreenButton setAlpha:0.5];
    [[NavigationManager mainView] addSubview:self.backFullscreenButton];
  }
}

- (void)removeFullscreenControls;
{
  self.isFullscreen = NO;
  [self.exitFullscreenButton removeFromSuperview];
  [self.backFullscreenButton removeFromSuperview];
}

- (void)exitFullscreenMode;
{
  if ([Resources useActionMenu])
    return;
  
  if ([Resources isIPAD])
    return;
  
  if (![NavigationManager shared].isFullscreen)
    return;
  
  // reposition the foremost visible scrollview to avoid it abruptly shifting down
  JMOutlineViewController *controller = JMIsKindClassOrNil(self.postsNavigation.topViewController, JMOutlineViewController);
  if (controller)
  {
    CGFloat offsetAmount = JMPortrait() ? 60. : 60.;
    CGPoint oldOffset = controller.tableView.contentOffset;
    CGPoint newOffset = CGPointMake(oldOffset.x, oldOffset.y + offsetAmount);
    controller.tableView.contentOffset = newOffset;
  }
  
  [self removeFullscreenControls];
  self.isFullscreen = NO;
  [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
  [self.postsNavigation setNavigationBarHidden:NO animated:YES];
  [self.postsNavigation setToolbarHidden:NO animated:YES];
  
  [self interactionIconsNeedUpdate];
}

- (void)exitFullscreenAnimated:(BOOL)animated;
{
  if ([Resources useActionMenu])
    return;
  
  [self removeFullscreenControls];
  self.isFullscreen = NO;
  [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
  [self.postsNavigation setNavigationBarHidden:NO animated:animated];
  [self.postsNavigation setToolbarHidden:NO animated:animated];
  
  [self interactionIconsNeedUpdate];
}


- (void)enterFullscreenAdjustsTopScrollView:(BOOL)adjustsTopScrollView;
{
  // reposition the foremost visible scrollview to avoid it abruptly shifting up
  if (adjustsTopScrollView)
  {
    JMOutlineViewController *controller = JMIsKindClassOrNil(self.postsNavigation.topViewController, JMOutlineViewController);
    if (controller)
    {
      CGFloat offsetAmount = JMPortrait() ? 60. : 60.;
      CGPoint oldOffset = controller.tableView.contentOffset;
      CGPoint newOffset = CGPointMake(oldOffset.x, oldOffset.y - offsetAmount);
      if (newOffset.y < 0.)
      {
        newOffset = CGPointZero;
      }
      controller.tableView.contentOffset = newOffset;
    }
  }
  
  [self generateButtonsForFullscreenIfNecessary];
  [self.exitFullscreenButton removeFromSuperview];
  
  [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
  [self.postsNavigation setNavigationBarHidden:YES animated:YES];
  [self.postsNavigation setToolbarHidden:YES animated:YES];
  self.isFullscreen = YES;
  
  CGRect bounds = [[self.postsNavigation view] bounds];
  self.exitFullscreenButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
  [self.exitFullscreenButton setFrame:CGRectMake(bounds.size.width - 43, bounds.size.height - 31, 43, 31)];
  [self.exitFullscreenButton setAlpha:0.5];
  [[NavigationManager mainView] addSubview:self.exitFullscreenButton];
  
  DO_AFTER_WAITING(0.1, ^{
    if (CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame) > 10)
    {
      [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
  });
  
  [self drawFullScreenBackButton];
}

- (void)enterFullscreenMode;
{
  [self enterFullscreenAdjustsTopScrollView:YES];
}

- (void)toggleFullscreen;
{
  if ([Resources useActionMenu])
    return;
  
  if (self.isFullscreen)
  {
    [self exitFullscreenAnimated:YES];
  }
  else
  {
    [self enterFullscreenAdjustsTopScrollView:YES];
  }
}

- (void)generateButtonsForFullscreenIfNecessary;
{
  if (self.exitFullscreenButton)
    return;
  
  self.exitFullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.exitFullscreenButton setImage:[UIImage imageNamed:@"show-toolbars-button.png"] forState:UIControlStateNormal];
  [self.exitFullscreenButton addTarget:self action:@selector(exitFullscreenMode) forControlEvents:UIControlEventTouchUpInside];
  
  self.backFullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.backFullscreenButton setImage:[UIImage imageNamed:@"fullscreen-back-button.png"] forState:UIControlStateNormal];
  [self.backFullscreenButton addTarget:self action:@selector(goBackToPreviousScreen) forControlEvents:UIControlEventTouchUpInside];
}

- (void)deprecated_handleFullscreenWillShowViewControllerAdjustments;
{
  if (!self.isFullscreen)
    return;
  
  [self enterFullscreenAdjustsTopScrollView:NO];
  [self drawFullScreenBackButton];
}

- (void)deprecated_handleFullscreenAdjustmentsAfterRotationIfNecessary;
{
  if (![Resources isIPAD] && [[NavigationManager shared] isFullscreen])
  {
    [self enterFullscreenAdjustsTopScrollView:NO];
  }
}

- (BOOL)deprecated_isFullscreen;
{
  return self.isFullscreen;
}

- (void)deprecated_toggleFullscreen;
{
  [self toggleFullscreen];
}

- (void)deprecated_exitFullscreenAnimated:(BOOL)animated;
{
  [self exitFullscreenAnimated:animated];
}

- (void)deprecated_exitFullscreenMode;
{
  [self exitFullscreenMode];
}

#pragma mark -
#pragma mark - Legacy Updates to Navigation & Toolbar UI Icons

- (void)deprecated_drawIphoneBottomToolbarItems;
{
  [self drawIphoneBottomToolbarItems];
}

- (void)deprecated_drawIphoneVotingItems;
{
  [self drawIphoneVotingItems];
}

- (void)drawIphoneVotingItems
{
  if (!self.deprecated_legacyPostDictionary || ![self.deprecated_legacyPostDictionary isKindOfClass:[NSDictionary class]])
    return;
  
  TransparentToolbar *tb = [[TransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, 146, 44)];
  
  UIColor *neutralIconColor = JMIsNight() ? [UIColor colorWithWhite:0.3 alpha:1.] : [UIColor colorWithWhite:0.75 alpha:1.];
  UIBarButtonItem* voteUpPostItem = [UIBarButtonItem skinBarItemWithIcon:@"upvote-icon" fillColor:neutralIconColor target:self action:@selector(upvoteCurrentPost:)];
  UIBarButtonItem* voteDownPostItem = [UIBarButtonItem skinBarItemWithIcon:@"downvote-icon" fillColor:neutralIconColor target:self action:@selector(downvoteCurrentPost:)];
  
  if (self.lastVisitedPost.voteState == VoteStateUpvoted)
  {
    voteUpPostItem = [UIBarButtonItem skinBarItemWithIcon:@"upvote-icon" fillColor:[UIColor colorWithHex:0xf08f42] target:self action:@selector(upvoteCurrentPost:)];
  }
  else if (self.lastVisitedPost.voteState == VoteStateDownvoted)
  {
    voteDownPostItem = [UIBarButtonItem skinBarItemWithIcon:@"downvote-icon" fillColor:[UIColor colorForDownvote] target:self action:@selector(downvoteCurrentPost:)];
  }
  
  UIBarButtonItem * voteItemSpacing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  [voteItemSpacing setWidth:5.];
  
  UIBarButtonItem * marginEdge = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  [marginEdge setWidth:24.];
  
  tb.items = [NSArray arrayWithObjects:marginEdge, voteDownPostItem, voteItemSpacing, voteUpPostItem, marginEdge, nil];
  
  UIBarButtonItem *tbItem = [[UIBarButtonItem alloc] initWithCustomView:tb];
  self.postsNavigation.visibleViewController.navigationItem.rightBarButtonItem = tbItem;
}

- (void)drawIphoneBottomToolbarItems;
{
  if ([Resources isIPAD])
    return;
  
  BOOL showRibbonOnFourthItem = NO;
  BOOL showToolbarUpCenterArrow = NO;
  UIColor *toolbarBGColor = [UIColor colorForBackground];
  
  UIBarButtonItem *messagesItem = [UIBarButtonItem skinBarItemWithIcon:@"inbox-icon" target:self action:@selector(showMessagesScreen)];
  UIBarButtonItem *fullscreenItem = [UIBarButtonItem skinBarItemWithIcon:@"fullscreen-icon" target:self action:@selector(enterFullscreenMode)];
  
  UIViewController * vc = self.postsNavigation.topViewController;
  
  if (!vc)
    return;
  
  if (![vc isKindOfClass:[BrowserViewController class]]
      && ![vc isKindOfClass:[RedditsViewController class]]
      && ![vc isKindOfClass:[PostsViewController class]]
      && ![vc isKindOfClass:[CommentsViewController class]])
    return;
  
  if ([vc isKindOfClass:[RedditsViewController class]])
  {
    // don't overwrite toolbar items while we're editing groups/subreddits
    if ([(RedditsViewController *)vc tableView].editing)
      return;
  }
  
  if ([RedditAPI shared].hasMail)
  {
    UIButton * vOrangeEnvelopeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *orangeredIcon = [UIImage skinImageNamed:@"generated/orangered-icon"];
    [vOrangeEnvelopeButton setImage:orangeredIcon forState:UIControlStateNormal];
    [vOrangeEnvelopeButton addTarget:self action:@selector(showMessagesScreen) forControlEvents:UIControlEventTouchUpInside];
    vOrangeEnvelopeButton.showsTouchWhenHighlighted = YES;
    [vOrangeEnvelopeButton setFrame:CGRectMake(0,0,44,44)];
    [vOrangeEnvelopeButton setImageEdgeInsets:UIEdgeInsetsMake(-1, 1,0,0)];
    
    [messagesItem setCustomView:vOrangeEnvelopeButton];
  }
  else if ([RedditAPI shared].hasModMail)
  {
    UIButton * vOrangeEnvelopeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *modIcon = [UIImage skinImageNamed:@"generated/modmail-icon"];
    [vOrangeEnvelopeButton setImage:modIcon forState:UIControlStateNormal];
    [vOrangeEnvelopeButton addTarget:self action:@selector(showMessagesScreen) forControlEvents:UIControlEventTouchUpInside];
    [vOrangeEnvelopeButton setFrame:CGRectMake(0,0,44,44)];
    [vOrangeEnvelopeButton setImageEdgeInsets:UIEdgeInsetsMake(-1, 1,0,0)];
    vOrangeEnvelopeButton.showsTouchWhenHighlighted = YES;
    [messagesItem setCustomView:vOrangeEnvelopeButton];
  }
  
  UIBarButtonItem *gotoSettingsItem = [UIBarButtonItem skinBarItemWithIcon:@"settings-icon" target:self action:@selector(showSettingsScreen)];
  UIBarButtonItem *actionSheetItem = [UIBarButtonItem skinBarItemWithIcon:@"action-icon" target:vc action:@selector(popupExtraOptionsActionSheet:)];
  UIBarButtonItem *searchItem = [UIBarButtonItem skinBarItemWithIcon:@"search-icon" target:vc action:@selector(showSearch)];
  UIBarButtonItem *gotoCommentsItem = [UIBarButtonItem skinBarItemWithIcon:@"comments-icon" target:self action:@selector(switchToComments)];
  
  NSString *linkIconName = (self.lastVisitedPost.linkTypeIconName == nil) ? @"browser-icon" : self.lastVisitedPost.linkTypeIconName;
  if (self.lastVisitedPost.linkType == LinkTypeSelf)
  {
    linkIconName = @"self-icon";
  }
  
  UIBarButtonItem *gotoWeblinkItem = [UIBarButtonItem skinBarItemWithIcon:linkIconName target:self action:@selector(switchToArticle)];
  
  UIBarButtonItem * fixedWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  [fixedWidth setWidth:12.0];
  
  UIBarButtonItem * edgeMarginWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  CGFloat marginWidth = JMIsIOS7() ? -10. : -6.;
  [edgeMarginWidth setWidth:marginWidth];
  
  UIBarButtonItem * flexibleWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  
  NSMutableArray * iconArray = [NSMutableArray arrayWithCapacity:10];
  
  [iconArray addObject:edgeMarginWidth];
  
  if(![vc isKindOfClass:[BrowserViewController class]])
  {
    [iconArray addObject:messagesItem];
    if ([vc isKindOfClass:[RedditsViewController class]])
      [iconArray addObject:fixedWidth];
    else
      [iconArray addObject:flexibleWidth];
    [iconArray addObject:gotoSettingsItem];
  }
  
  if(![MKStoreManager isProUpgraded] && [vc isKindOfClass:[RedditsViewController class]])
  {
    NSString *upgradeTitle = ([[MKStoreManager proUpgradePriceInfo] length] > 0) ? [NSString stringWithFormat:@"Go PRO (%@)",[MKStoreManager proUpgradePriceInfo]] : @"Upgrade to PRO";
    UIBarButtonItem* upgradeToProItem = [UIBarButtonItem skinBarItemWithTitle:upgradeTitle textColor:JMHexColor(ffffff) fillColor:nil positionOffset:CGSizeZero target:self action:@selector(showProUpgradeScreen)];
    
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:upgradeToProItem];
  }
  else if (![vc isKindOfClass:[BrowserViewController class]]
           && ![vc isKindOfClass:[RedditsViewController class]]
           && ![vc isKindOfClass:[UserDetailsViewController class]]
           && ![vc isKindOfClass:[MessagesViewController class]]
           )
  {
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:actionSheetItem];
  }
  
  if([vc isKindOfClass:[UserDetailsViewController class]]
     || [vc isKindOfClass:[MessagesViewController class]]
     )
  {
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:flexibleWidth];
  }
  else if([vc isKindOfClass:[PostsViewController class]])
  {
    showToolbarUpCenterArrow = YES;
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:searchItem];
  }
  else if([vc isKindOfClass:[CommentsViewController class]])
  {
    [self drawIphoneVotingItems];
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:gotoWeblinkItem];
    
    showRibbonOnFourthItem = YES;
    
    NSString *linkType = [NSString ab_getLinkType:[self.deprecated_legacyPostDictionary valueForKey:@"url"]];
    if ([linkType equalsString:@"self"]
        || [linkType length] == 0)
    {
      [gotoWeblinkItem setEnabled:NO];
    }
  }
  else if([vc isKindOfClass:[BrowserViewController class]])
  {
    BrowserViewController * browserView = (BrowserViewController *) vc;
    
    UIBarButtonItem *backItem = [UIBarButtonItem skinBarItemWithIcon:@"back-arrow-icon" target:browserView action:@selector(browserBack)];
    UIBarButtonItem *forwardItem = [UIBarButtonItem skinBarItemWithIcon:@"forward-arrow-icon" target:browserView action:@selector(browserForward)];
    
    if (!browserView.browserCanGoBack)
      backItem.enabled = NO;
    
    if (!browserView.browserCanGoForward)
      forwardItem.enabled = NO;
    
    [iconArray addObject:backItem];
    
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:forwardItem];
    
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:actionSheetItem];
    
    [iconArray addObject:flexibleWidth];
    [iconArray addObject:gotoCommentsItem];
    
    showRibbonOnFourthItem = YES;
    
    NSString *linkType = [NSString ab_getLinkType:[self.deprecated_legacyPostDictionary valueForKey:@"url"]];
    if ([linkType equalsString:@"image"] || [linkType length] == 0)
    {
      toolbarBGColor = [UIColor blackColor];
    }
    
    if (!browserView.shouldHideVoteIcons)
    {
      [self drawIphoneVotingItems];
    }
    else
    {
      [gotoCommentsItem setEnabled:NO];
    }
  }
  
  [iconArray addObject:flexibleWidth];
  [iconArray addObject:fullscreenItem];
  [iconArray addObject:edgeMarginWidth];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [vc setToolbarItems:iconArray];
    ABToolbar *toolbar = (ABToolbar *)self.postsNavigation.toolbar;
    [toolbar setShowsRibbon:showRibbonOnFourthItem];
    [toolbar setShowsUpArrow:showToolbarUpCenterArrow];
    [toolbar setToolbarBackgroundColor:toolbarBGColor];
  });
}

- (void)upvoteCurrentPost: (id) sender
{
  REQUIRES_REDDIT_AUTHENTICATION;
  [[ABEventLogger shared] logUpvoteChangeForPost:self.lastVisitedPost
                                       container:@"classic_detail"
                                         gesture:@"button_press"];
  if (self.lastVisitedPost)
  {
    [self.lastVisitedPost upvote];
  }
  
  [self interactionIconsNeedUpdate];
}

- (void)downvoteCurrentPost: (id) sender
{
  REQUIRES_REDDIT_AUTHENTICATION;
  [[ABEventLogger shared] logDownvoteChangeForPost:self.lastVisitedPost
                                         container:@"classic_detail"
                                           gesture:@"button_press"];
  if (self.lastVisitedPost)
  {
    [self.lastVisitedPost downvote];
  }
  
  [self interactionIconsNeedUpdate];
}

- (void)deprecated_applyNightSwitchGestureRecognizer;
{
  if (!JMIsIphone())
    return;
  
  UITapGestureRecognizer *navbarTripleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarTripleTapped:)];
  navbarTripleTapGesture.numberOfTapsRequired = 3;
  [self.postsNavigation.navigationBar addGestureRecognizer:navbarTripleTapGesture];
  navbarTripleTapGesture.delaysTouchesBegan = NO;
  navbarTripleTapGesture.delaysTouchesEnded = NO;
}

@end
