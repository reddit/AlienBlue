#import "ABHoverLoadingIndicatorView.h"
#import "Resources.h"

@interface ABHoverLoadingIndicatorView()
@property CGFloat progressRatio;
@end

@implementation ABHoverLoadingIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
  JM_SUPER_INIT(initWithFrame:frame);
  self.size = CGSizeMake(70., 70.);
  self.backgroundColor = [UIColor clearColor];
  return self;
}

- (void)updateWithProgressRatio:(CGFloat)progressRatio;
{
  if (progressRatio > 0 && progressRatio < self.progressRatio)
    return;
  
  self.progressRatio = progressRatio;
  [self setNeedsDisplay];
}

- (UIBezierPath *)generateArcPathToRatio:(CGFloat)ratio lineThickness:(CGFloat)lineThickness;
{
  CGRect loadingRingRect = CGRectInset(self.bounds, 2., 2.);
  CGRect arcRect = CGRectInset(loadingRingRect, 6., 6. );
  
  UIBezierPath *arcPath = [UIBezierPath bezierPath];
  
  CGFloat midX = CGRectGetMidX(arcRect);
  CGFloat midY = CGRectGetMidY(arcRect);
  CGFloat radius = arcRect.size.width / 2.;
  CGFloat anglePaddingRatio = 0.25;
  CGFloat startAngle = (1. + (1. - anglePaddingRatio)) * M_PI;
  CGFloat endAngle = (1. + anglePaddingRatio) * M_PI;
  CGFloat progressStartAngle = endAngle - (endAngle - startAngle) * ratio;
  
  [arcPath addArcWithCenter:CGPointMake(midX, midY) radius:radius startAngle:progressStartAngle endAngle:endAngle clockwise:NO];
  arcPath.lineWidth = lineThickness;
  arcPath.lineCapStyle = kCGLineCapRound;
  
  return arcPath;
}


- (void)drawRect:(CGRect)rect;
{
  UIBezierPath *bgPath = [self generateArcPathToRatio:1. lineThickness:12.];
  [[UIColor colorWithWhite:1. alpha:0.6] setStroke];
  [bgPath stroke];
  
  [bgPath addLineToPoint:CGPointCenterOfRect(self.bounds)];
  [bgPath closePath];
  [[UIColor colorWithWhite:1. alpha:0.6] setFill];
  [bgPath setLineCapStyle:kCGLineCapRound];
  [bgPath fill];
  
  UIBezierPath *trackPath = [self generateArcPathToRatio:1. lineThickness:9.];
  [[UIColor colorWithWhite:0.6 alpha:0.4] setStroke];
  [trackPath stroke];
  
  CGFloat isIndeterminate = self.progressRatio < 0.;
  CGFloat ratioToDraw = isIndeterminate ? 1. : self.progressRatio;
  UIColor *barColor = isIndeterminate ? JMHexColor(df4192) : [UIColor colorForHighlightedOptions];
  if (self.progressRatio == kABHoverLoadingIndicatorViewProgressRatioForError)
  {
    barColor = [UIColor skinColorForDestructive];
  }

  UIBezierPath *progressPath = [self generateArcPathToRatio:ratioToDraw lineThickness:6.];
  [barColor setStroke];
  
  [UIView jm_drawShadowed:^{
    [progressPath stroke];
  } shadowOpacity:0.1];
  
  UIImage *barPatternImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGFloat barWidth = 1.;
    CGFloat barSpacing = 2.;
    NSUInteger numberOfBars = ceilf(bounds.size.width / (barWidth + barSpacing));
    UIBezierPath *barPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., barWidth, bounds.size.height)];
    [[UIColor colorWithWhite:1. alpha:0.2] setFill];
    for (NSUInteger i=0; i<numberOfBars; i++)
    {
      [barPath fill];
      [barPath applyTransform:CGAffineTransformMakeTranslation(barSpacing + barWidth, 0.)];
    }
  } opaque:NO withSize:CGSizeMake(12., 10.) cacheKey:@"ab-hover-indicator-bar-pattern"];
  
  CGFloat phaseForBarPattern = (200. - self.animationStep / 6.);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetPatternPhase(context, CGSizeMake(phaseForBarPattern, 0.));
  UIColor *patternColor = [UIColor colorWithPatternImage:barPatternImage];
  [patternColor setStroke];
  [progressPath stroke];
}

@end
