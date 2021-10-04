#import "JMAnimatedSlideIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@interface JMAnimatedSlideIndicatorView()
@property CGFloat lightOffset;
@property BOOL _isAnimating;

@property (strong) UIImageView *leftTab;
@property (strong) UIImageView *rightTab;
@property (strong) UILabel *instructionLabel;
@end

@implementation JMAnimatedSlideIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor colorWithWhite:0. alpha:0.85];
      
      self.leftTab = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., 26., self.bounds.size.height)];
      self.leftTab.autoresizingMask = UIViewAutoresizingFlexibleHeight;
      self.leftTab.left = 0.;
      [self addSubview:self.leftTab];
      
      self.rightTab = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., 26., self.bounds.size.height)];
      self.rightTab.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
      self.rightTab.right = self.bounds.size.width + 0.;
      [self addSubview:self.rightTab];
      
      self.leftTab.backgroundColor = [[self class] patternColorImageForTabBackground];
      self.leftTab.image = [[self class] imageForGripArea];
      self.leftTab.contentMode = UIViewContentModeCenter;

      self.rightTab.backgroundColor = [[self class] patternColorImageForTabBackground];
      self.rightTab.image = [[self class] imageForGripArea];
      self.rightTab.contentMode = UIViewContentModeCenter;

      self.instructionLabel = [UILabel new];
      self.instructionLabel.text = @"Drag from the edges of your screen to more comfortably navigate back and forward";
      self.instructionLabel.textColor = [UIColor whiteColor];
      self.instructionLabel.shadowColor = [UIColor blackColor];
      self.instructionLabel.shadowOffset = CGSizeMake(0., 2.);
      self.instructionLabel.font = [UIFont skinFontWithName:kBundleFontTipBody];
      self.instructionLabel.numberOfLines = 3;
      self.instructionLabel.width = 225.;
      self.instructionLabel.height = 100.;
      self.instructionLabel.textAlignment = NSTextAlignmentCenter;
      self.instructionLabel.contentMode = UIViewContentModeCenter;
      [self addSubview:self.instructionLabel];
      [self.instructionLabel centerInSuperView];
      self.instructionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
      self.instructionLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (UIColor *)patternColorImageForTabBackground;
{
  UIImage *image = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    UIColor *paneColor = [UIColor colorWithHex:0x00bcff];
    [paneColor set];
    [[UIBezierPath bezierPathWithRect:bounds] fill];
    
    // draw thin stripes for texture
    [[UIColor colorWithWhite:0. alpha:0.2] set];
    UIBezierPath *thinLine = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., 50., 1.)];
    [thinLine applyTransform:CGAffineTransformMakeRotation(M_PI_4)];
    [thinLine applyTransform:CGAffineTransformMakeTranslation(0., -30)];
    
    for (int i=0; i<50; i++)
    {
      [thinLine applyTransform:CGAffineTransformMakeTranslation(0., 3.)];
      [thinLine stroke];
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextRotateCTM(ctx, -M_PI_2);
    [UIView drawGradientInRect:CGRectMake(0., 0., 5., 3.) minHeight:0. startColor:[UIColor colorWithWhite:0. alpha:0.3] endColor:[UIColor clearColor]];
    CGContextTranslateCTM(ctx, 0, 23.);
    [UIView drawGradientInRect:CGRectMake(0., 0., 5., 3.) minHeight:0. startColor:[UIColor clearColor] endColor:[UIColor colorWithWhite:0. alpha:0.3]];

  } opaque:NO withSize:CGSizeMake(30., 60.) cacheKey:@"slide-train-tab-bg"];
  return [UIColor colorWithPatternImage:image];
}

+ (UIImage *)imageForGripArea;
{
  UIImage *image = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    [UIView startEtchedInnerShadowDraw];

    [[UIColor whiteColor] set];
    UIBezierPath *gripDot = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2., 0., 2., 2.)];

    for (int j=0; j<2; j++)
    {
      for (int i=0; i<20; i++)
      {
        [gripDot applyTransform:CGAffineTransformMakeTranslation(0., 5.)];
        [gripDot fill];
      }
      [gripDot applyTransform:CGAffineTransformMakeTranslation(0., -100.)];
      [gripDot applyTransform:CGAffineTransformMakeTranslation(7., 0.)];
    }
    
    [UIView endEtchedInnerShadowDraw];
  } opaque:NO withSize:CGSizeMake(13., 104.) cacheKey:@"slide-train-tab-grip"];
  return image;
}

@end
