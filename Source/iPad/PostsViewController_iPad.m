#import "PostsViewController_iPad.h"
#import "PostsNavigation_iPad.h"
#import "PostsHeaderView_iPad.h"

#import "PostsViewController+CanvasSupport.h"
#import "PostsViewController+PopoverOptions.h"
#import "PostsViewController+API.h"

#import "AppDelegate_iPad.h"
#import "NPostCell_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "Resources.h"
#import "NavigationManager_iPad.h"
#import "Subreddit.h"
#import "DiscoveryAddController_iPad.h"
#import "GalleryViewController.h"
#import "SubredditSidebarViewController.h"
#import "RedditAPI+Account.h"
#import "Post+Style.h"

@interface PostsViewController_iPad()
@property (strong) PostsHeaderView_iPad *headerView;
@property (readonly) PostsNavigation_iPad *foldingNav;
@property (strong) Post *i_contentPaneFocussedPost;
@property (strong) GalleryViewController *presentedGalleryController;

- (void)showCanvas_iPad;
- (void)activateFocusOnPost:(Post *)p;
@end

@implementation PostsViewController_iPad

SYNTHESIZE_ASSOCIATED_STRONG(GalleryViewController, presentedGalleryController, PresentedGalleryController);

//kCanvasExitNotification

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCanvasExitNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kContentPaneOpenedForPostNotification object:nil];
}

- (id)initWithSubreddit:(NSString *)subreddit title:(NSString *)title;
{
    self = [super initWithSubreddit:subreddit title:title];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canvasExitNotificationReceived) name:kCanvasExitNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentPaneOpenedForPostNotificationReceived:) name:kContentPaneOpenedForPostNotification object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    Subreddit *sr = [Subreddit subredditWithUrl:self.subreddit name:@""];

    self.headerView = [[PostsHeaderView_iPad alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 55.) forSubreddit:sr];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerView.shadowTriggerOffset = 44.;
    self.headerView.title = self.subredditTitle;
    [self.view addSubview:self.headerView];

    self.tableView.top = self.headerView.height - 5.;
    self.tableView.height -= self.tableView.top;
    self.topShadowView.hidden = YES;
    
    BSELF(PostsViewController_iPad);
    self.headerView.showCanvasButton.onTap = ^(CGPoint touchPoint){
        [blockSelf showCanvas_iPad];
    };
    
    self.headerView.createPostButton.onTap = ^(CGPoint touchPoint)
    {
        [[NavigationManager shared] showCreatePostScreen]; 
    };
    
    self.headerView.searchButton.onTap = ^(CGPoint touchPoint)
    {
        [blockSelf showSearch];
    };
    
    self.headerView.subredditIconOverlay.onTap = ^(CGPoint touchPoint)
    {
        [blockSelf popupSubredditOptions];
    };
    
}

- (void)viewWillLayoutSubviews;
{
    [super viewWillLayoutSubviews];
    if (self.tableView.contentOffset.y <= kPostTableHeaderOffsetWithoutActionMenu)
    {
        [self.tableView setContentOffset:CGPointMake(0., kPostTableHeaderOffsetWithoutActionMenu) animated:NO];
    }
}

- (PostsNavigation_iPad *)foldingNav;
{
    PostsNavigation_iPad *nav = (PostsNavigation_iPad *) [NavigationManager shared].postsNavigation;
    return  nav;
}

- (void)respondToStyleChange;
{
    [super respondToStyleChange];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorForBackground];
    
//    self.footerCoordinator.view.backgroundColor = [UIColor colorForBackground];
//    self.footerCoordinator.sliderView.backgroundColor = [UIColor colorForBackground];
}

- (BOOL)isNavigatingBackToCanvasFromComments;
{
  return self.presentedGalleryController && !self.presentedGalleryController.view.userInteractionEnabled;
}

- (CGFloat)pageWidth;
{
    if ([self isNavigatingBackToCanvasFromComments])
    {
      // A user may go to [Canvas]->[Comments]->[User Details]->[Posts]
      // and then take the PostsViewController (and thus) Canvas out of
      // fullscreen. Even though we officially make it fullscreen in
      // foldingViewWillBecomeActive... forcing the width here stops
      // the canvas from shrinking its width before expanding again.
      return self.foldingNavigationController.wrapperView.width;
    }

  
    CGFloat width = JMPortrait() ? 414. : 430.;

    BOOL isLastController = (self == [self.foldingNav.viewControllers last]);
    BOOL isSecondLastController =  !isLastController && (self == [self.foldingNav.viewControllers objectAtIndex:1]);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kABSettingKeyIpadUseLegacyPostPaneSize] && JMLandscape())
    {
        if (isLastController)
        {
            width = 670.;
        }
        else if (isSecondLastController)
        {
            width = 360.;
        }
    }
    
    if ([Resources compactPortrait] && isSecondLastController)
    {
        width = 320.;
    }
    else
    {
        if (![NavigationManager_iPad foldingNavigation].showingSidePane)
        {
            if (JMPortrait() || (isLastController && [[NSUserDefaults standardUserDefaults] boolForKey:kABSettingKeyIpadUseLegacyPostPaneSize]))
                width += kSidePaneWidth;
        }
    }
    
    return width;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [super scrollViewDidScroll:scrollView];
    [self.headerView updateWithContentOffset:scrollView.contentOffset];
}
\

