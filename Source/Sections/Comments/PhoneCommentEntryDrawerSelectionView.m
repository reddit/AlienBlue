#import "PhoneCommentEntryDrawerSelectionView.h"

@implementation PhoneCommentEntryDrawerSelectionView

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
  CGRect bounds = CGRectInset(self.bounds, 2., 2.);
  CGFloat radius = 0.5f * CGRectGetHeight(bounds);
  UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];
  [[UIColor colorWithWhite:1. alpha:0.2] set];
  [path setLineWidth:1.];
  [path stroke];
}

@end
