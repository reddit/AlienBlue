#import "TiltManager.h"
#import "NavigationManager.h"
#import "BrowserViewController.h"

@interface TiltManager() <UIAccelerometerDelegate>
@property CGFloat tiltCalibrationOffset;
@property BOOL isCalibratingTilt;
@end

@implementation TiltManager

+ (TiltManager *)shared
{
  JM_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

- (void)startMonitoringAccelerometer;
{
  self.tiltCalibrationOffset = 0;
  self.isCalibratingTilt = NO;
  UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
  [accel setDelegate:self];
  [accel setUpdateInterval:1.0f / 60.0f];
}

- (void)activateTiltCalibrationMode
{
  self.isCalibratingTilt = YES;
}

- (void)tiltScrollViewControllerWithSpeed:(CGFloat)speed
{
  UIScrollView * scrollview;
  JMOutlineViewController *visibleController = JMCastOrNil([NavigationManager shared].postsNavigation.visibleViewController, JMOutlineViewController);
  BOOL isViewingBrowser = JMIsClass(visibleController, BrowserViewController);
  BOOL hasScrollableTableView = [visibleController respondsToSelector:@selector(tableView)];
  
  if (!isViewingBrowser && hasScrollableTableView)
  {
    scrollview = visibleController.tableView;
    CGPoint contentOffset = [scrollview contentOffset];
    contentOffset.y = contentOffset.y + speed;
    BOOL alreadyAtBoundaries = (contentOffset.y < -30 && speed < 0) || (contentOffset.y > [scrollview contentSize].height - scrollview.bounds.size.height && speed > 0);
    if (!alreadyAtBoundaries)
    {
      [scrollview setContentOffset:contentOffset animated:NO];
    }
  }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
  if (![UDefaults boolForKey:kABSettingKeyAllowTiltScroll])
    return;
  
  if (self.isCalibratingTilt)
  {
    self.tiltCalibrationOffset = acceleration.z;
    self.isCalibratingTilt = NO;
    return;
  }
  
  CGFloat tiltThreshold = 0.1f;
  CGFloat tiltScrollRatio = 9.0f;
  CGFloat maxAcceleration = 0.6f;
  
  CGFloat verticalAcceleration;
  if (acceleration.z > 0)
  {
    verticalAcceleration = acceleration.z - self.tiltCalibrationOffset;
    if (verticalAcceleration > maxAcceleration) verticalAcceleration = maxAcceleration;
  }
  else
  {
    verticalAcceleration = acceleration.z - self.tiltCalibrationOffset;
    if (verticalAcceleration < (-1 * maxAcceleration)) verticalAcceleration = -1 * maxAcceleration;
  }
  
  if (fabs(acceleration.z - self.tiltCalibrationOffset) > tiltThreshold)
  {
    CGFloat direction = -1;
    if ([UDefaults boolForKey:kABSettingKeyTiltScrollReverseAxis])
      direction = 1;
    CGFloat speed = direction * tiltScrollRatio * (verticalAcceleration);
    
    [self tiltScrollViewControllerWithSpeed:speed];
  }
}


@end
