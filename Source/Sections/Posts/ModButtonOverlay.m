#import "ModButtonOverlay.h"
#import "Resources.h"

@interface ModButtonOverlay()
@property (strong) UIColor *indicatorColor;
//@property (strong) UIColor *modLabelColor;
@property BOOL i_drawAsIndicatorOnly;
@end

@implementation ModButtonOverlay

+ (UIColor *)indicatorColorForModState:(ModerationState)modState;
{
  switch (modState) {
    case ModerationStateApproved: return [UIColor colorWithHex:0x14a006]; break;
    case ModerationStatePending: return [UIColor colorForBackgroundAlt]; break;
    case ModerationStateReported: return [UIColor colorWithHex:0xd89223]; break;
    case ModerationStateRemoved: return [UIColor colorWithHex:0xda0000]; break;
    default:
      return nil;
      break;
  }
}

- (void)updateWithVotableElement:(VotableElement *)votableElement;
{
  self.hidden = !votableElement.isModdable;
  
  if (self.hidden)
    return;
  
  self.indicatorColor = [[self class] indicatorColorForModState:votableElement.moderationState];
  [self setNeedsDisplay];
}

- (id)initAsIndicatorOnly;
{
  self = [super initWithFrame:CGRectMake(0., 0., 9., 9.)];
  if (self)
  {
    self.i_drawAsIndicatorOnly = YES;
  }
  return self;
}

- (id)initAsButton;
{
  self = [super initWithFrame:CGRectMake(0., 0., 68., 32.)];
  if (self)
  {
    self.allowTouchPassthrough = NO;
  }
  return self;
}

- (void)drawAsTinyCircle;
{
  
  CGSize dOffset = CGSizeZero;
  UIColor *indicatorColor = (self.indicatorColor) ? self.indicatorColor : [UIColor colorForBackground];
  CGRect indicatorRect = CGRectOffset(CGRectMake(1., 1., 7., 7.), dOffset.width, dOffset.height);
  [[self class] drawModLightIndicatorWithColor:indicatorColor inRect:indicatorRect];
}

- (void)drawAsTriangle;
{
  UIBezierPath *path = [UIBezierPath bezierPath];
  
  CGSize b = CGSizeMake(28., 28.);
  [path moveToPoint:CGPointMake(0., b.height)];
  [path addLineToPoint:CGPointMake(b.width, b.height)];
  [path addLineToPoint:CGPointMake(b.width, 0.)];
  [path closePath];
  
  [path applyTransform:CGAffineTransformMakeTranslation(7., 7.)];
  
  UIColor *bgColor = (self.indicatorColor) ? self.indicatorColor : [UIColor colorForBackground];
  [bgColor set];
  [path fill];
  
  [[UIColor colorWithWhite:0. alpha:0.03] set];
  [path fill];
  
  [[UIColor colorWithWhite:0. alpha:0.08] set];
  [path stroke];
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  CGContextRotateCTM(ctx, -M_PI_4);
  CGContextTranslateCTM(ctx, -6, 33);
  
  if (!self.indicatorColor)
  {
    [[UIColor colorWithWhite:0.5 alpha:0.5] set];
    [UIView startEtchedDropShadowDraw];
    [@"MOD" drawAtPoint:CGPointMake(0., 0.) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:5.5]];
    [UIView endEtchedDropShadowDraw];
  }
  else
  {
    [[UIColor whiteColor] set];
    [@"MOD" drawAtPoint:CGPointMake(0., 0.) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:5.5]];
  }
  
  CGContextRestoreGState(ctx);
  
  
//  [self.indicatorColor set];
//  [[UIColor purpleColor] set];
//
//  CGRect iRect = CGRectMake(1., 1., 30., 30.);
//  UIBezierPath *iPath = [UIBezierPath bezierPath];
//
//  [iPath moveToPoint:CGPointMake(iRect.origin.x, iRect.origin.y + iRect.size.height)];
//  [iPath addLineToPoint:CGPointMake(iRect.origin.x + 3, iRect.origin.y + iRect.size.height)];
//  [iPath addLineToPoint:CGPointMake(iRect.origin.x + iRect.size.width, iRect.origin.y + 3)];
//  [iPath addLineToPoint:CGPointMake(iRect.origin.x + iRect.size.width, iRect.origin.y)];
//  [iPath closePath];
//  
//  [iPath fill];
//

//  CGRect kRect = CGRectMake(25., 25., 9., 9.);
//  UIBezierPath *kPath = [UIBezierPath bezierPath];
//  [kPath moveToPoint:CGPointMake(kRect.origin.x, kRect.origin.y + kRect.size.height)];
//  [kPath addLineToPoint:CGPointMake(kRect.origin.x + kRect.size.width, kRect.origin.y + kRect.size.height)];
//  [kPath addLineToPoint:CGPointMake(kRect.origin.x + kRect.size.width, kRect.origin.y)];
//  [kPath closePath];
//  [kPath fill];
//  [[UIColor colorWithWhite:0. alpha:0.1] set];
//  [kPath stroke];
}

- (void)drawRect:(CGRect)rect;
{
  if (self.i_drawAsIndicatorOnly)
    [self drawAsTinyCircle];
  else
    [self drawAsButton];
}

+ (void)drawModLightIndicatorWithColor:(UIColor *)indicatorColor inRect:(CGRect)indicatorRect;
{
  UIBezierPath *indicatorPath = [UIBezierPath bezierPathWithOvalInRect:indicatorRect];
  
  [indicatorColor setFill];
  [indicatorPath fill];
  
  // inner shadow
  [[UIColor colorWithWhite:0. alpha:0.15] set];
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(indicatorRect, 1., 1.)];
  [shadowPath setLineWidth:1.];
  [shadowPath stroke];
  
//  [shadowPath setLineWidth:1.];
//  [shadowPath stroke];
}

- (void)drawAsButton;
{
  CGRect dBounds = CGRectInset(self.bounds, 10., 8.);
  CGSize dOffset = CGSizeMake(10., 7.);
  CGFloat bgColorWhiteLevel = [Resources isNight] ? 0.12 : 1.;
  CGFloat bgColorAlphaLevel = [Resources isNight] ? 0.1 : 1.;
  
  if (self.highlighted)
    bgColorWhiteLevel -= 0.1;
  
  [[UIColor colorWithWhite:bgColorWhiteLevel alpha:bgColorAlphaLevel] set];
  [UIView startEtchedDropShadowDraw];
  [[UIBezierPath bezierPathWithRoundedRect:dBounds cornerRadius:5.] fill];
  [UIView endEtchedDropShadowDraw];
  
  UIFont *modFont = [UIFont boldSystemFontOfSize:9.];
  UIColor *titleColor = [Resources isNight] ? [UIColor colorWithWhite:0.25 alpha:1.] : [UIColor colorWithWhite:0.7 alpha:1.];
  [titleColor set];
  [UIView startEtchedDraw];
  [@"MOD" drawAtPoint:CGPointMake(7. + dOffset.width, 4. + dOffset.height) withFont:modFont];
  [UIView endEtchedDraw];
  
  UIColor *indicatorColor = (self.indicatorColor) ? self.indicatorColor : [UIColor colorForBackground];
  CGRect indicatorRect = CGRectOffset(CGRectMake(35., 6., 7., 7.), dOffset.width, dOffset.height);
  [[self class] drawModLightIndicatorWithColor:indicatorColor inRect:indicatorRect];
}

@end
