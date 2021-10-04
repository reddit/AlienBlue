//
//  ABNavigationController.m
//  AlienBlue
//
//  Created by JM on 29/12/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "ABNavigationController.h"
#import "UIView+Additions.h"
#import "CustomNavigationBar.h"
#import "UIView+Decorators.h"
#import "ViewDecorators.h"
#import "ABNavigationBar.h"
#import "ABToolbar.h"
#import "Resources.h"
#import "UINavigationController+ABAdditions.h"

#import "GenericNavigationBar.h"
#import "JMOutlineViewController+CustomNavigationBar.h"

@interface ABNavigationController()
@property BOOL i_isStatusBarHiddenBeforeModalPresentation;
@property BOOL i_isStatusBarHiddenBeforeControllerPush;
@end

@implementation ABNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController;
{
  JM_SUPER_INIT(initWithRootViewController:rootViewController);
  [self attachGenericCustomNavigationBarIfNecessaryToViewController:rootViewController];
  return self;
}

- (void)loadView;
{
  [super loadView];
  self.view.backgroundColor = [UIColor colorForBackground];
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
  return NO;
}

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

- (void)attachGenericCustomNavigationBarIfNecessaryToViewController:(UIViewController *)viewController;
{
  JMOutlineViewController *controller = JMCastOrNil(viewController, JMOutlineViewController);
  if (controller && controller.attachedCustomNavigationBar == nil)
  {
    GenericNavigationBar *navigationBar = [GenericNavigationBar new];
    [controller attachCustomNavigationBarView:navigationBar];
    self.navigationBarHidden = YES;
    [navigationBar setTitleLabelText:controller.title];
  }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
  self.i_isStatusBarHiddenBeforeControllerPush = JMIsStatusBarHidden();
  [self attachGenericCustomNavigationBarIfNecessaryToViewController:viewController];
  [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
{
  JMAnimateStatusBarHidden(self.i_isStatusBarHiddenBeforeControllerPush);
  return [super popViewControllerAnimated:animated];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
{
  self.i_isStatusBarHiddenBeforeModalPresentation = JMIsStatusBarHidden();
  [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
{
  JMAnimateStatusBarHidden(self.i_isStatusBarHiddenBeforeModalPresentation);
  [super dismissViewControllerAnimated:flag completion:completion];
}


@end
