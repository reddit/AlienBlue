//
//  PostsNavigation_iPad.m
//  AlienBlue
//
//  Created by J M on 14/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "PostsNavigation_iPad.h"
#import "NavigationManager_iPad.h"
#import "NotificationBar.h"
#import "AppDelegate_iPad.h"
#import "Resources.h"
#import "JMFNNavigationController+PagingBehavior.h"
#import "SlidingDragReleaseProtocol.h"
#import "UIApplication+ABAdditions.h"
#import "RedditAPI+Account.h"

#define kPostsNavigationDragReleaseThreshold 120.

@interface PostsNavigation_iPad()
@property BOOL showingSidePane;
@property BOOL suppressReleaseGuide;
@property (strong) SidePane_iPad *sidePane;
@property (strong) ABButton *revealSidePaneButton;
@property (strong) NotificationBar *notificationBar;
@property (strong) UILabel *dragReleaseGuide;
- (void)respondToStyleChangeNotification;
@end

@implementation PostsNavigation_iPad

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextSizeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kABAuthenticationStatusDidReceiveUpdatedUserInformation object:nil];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController;
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToStyleChangeNotification) name:kNightModeSwitchNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToStyleChangeNotification) name:kTextSizeChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOrangeredStatus) name:kABAuthenticationStatusDidReceiveUpdatedUserInformation object:nil];
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    [super pushViewController:viewController animated:animated];
}

- (void)loadView;
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];

    self.sidePane = [[SidePane_iPad alloc] initWithFrame:CGRectMake(0., 0., 50., self.wrapperView.height)];
    self.sidePane.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [self.wrapperView insertSubview:self.sidePane atIndex:1];
    
    self.notificationBar = [[NotificationBar alloc] initWithFrame:CGRectMake(0., 0., self.view.width, 36)];
    self.notificationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view insertSubview:self.notificationBar belowSubview:self.wrapperView];

    self.revealSidePaneButton = [ABButton buttonWithImageName:@"icons/ipad-navbar/navbar-sidepane-expand" onTap:^{
        [[NavigationManager_iPad foldingNavigation] showSidePaneAnimated:YES];
    }];
    self.revealSidePaneButton.imageSelected = [UIImage skinImageNamed:@"icons/ipad-navbar/navbar-sidepane-expand-orangered"];
    self.revealSidePaneButton.left = 0.;
    self.revealSidePaneButton.bottom = self.wrapperView.height + 3.;
    self.revealSidePaneButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.wrapperView addSubview:self.revealSidePaneButton];
    
    BOOL hideSidePane =  [[NSUserDefaults standardUserDefaults] boolForKey:kABSettingKeyIpadHideSidePane];
    // call this first to make preliminary adjustments to the paging view size prior to hiding
    [self showSidePaneAnimated:NO];
    if (hideSidePane)
    {
        [self hideSidePaneAnimated:NO showingRevealButton:YES];
    }

//    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:^(UISwipeGestureRecognizer *gesture) {
//        DLog(@"swipeGesture: %@", gesture);
//    }];
//    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.wrapperView addGestureRecognizer:swipeGesture];

    self.dragReleaseGuide = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., 140., 50.)];
    self.dragReleaseGuide.font = [UIFont boldSystemFontOfSize:13.];
    self.dragReleaseGuide.text = @"";
    self.dragReleaseGuide.textAlignment = UITextAlignmentCenter;
    self.dragReleaseGuide.numberOfLines = 2;
    self.dragReleaseGuide.backgroundColor = [UIColor clearColor];
    self.dragReleaseGuide.textColor = [UIColor whiteColor];
    self.dragReleaseGuide.shadowColor = [UIColor blackColor];
    self.dragReleaseGuide.shadowOffset = CGSizeMake(0., 1.);
    self.dragReleaseGuide.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.dragReleaseGuide.hidden = YES;
    [self.wrapperView insertSubview:self.dragReleaseGuide belowSubview:self.pagingView];
    [self.dragReleaseGuide centerVerticallyInSuperView];
    self.dragReleaseGuide.right = self.wrapperView.width ;
    
    [self respondToStyleChangeNotification];
}

- (void)showSidePaneAnimated:(BOOL)animated;
{
    if (self.showingSidePane)
      return;
  
    self.showingSidePane = YES;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kABSettingKeyIpadHideSidePane];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BSELF(PostsNavigation_iPad);
    [UIView jm_animate:^{
        blockSelf.pagingView.left = kSidePaneWidth;
        blockSelf.pagingView.width -= kSidePaneWidth;
        blockSelf.sidePane.left = 0.;
        blockSelf.revealSidePaneButton.alpha = 0.;
        [blockSelf layoutControllersNow];
    } completion:^{
        [blockSelf scrollToActiveController];
    } animated:animated];
}

- (void)hideSidePaneAnimated:(BOOL)animated showingRevealButton:(BOOL)showingRevealButton;
{
  if (!self.showingSidePane)
  {
    self.revealSidePaneButton.alpha = (showingRevealButton) ? 1. : 0.;
    return;
  }

  self.showingSidePane = NO;
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kABSettingKeyIpadHideSidePane];
  [[NSUserDefaults standardUserDefaults] synchronize];

  BSELF(PostsNavigation_iPad);
  [UIView jm_animate:^{
      blockSelf.pagingView.left = 0.;
      blockSelf.pagingView.width += kSidePaneWidth;
      blockSelf.sidePane.left = -kSidePaneWidth;
      blockSelf.revealSidePaneButton.alpha = (showingRevealButton) ? 1. : 0.;
      [blockSelf layoutControllersNow];
  } completion:^{
      [blockSelf scrollToActiveController];
  } animated:animated];
}

