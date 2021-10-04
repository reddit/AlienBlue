//
//  PostsNavigation.m
//  AlienBlue
//
//  Created by JM on 5/09/10.
//  Copyright (c) 2010 The Design Shed. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PostsNavigation.h"
#import "AlienBlueAppDelegate.h"
#import "NavigationManager.h"
#import "Resources.h"
#import "ABBundleManager.h"
#import "ABNavigationBar.h"
#import "UINavigationController+ABAdditions.h"
#import "NavigationBackItemView.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "JMSlideableNavigationAnimatorView.h"
#import "SlideableNavigationEdgeView.h"
#import "SlidingDragReleaseProtocol.h"
#import "NavigationManager+Deprecated.h"
#import "ABToolbar.h"
#import "ABCustomOutlineNavigationBar.h"

@interface JMSlideableNavigationController() <UINavigationBarDelegate>
@end

@interface PostsNavigation()
@property BOOL i_isStatusBarHiddenBeforeModalPresentation;
@property BOOL i_isStatusBarHiddenBeforeControllerPush;
@end

@implementation PostsNavigation

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
}

- (id)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass;
{
  self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
  if (self)
  {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToStyleChangeNotification) name:kNightModeSwitchNotification object:nil];
  }
  return self;
}

+ (PostsNavigation *)postsNavigationWithRootControllerOrNil:(UIViewController *)rootControllerOrNil;
{
  if ([Resources isIPAD])
  {
    PostsNavigation *nav = [[UNIVERSAL(PostsNavigation) alloc] initWithRootViewController:rootControllerOrNil];
    return nav;
  }
  
  PostsNavigation *nav = [[PostsNavigation alloc] initWithNavigationBarClass:[ABNavigationBar class] toolbarClass:[ABToolbar class]];
  if (rootControllerOrNil)
  {
    [nav setViewControllers:[NSArray arrayWithObject:rootControllerOrNil] animated:NO];
  }
  return nav;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self respondToStyleChangeNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if (JMIsNight())
    [self.toolbar setBarStyle:UIBarStyleBlack];
  else
    [self.toolbar setBarStyle:UIBarStyleDefault];

  [self.navigationBar setNeedsDisplay];
  [self.toolbar setNeedsDisplay];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  [[NavigationManager shared] deprecated_handleFullscreenAdjustmentsAfterRotationIfNecessary];
}

- (UIViewController *)secondLastController;
{
  if ([self.viewControllers count] <= 1)
    return nil;
  
  return [self.viewControllers objectAtIndex:([self.viewControllers count] - 2)];
}

