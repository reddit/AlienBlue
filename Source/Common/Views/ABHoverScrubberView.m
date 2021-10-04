#import "ABHoverScrubberView.h"

@interface ABHoverScrubberView()
@property CGFloat startingTouchXOffset;
@property CGFloat touchXOffset;
@property (strong) UIImageView *iconView;
@property (copy) NSString *instructionText;
@end

@implementation ABHoverScrubberView

- (instancetype)initWithFrame:(CGRect)frame
{
  JM_SUPER_INIT(initWithFrame:frame);
  self.backgroundColor = [UIColor clearColor];
  self.iconView = [[UIImageView alloc] initWithSize:CGSizeMake(30., 30.)];
  self.iconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  [self addSubview:self.iconView];
  self.clipsToBounds = NO;
  self.iconView.right = self.bounds.size.width;
  self.iconView.top = 0.;
  return self;
}

- (void)updateWithCurrentTouchCenterXOffset:(CGFloat)touchXOffset;
{
  self.touchXOffset = touchXOffset;
  [self setNeedsDisplay];
}

- (void)setStartingTouchCenterXOffset:(CGFloat)startingTouchXOffset;
{
  self.startingTouchXOffset = startingTouchXOffset;
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect;
{
  CGFloat arrowNudgeOffset = -2.;
  CGFloat marginFromEnd = 20.;
  
  CGFloat startOffset = self.startingTouchXOffset + arrowNudgeOffset;
  CGFloat endOffset = self.bounds.size.width - marginFromEnd;
  CGFloat distanceToEnd = endOffset - startOffset;
  
  CGFloat dotSpacing = 10.;
  CGFloat dotWidth = 3.;
  NSUInteger numberOfDots = floorf(distanceToEnd / (dotSpacing));

  CGFloat currentXDrawOffset = (startOffset - dotWidth / 2.);

  UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(currentXDrawOffset, 13., dotWidth, dotWidth)];
  [[UIColor grayColor] setFill];
  
  for (NSUInteger i=0; i<numberOfDots; i++)
  {
    [dotPath fill];
    [dotPath applyTransform:CGAffineTransformMakeTranslation(dotSpacing, 0.)];
  }
}

- (void)updateIconForEndPoint:(UIImage *)iconForEndPoint;
{
  self.iconView.image = iconForEndPoint;
}

@end