- (void)refreshOrangeredStatus;
{
    BSELF(PostsNavigation_iPad);
    [UIView transitionWithView:blockSelf.revealSidePaneButton duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        blockSelf.revealSidePaneButton.selected = [RedditAPI shared].hasMail || [RedditAPI shared].hasModMail;
        [blockSelf.revealSidePaneButton setNeedsDisplay];
    } completion:nil];
}

- (void)respondToStyleChangeNotification;
{
    self.wrapperView.backgroundColor = [UIColor tiledPatternForBackground];

    self.innerShadow.hidden = [Resources isNight];
    self.supressInnerShadow = [Resources isNight];
    
    BSELF(PostsNavigation_iPad);

    // give the controllers a little time to respond to the notification, as they may have not
    // received it just yet
    [NSTimer bk_scheduledTimerWithTimeInterval:0.2 block:^(NSTimer *timer) {
        [blockSelf.viewControllers each:^(UIViewController *controller) {
            [controller viewWillDisappear:NO];
            [controller viewWillAppear:NO];
            
            [controller.containerView updateBorder];
        }];
    } repeats:NO];
}

- (void)setPaneTitle:(NSString *)title;
{
    [self.sidePane setPaneTitle:title];
}

- (void)hideNotification;
{
    BSELF(PostsNavigation_iPad);
    [UIView jm_animate:^{
        blockSelf.wrapperView.top = 0.;
    } completion:^{
        [blockSelf.notificationBar setMessage:@""];
        blockSelf.notificationBar.hidden = YES;
    }];
}

- (void)showNotification:(NSString *)message;
{
    BSELF(PostsNavigation_iPad);
    
    blockSelf.notificationBar.hidden = NO;
    [blockSelf.notificationBar setMessage:message];
    
    [UIView jm_animate:^{
        [blockSelf.notificationBar setMessage:message];
        blockSelf.wrapperView.top = blockSelf.notificationBar.height;
    } completion:^{
        [NSTimer bk_scheduledTimerWithTimeInterval:5. block:^(NSTimer *timer) {
            [blockSelf hideNotification];
        } repeats:NO];
    }];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
{
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;
{
}

- (id)sidePanel;
{
    return nil;
}

//- (UINavigationController *)navigationController;
//{
//    DLog(@"nav controller requested");
//    return super.navigationController;
//}

//- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
//{
//    DLog(@"present modal view in()");
//}
#pragma mark - Folding Controller Drag-Release behavior

- (void)didBeginPinchClose;
{
    self.suppressReleaseGuide = YES;
    if (!self.dragReleaseGuide.hidden)
    {
        BSELF(PostsNavigation_iPad);
        [UIView jm_transition:self.dragReleaseGuide animations:^{
            blockSelf.dragReleaseGuide.hidden = YES;
        } completion:nil animated:YES];
    }
}

- (void)didEndPinchClose;
{
    BSELF(PostsNavigation_iPad);
    [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:^(NSTimer *timer) {
        blockSelf.suppressReleaseGuide = NO;
    } repeats:NO];
}

- (void)didReleaseDragLeftBeyondBoundsOffset:(CGFloat)offset;
{
    if (!self.dragReleaseGuide.hidden)
    {
        BSELF(PostsNavigation_iPad);
        [UIView jm_transition:self.dragReleaseGuide animations:^{
            blockSelf.dragReleaseGuide.hidden = YES;
        } completion:nil animated:YES];
    }
    
    if (offset < kPostsNavigationDragReleaseThreshold)
        return;
    
    if (![self.viewControllers.last conformsToProtocol:@protocol(SlidingDragReleaseProtocol)])
        return;
    
    UIViewController <SlidingDragReleaseProtocol>* controller = self.viewControllers.last;
    if (!controller.canDragRelease)
        return;
    
    if (self.suppressReleaseGuide)
        return;
    
    [controller performSelector:@selector(didDragRelease) withObject:nil afterDelay:0.2];
}

- (void)didDragLeftBeyondBoundsByOffset:(CGFloat)offset;
{    
    if (![self.viewControllers.last conformsToProtocol:@protocol(SlidingDragReleaseProtocol)])
        return;
    
    UIViewController <SlidingDragReleaseProtocol> * controller = self.viewControllers.last;
    if (!controller.canDragRelease)
        return;
    
    if (self.suppressReleaseGuide)
        return;
    
    NSString *willLaunchTitle = controller.titleForDragReleaseLabel;

    CGFloat alpha = JM_LIMIT(0., 1., (offset / kPostsNavigationDragReleaseThreshold));
    CGFloat width = MAX(kPostsNavigationDragReleaseThreshold, offset);
    
    self.dragReleaseGuide.hidden = (alpha < 0.2);
    if (width != self.dragReleaseGuide.width)
    {
        self.dragReleaseGuide.width = width;
        self.dragReleaseGuide.right = self.wrapperView.width;
    }
    self.dragReleaseGuide.alpha = alpha;
    if (alpha == 1.)
    {
        self.dragReleaseGuide.text = [NSString stringWithFormat:@"Release to Show\n%@", willLaunchTitle];
    }
    else 
    {
        self.dragReleaseGuide.text = [NSString stringWithFormat:@"Pull to Show\n%@", willLaunchTitle];
    }
}

- (void)setViewControllers:(NSMutableArray *)viewControllers animated:(BOOL)animated;
{    
}

@end
