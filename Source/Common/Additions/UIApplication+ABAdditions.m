#import "UIApplication+ABAdditions.h"
#import "Resources.h"

#define kABApplicationKeyStatusBarAccessor [NSString stringWithFormat:@"_%@%@", @"status", @"Bar"]
#define kABApplicationKeyStatusBarBGAccessor [NSString stringWithFormat:@"_%@%@", @"background", @"View"]
#define kABApplicationKeyGatedGesturePattern [NSString stringWithFormat:@"%@%@%@", @"m", @"Gesture", @"Gate"]

@implementation UIApplication (ABAdditions)

#pragma mark -
#pragma mark - Enable Top-Edge Panning

// Patch for iOS 7 supressing pan gestures near the top of the screen
+ (void)ab_enableEdgePanning;
{
  if (!JMIsIOS7())
    return;
  
  void(^GestureFilterAction)(UIView *) = ^(UIView *view){
    [view.gestureRecognizers each:^(UIGestureRecognizer *gesture) {
      if ([NSStringFromClass(gesture.class) jm_contains:kABApplicationKeyGatedGesturePattern])
      {
        gesture.enabled = NO;
        [view removeGestureRecognizer:gesture];
      }
    }];
  };
  
  NSArray *windows = [UIApplication sharedApplication].windows;
  [windows each:^(UIView *view) {
    GestureFilterAction(view);
  }];
}

#pragma mark -
#pragma mark - Status Bar Manipulation (Deprecated)

+ (void)ab_updateStatusBarTint_iPad
{
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
  
  if (JMIsIOS7())
  {
    CGFloat barAlpha = 0.65;
    UIColor *statusBGPattern = [[UIColor tiledPatternForBackground] colorWithAlphaComponent:barAlpha];
    if (JMIsNight())
    {
      statusBGPattern = [UIColor blackColor];
    }
    [UIApplication ab_setStatusBarTintColor:statusBGPattern];
  }
}

+ (void)ab_updateStatusBarTint_iPhone
{
  if (!JMIsIOS7())
  {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    return;
  }
  
  UIStatusBarStyle barStyle = [Resources isNight] ? UIStatusBarStyleBlackOpaque : UIStatusBarStyleDefault;
  UIColor *statusBarTintColor = [UIColor colorForNavigationBar];
  
  if ([UDefaults boolForKey:kABSettingKeyLowContrastMode])
  {
    statusBarTintColor = [statusBarTintColor jm_darkenedWithStrength:0.35];
  }
  
  [[UIApplication sharedApplication] setStatusBarStyle:barStyle];
  [UIApplication ab_setStatusBarTintColor:statusBarTintColor];
}

+ (void)ab_updateStatusBarTint;
{
  if (JMIsIpad())
  {
    [self ab_updateStatusBarTint_iPad];
  }
  else
  {
    [self ab_updateStatusBarTint_iPhone];
  }
}

+ (void)ab_setStatusBarTintColor:(UIColor *)tintColor;
{
  if ([Resources useActionMenu])
    return;
  
  [self deprecated_AB_setStatusBarTintColor:tintColor];
}

+ (void)deprecated_AB_setStatusBarTintColor:(UIColor *)tintColor;
{
  UIView *statusBar = [[UIApplication sharedApplication] valueForKey:kABApplicationKeyStatusBarAccessor];
  if (!statusBar)
    return;
  
  UIView *statusBarBG = [statusBar valueForKey:kABApplicationKeyStatusBarBGAccessor];
  if (!statusBarBG)
    return;
  
  statusBarBG.backgroundColor = tintColor;
}

+ (void)ab_updateStatusBarTintWithTransition;
{
  UIView *statusBar = [[UIApplication sharedApplication] valueForKey:kABApplicationKeyStatusBarAccessor];
  if (!statusBar)
    return;
  
  UIView *statusBarBG = [statusBar valueForKey:kABApplicationKeyStatusBarBGAccessor];
  if (!statusBarBG)
    return;
  
  [UIView jm_animate:^{
    statusBarBG.alpha = 0.;
  } completion:^{
    [UIApplication ab_updateStatusBarTint];
    [UIView jm_animate:^{
      statusBarBG.alpha = 1.;
    } completion:nil];
  } animated:YES];
}

@end