- (void)foldingViewWillBecomeActive;
{
  // if a users opens comments from canvas view, flush the panes away
  // to conserve memory once the user brings canvas back in.
  if (self.presentedGalleryController && self.foldingNavigationController.topViewController != self)
  {
    [self.foldingNavigationController popToViewController:self animated:YES];
  }
  
  if ([self isNavigatingBackToCanvasFromComments])
  {
    self.presentedGalleryController.view.userInteractionEnabled = YES;
    if (!self.fullScreen)
    {
      [self toggleFullscreen];
    }
  }
}

- (void)foldingViewWillBecomeInactive;
{
  if (self.presentedGalleryController && self.foldingNavigationController.topViewController != self)
  {
    self.presentedGalleryController.view.userInteractionEnabled = NO;
  }
}

- (void)presentGalleryModally;
{
  NSString *additionalParams = [[self additionalURLParamsFromHeaderCoordinator] urlEncodedString];
	GalleryViewController *controller = [[UNIVERSAL(GalleryViewController) alloc] initWithSubredditUrl:self.subreddit additionalParams:additionalParams title:self.title];
  self.presentedGalleryController = controller;
  [self addChildViewController:controller];
  [self.view addSubview:controller.view];
  controller.view.autoresizingMask = JMFlexibleSizeMask;
  controller.view.frame = self.view.bounds;
  controller.view.alpha = 0.;
  DO_AFTER_WAITING(1, ^{
    [UIView jm_transition:controller.view animations:^{
      controller.view.alpha = 1.;
    } completion:nil];
  });
}

- (void)removeCanvas_iPad;
{
  [self.presentedGalleryController removeFromParentViewController];
  [self.presentedGalleryController.view removeFromSuperview];
  self.presentedGalleryController = nil;
  [super removeCanvas];
}

- (void)showCanvas_iPad;
{
    self.fullScreen = YES;
    self.disallowPinchClose = YES;
    self.shouldLaunchCanvasWithViewHidden = YES;
    self.disallowSlidingWhenActiveAndFullscreen = YES;
  
    PostsNavigation_iPad *nav = (PostsNavigation_iPad *)self.foldingNavigationController;
    
    BSELF(PostsViewController_iPad);
    blockSelf.containerView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.];
    [UIView animateWithDuration:0.5 animations:^{
        blockSelf.tableView.top = blockSelf.view.height;
        blockSelf.headerView.bottom = 0.;
        [blockSelf.containerView hideBorder];
        nav.innerShadow.alpha = 0.;
        nav.rightShadow.alpha = 0.;
    } completion:^(BOOL finished) {
        blockSelf.tableView.alpha = 0.;
        [UIView animateWithDuration:0.5 animations:^{
            [nav hideSidePaneAnimated:YES showingRevealButton:NO];
            [nav layoutControllersNow];
            [nav popToViewController:blockSelf animated:YES];
            [nav activateController:blockSelf scrolling:YES];
        } completion:^(BOOL finished) {
            [blockSelf presentGalleryModally];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCanvasLaunchNotification object:nil];
        }];
    }];
}

- (void)canvasExitNotificationReceived;
{
    self.fullScreen = NO;
    self.disallowPinchClose = NO;
    self.disallowSlidingWhenActiveAndFullscreen = NO;
    
    PostsNavigation_iPad *nav = (PostsNavigation_iPad *)self.foldingNavigationController;

    BSELF(PostsViewController_iPad);
    blockSelf.containerView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.7 animations:^{
        [blockSelf removeCanvas_iPad];
        [nav layoutControllersNow];
        [nav activateController:blockSelf scrolling:YES];
        blockSelf.tableView.alpha = 1.;
        [nav showSidePaneAnimated:YES];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 animations:^{
            nav.innerShadow.alpha = 1.;
            nav.rightShadow.alpha = 1.;
            blockSelf.tableView.bottom = blockSelf.view.height;
            blockSelf.headerView.top = 0.;
        } completion:^(BOOL finished) {
            [blockSelf.containerView updateBorder];
        }];
    }];    
}

- (BOOL)isContentPaneOpenForPost:(Post *)post;
{
    if (!self.i_contentPaneFocussedPost)
        return NO;
    
    return [post.name equalsString:self.i_contentPaneFocussedPost.name];
}

- (PostNode *)postNodeForPostName:(NSString *)name;
{
    PostNode *matchingNode = [self.nodes first:^BOOL(JMOutlineNode *node) {
        if (![node isKindOfClass:[PostNode class]])
            return NO;
        
        PostNode *postNode = (PostNode *)node;
        return [postNode.post.name equalsString:name];
    }];
    return matchingNode;
}

- (CGFloat)offsetRatioForNode:(JMOutlineNode *)node;
{
    CGFloat offsetYFromTop = fmodf([self rectForNode:node].origin.y, self.tableView.contentOffset.y);
    CGFloat offsetRatio = offsetYFromTop / self.tableView.height;
    return offsetRatio;
}

