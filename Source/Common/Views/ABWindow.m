#import "ABWindow.h"

@interface ABWindow()
@property (strong) UIView *dimView;
@end

@implementation ABWindow

- (void)sendEvent:(UIEvent *)event;
{
  [super sendEvent:event];
  if (self.customEventHandlerAction)
  {
    self.customEventHandlerAction(event);
  }
}

#pragma mark -
#pragma mark - Screen Dimming

+ (void)dimToAlpha:(CGFloat)alpha;
{
  ABWindow *window = JMCastOrNil([UIApplication sharedApplication].keyWindow, ABWindow);
  [window i_dimToAlpha:alpha];
}

+ (void)removeDim;
{
  ABWindow *window = JMCastOrNil([UIApplication sharedApplication].keyWindow, ABWindow);
  [window i_removeDim];
}

+ (void)bringDimmingOverlayToFrontIfNecessary;
{
  ABWindow *window = JMCastOrNil([UIApplication sharedApplication].keyWindow, ABWindow);
  [window i_bringDimToFront];
}

- (void)i_removeDim;
{
  if (self.dimView)
  {
    [self.dimView removeFromSuperview];
    self.dimView = nil;
  }
}

- (void)i_dimToAlpha:(CGFloat)alpha;
{
  if (!self.dimView)
  {
    self.dimView = [[UIView alloc] initWithFrame:self.bounds];
    self.dimView.backgroundColor = [UIColor blackColor];
    self.dimView.userInteractionEnabled = NO;
    self.dimView.autoresizingMask = JMFlexibleSizeMask;
    [self addSubview:self.dimView];
  }
  self.dimView.alpha = alpha;
}

- (void)i_bringDimToFront;
{
  if (self.dimView)
  {
    [self bringSubviewToFront:self.dimView];
  }
}

- (void)makeKeyAndVisible;
{
  [super makeKeyAndVisible];
  
  // this is a temporary patch to work against a rotation issue
  // on iOS 8 + iPhone combo that causes the window to (very rarely)
  // not scale correctly
  // todo: need to revisit this patch after the next iOS update
  // to see if it is still required
  // http://stackoverflow.com/a/26040354
  self.window.frame = [UIScreen mainScreen].bounds;
}

@end