#pragma mark - Rotation Locks

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return [UINavigationController ab_shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (BOOL)shouldAutorotate;
{
  return [UINavigationController ab_shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations;
{
  return [UINavigationController ab_supportedInterfaceOrientations];
}

- (void)customBackTapped;
{
  [self popViewControllerAnimated:YES];
  [self userDidNavigateBackWithoutSwiping];
}

- (void)replaceNavigationItemWithCustomBackButton:(UINavigationItem *)item;
{
  NavigationBackItemView *backItem = [[NavigationBackItemView alloc] initWithNavigationItem:item];
  UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:backItem];
  item.leftBarButtonItem = customItem;
  item.titleView = [UIView new];
  [backItem addTarget:self action:@selector(customBackTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
{
  [super setViewControllers:viewControllers animated:animated];
  
  BSELF(PostsNavigation);
  [viewControllers each:^(UIViewController *controller) {
    [blockSelf replaceNavigationItemWithCustomBackButton:controller.navigationItem];
  }];
  
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
{
  if (self.shouldSuppressPushingOrPopping)
    return nil;
  
  JMAnimateStatusBarHidden(self.i_isStatusBarHiddenBeforeControllerPush);
  return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;
{
  if (self.shouldSuppressPushingOrPopping)
    return @[];
  
  JMAnimateStatusBarHidden(self.i_isStatusBarHiddenBeforeControllerPush);
  return [super popToRootViewControllerAnimated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
  if (self.shouldSuppressPushingOrPopping)
    return;
  
  self.i_isStatusBarHiddenBeforeControllerPush = JMIsStatusBarHidden();
  [self replaceNavigationItemWithCustomBackButton:viewController.navigationItem];
  [super pushViewController:viewController animated:animated];
}

- (void)respondToStyleChangeNotification;
{
  self.view.backgroundColor = [UIColor skinColorForBackground];
}

#pragma mark -
#pragma mark - SlideableNavigationAnimatorView delegate

- (void)animatorView:(JMSlideableNavigationAnimatorView *)animatorView decorateRightUnderlay:(UIView *)rightUnderlayView forBoundaryOffset:(CGFloat)boundaryOffset;
{
  if (![self.viewControllers.last conformsToProtocol:@protocol(SlidingDragReleaseProtocol)])
    return;
  
  UIViewController <SlidingDragReleaseProtocol> * controller = self.viewControllers.last;
  if (!controller.canDragRelease)
    return;
  
  SlideableNavigationEdgeView *v = (SlideableNavigationEdgeView *)[rightUnderlayView viewWithTag:1234];
  if (!v)
  {
    v = [[SlideableNavigationEdgeView alloc] initWithFrame:CGRectMake(0., 0., 48, 100.)];
    v.tag = 1234;
    [rightUnderlayView addSubview:v];
    v.backgroundColor = [UIColor clearColor];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  }
  CGFloat visibleWidth = MAX(48, boundaryOffset);
  [v centerHorizontallyInRect:CGRectMake(rightUnderlayView.bounds.size.width - visibleWidth, 0., visibleWidth, rightUnderlayView.height)];
  v.frame  = CGRectIntegral(v.frame);
  
  NSString *willLaunchTitle = controller.titleForDragReleaseLabel;
  NSString *verb = (self.shouldActivateBeyondBoundaryTrigger) ? @"Release" : @"Pull";
  NSString *instruction = [NSString stringWithFormat:@"%@ to\n Show %@", verb, willLaunchTitle];
  
  v.instructionLabel.text = instruction;
  v.instructionLabel.alpha = self.shouldActivateBeyondBoundaryTrigger ? 1. : 0.6;

  if ([controller respondsToSelector:@selector(iconNameForDragReleaseDestination)])
  {
    NSString *iconName = [NSString stringWithFormat:@"generated/%@", controller.iconNameForDragReleaseDestination];
    UIImage *icon = [UIImage skinImageNamed:iconName withColor:[UIColor colorForHighlightedOptions]];
    v.iconView.image = icon;
    v.iconView.frame = CGRectIntegral(v.iconView.frame);
    v.iconView.alpha = JM_RANGE(0., 1., boundaryOffset / 48.);
    v.highlightView.hidden = !self.shouldActivateBeyondBoundaryTrigger;
  }
}

- (void)didReleaseBeyondRightBoundaryTrigger;
{
  if (![self.viewControllers.last conformsToProtocol:@protocol(SlidingDragReleaseProtocol)])
    return;
  
  UIViewController <SlidingDragReleaseProtocol>* controller = self.viewControllers.last;
  if (!controller.canDragRelease)
    return;
  
  [controller performSelector:@selector(didDragRelease) withObject:nil afterDelay:0.2];
}

- (void)userDidBeginSlidingController;
{
  [super userDidBeginSlidingController];
  if ([Resources useActionMenu] && ![UIApplication sharedApplication].statusBarHidden)
  {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
  }
}

- (void)userDidFinishSlidingController;
{
  [super userDidFinishSlidingController];
  
  JMOutlineViewController *controller = JMCastOrNil(self.topViewController, JMOutlineViewController);
  ABCustomOutlineNavigationBar *navbar = (ABCustomOutlineNavigationBar *)controller.attachedCustomNavigationBar;
  BOOL shouldShowStatusBarAfterRelease = navbar.height > navbar.minimumBarHeight || !navbar.hidesStatusBarOnCompact;
  if ([Resources useActionMenu] && shouldShowStatusBarAfterRelease)
  {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
  }
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
{
  self.i_isStatusBarHiddenBeforeModalPresentation = JMIsStatusBarHidden();
  [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
{
  JMAnimateStatusBarHidden(self.i_isStatusBarHiddenBeforeModalPresentation && [Resources useActionMenu]);
  [super dismissViewControllerAnimated:flag completion:completion];
}

@end
