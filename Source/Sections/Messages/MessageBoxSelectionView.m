#import "MessageBoxSelectionView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MessageBoxSelectionView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self)
  {
    self.layer.shadowOpacity = 0.;
  }
  return self;
}

- (void)layoutSubviews;
{
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  CGRect selectionRect = CGRectInset(self.bounds, 11., 4.);
  selectionRect = CGRectOffset(selectionRect, 0., -1.);
  [[UIColor colorForTint] set];
  [[UIBezierPath bezierPathWithRect:CGRectCropToBottom(selectionRect, 1.)] fill];
}


@end