- (void)scrollToLastTouchedPost;
{
    if (self.i_contentPaneFocussedPost)
    {
        [self activateFocusOnPost:self.i_contentPaneFocussedPost];
    }
}

- (void)i_activateFocusOnPost:(Post *)p;
{
  if (self.isCanvasShowing)
    return;
  
  NSMutableArray *nodesToReload = [NSMutableArray array];
  
  PostNode *focussingOnNode = [self postNodeForPostName:p.name];
  if (!focussingOnNode)
  {
    return;
  }
  
  // before redrawing (eg. when the posts pane resizes), track the position of this cell
  // relative to the size of the table, so that the touch position is consistent.
  CGFloat offsetRatioOriginal = [self offsetRatioForNode:focussingOnNode];
  
  if (focussingOnNode)
  {
    [nodesToReload addObject:focussingOnNode];
  }
  
  if (self.i_contentPaneFocussedPost)
  {
    PostNode *previouslyFocussedNode = [self postNodeForPostName:self.i_contentPaneFocussedPost.name];
    if (previouslyFocussedNode && previouslyFocussedNode != focussingOnNode)
    {
      [nodesToReload addObject:previouslyFocussedNode];
    }
  }
  
  self.i_contentPaneFocussedPost = p;
  [p flushCachedStyles];
  
  BSELF(PostsViewController_iPad);
  
  if (!self.tableView.isDragging && !self.tableView.isDecelerating && !self.tableView.isTracking)
  {
    [NSTimer bk_scheduledTimerWithTimeInterval:0.1 block:^(NSTimer *timer) {
      // restore scroll location so that the cell re-appears right under the touch point even if the table
      // is resized
      CGFloat offsetRatioNew = [blockSelf offsetRatioForNode:focussingOnNode];
      CGFloat requiredOffset = (offsetRatioNew - offsetRatioOriginal) * blockSelf.tableView.height;
      if (!isnan(requiredOffset))
      {
        blockSelf.tableView.contentOffset = CGPointMake(0., blockSelf.tableView.contentOffset.y + requiredOffset);
      }
      
      // the transition animation "freaks out" the options drawer when it's visible, so skip it
      // if we're presenting the comment drawer for this node
      CGFloat animationDuration = (blockSelf.selectedNode == focussingOnNode) ? 0. : 0.15;
      [UIView transitionWithView:blockSelf.tableView duration:animationDuration options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
        if (nodesToReload.count > 0 && blockSelf && [blockSelf isKindOfClass:[PostsViewController_iPad class]])
        {
          [blockSelf reloadRowsForNodes:nodesToReload];
        }
      } completion:nil];
    } repeats:NO];
  }
  else
  {
    if (nodesToReload.count > 0)
    {
      [blockSelf reloadRowsForNodes:nodesToReload];
    }
  }
}

- (void)activateFocusOnPost:(Post *)p;
{
  BSELF(PostsViewController_iPad);
  DO_IN_MAIN(^{
    [blockSelf i_activateFocusOnPost:p];
  });
}

- (void)contentPaneOpenedForPostNotificationReceived:(NSNotification *)notification;
{
  Post *p = (Post *)notification.object;
  [self activateFocusOnPost:p];
}

- (void)setNavbarTitle:(NSString *)title
{
  self.headerView.title = title;
  [self.headerView.titleOverlay setNeedsDisplay];
  NSString *paneTitle = [title jm_removeOccurrencesOfString:@"Search in "];
  [self.foldingNav setPaneTitle:paneTitle];
}

- (void)foldingViewDidResize;
{
    // This is used when a person hits back from viewing contents. The paneWidth could expand, so we want
    // to scroll back to their last viewed post to give the user some context.
    [self scrollToLastTouchedPost];
}


- (void)presentSubredditOptionsActionSheet:(UIActionSheet *)sheet;
{
    CGRect openFromRect = self.headerView.subredditIconOverlay.frame;
    [sheet showFromRect:openFromRect inView:self.view animated:YES];
}

- (void)showSidebarForSubreddit:(Subreddit *)sr;
{
  SubredditSidebarViewController *controller = [[UNIVERSAL(SubredditSidebarViewController) alloc] initWithSubredditNamed:sr.title];
  [self.foldingNavigationController pushViewController:controller afterPoppingToController:self];
}

- (void)showAddSubredditToGroup;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    Subreddit *sr = [Subreddit subredditWithUrl:self.subreddit name:@""];
    UINavigationController *navController = [DiscoveryAddController_iPad navControllerForAddingSubreddit:sr onComplete:^{
    } excludeDontShowOption:YES excludeRemoveOption:YES];
    navController.ab_contentSizeForViewInPopover = CGSizeMake(320., 400.);
  
    CGRect openFromRect = self.headerView.subredditIconOverlay.frame;
    [(NavigationManager_iPad *)[NavigationManager_iPad shared] showPopoverWithContentViewController:navController inView:self.view fromRect:openFromRect permittedArrowDirections:UIPopoverArrowDirectionAny];
}

@end
