#import "TemplateSendModeSwitchView.h"

@interface TemplateSendModeSwitchView()
@property (strong) UIImageView *trackView;
@property (strong) UIImageView *leftIconView;
@property (strong) UIImageView *rightIconView;
@property BOOL i_switchOn;
@end

@implementation TemplateSendModeSwitchView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 108., 40.)];
  if (self)
  {
    self.trackView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.trackView];
        
    [self addTarget:self action:@selector(didToggle) forControlEvents:UIControlEventTouchUpInside];

    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipeGesture];
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipeGesture];
    
    self.leftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(3., 4., 30., 30.)];
    self.leftIconView.frame = CGRectInset(self.leftIconView.frame, 2., 2.);
//    self.leftIconView.backgroundColor = [UIColor purpleColor];
    [self addSubview:self.leftIconView];
    
    self.rightIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 4., 30., 30.)];
    self.rightIconView.frame = CGRectInset(self.rightIconView.frame, 3., 3.);
//    self.rightIconView.backgroundColor = [UIColor purpleColor];
    self.rightIconView.right = self.bounds.size.width - 4.;
    [self addSubview:self.rightIconView];
    
    [self setSwitchOn:NO animated:NO notifyDelegate:NO];
  }
  return self;
}

- (void)setDefaultSendSwitchPreference:(TemplateSendPreference)sendPref;
{
  [self setSwitchOn:(sendPref == TemplateSendPreferenceComment) animated:NO notifyDelegate:NO];
}

- (void)setSwitchOn:(BOOL)switchOn animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate;
{
  if (self.i_switchOn == switchOn && self.trackView.image)
    return;
  
  self.i_switchOn = switchOn;
  UIColor *activeColor = (switchOn) ? [UIColor colorWithHex:0xad49e1] : [UIColor colorWithHex:0x009cff];
//  UIColor *activeColor = (switchOn) ? [UIColor grayColor] : [UIColor lightGrayColor];
  
  self.trackView.image = [[self class] imageForTrackViewActiveColor:[UIColor colorWithHex:0x555555] switchOn:switchOn];
  
  UIColor *inactiveColor = [UIColor lightGrayColor];
  UIColor *leftIconColor = (switchOn) ? inactiveColor : activeColor;
  UIColor *rightIconColor = (!switchOn) ? inactiveColor : activeColor;
  self.leftIconView.image = [UIImage skinEtchedIcon:@"inbox-icon" withColor:leftIconColor];
  self.rightIconView.image = [UIImage skinEtchedIcon:@"comments-icon" withColor:rightIconColor];
  
  if (notifyDelegate && self.onSendSwitchChange)
  {
    TemplateSendPreference pref = switchOn ? TemplateSendPreferenceComment : TemplateSendPreferencePersonalMessage;
    self.onSendSwitchChange(pref);
  }
}

- (void)didToggle;
{
  [self setSwitchOn:!self.i_switchOn animated:YES notifyDelegate:YES];
}

- (void)didSwipeRight:(UISwipeGestureRecognizer *)swipeGesture;
{
  if (swipeGesture.state == UIGestureRecognizerStateRecognized)
  {
    [self setSwitchOn:YES animated:YES notifyDelegate:YES];
  }
  
}

- (void)didSwipeLeft:(UISwipeGestureRecognizer *)swipeGesture;
{
  if (swipeGesture.state == UIGestureRecognizerStateRecognized)
  {
    [self setSwitchOn:NO animated:YES notifyDelegate:YES];
  }
}

+ (UIImage *)imageForTrackViewActiveColor:(UIColor *)activeColor switchOn:(BOOL)switchOn;
{
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    //// General Declarations
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* gradientColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0];
    UIColor* gradientColor2 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.47];
    UIColor* shadowColor2 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.29];
    UIColor* shadow2Color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.51];
    
    CGFloat activeColorHSBA[4];
    [activeColor getHue: &activeColorHSBA[0] saturation: &activeColorHSBA[1] brightness: &activeColorHSBA[2] alpha: &activeColorHSBA[3]];
    
    UIColor* buttonGradientColorStart = [UIColor colorWithHue: activeColorHSBA[0] saturation: activeColorHSBA[1] brightness: 0.9 alpha: activeColorHSBA[3]];
    UIColor* buttonGradientColorEnd = [UIColor colorWithHue: activeColorHSBA[0] saturation: activeColorHSBA[1] brightness: 0.6 alpha: activeColorHSBA[3]];
    UIColor* color3 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.25];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)gradientColor2.CGColor,
                               (id)gradientColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    NSArray* buttonGradientColors = [NSArray arrayWithObjects:
                                     (id)buttonGradientColorStart.CGColor,
                                     (id)buttonGradientColorEnd.CGColor, nil];
    CGFloat buttonGradientLocations[] = {0, 1};
    CGGradientRef buttonGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonGradientColors, buttonGradientLocations);
    
    //// Shadow Declarations
    UIColor* shadow2 = shadow2Color;
    CGSize shadow2Offset = CGSizeMake(0.1, -1.1);
    CGFloat shadow2BlurRadius = 0;
    UIColor* shadow3 = shadowColor2;
    CGSize shadow3Offset = CGSizeMake(0.1, 1.1);
    CGFloat shadow3BlurRadius = 0.5;
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, 108, 40);
    
    
    //// Group
    {
      //// Rounded Rectangle Drawing
      CGRect roundedRectangleRect = CGRectMake(CGRectGetMinX(frame) + 37.5, CGRectGetMinY(frame) + 16, 35, 9);
      UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect cornerRadius: 4];
      CGContextSaveGState(context);
      [roundedRectanglePath addClip];
      CGContextDrawLinearGradient(context, gradient,
                                  CGPointMake(CGRectGetMidX(roundedRectangleRect) + 0 * CGRectGetWidth(roundedRectangleRect) / 35, CGRectGetMidY(roundedRectangleRect) + -4 * CGRectGetHeight(roundedRectangleRect) / 8),
                                  CGPointMake(CGRectGetMidX(roundedRectangleRect) + 0 * CGRectGetWidth(roundedRectangleRect) / 35, CGRectGetMidY(roundedRectangleRect) + 4 * CGRectGetHeight(roundedRectangleRect) / 8),
                                  kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
      CGContextRestoreGState(context);
      
      ////// Rounded Rectangle Inner Shadow
      CGRect roundedRectangleBorderRect = CGRectInset([roundedRectanglePath bounds], -shadow2BlurRadius, -shadow2BlurRadius);
      roundedRectangleBorderRect = CGRectOffset(roundedRectangleBorderRect, -shadow2Offset.width, -shadow2Offset.height);
      roundedRectangleBorderRect = CGRectInset(CGRectUnion(roundedRectangleBorderRect, [roundedRectanglePath bounds]), -1, -1);
      
      UIBezierPath* roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect: roundedRectangleBorderRect];
      [roundedRectangleNegativePath appendPath: roundedRectanglePath];
      roundedRectangleNegativePath.usesEvenOddFillRule = YES;
      
      CGContextSaveGState(context);
      {
        CGFloat xOffset = shadow2Offset.width + round(roundedRectangleBorderRect.size.width);
        CGFloat yOffset = shadow2Offset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadow2BlurRadius,
                                    shadow2.CGColor);
        
        [roundedRectanglePath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(roundedRectangleBorderRect.size.width), 0);
        [roundedRectangleNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [roundedRectangleNegativePath fill];
      }
      CGContextRestoreGState(context);
      
      
      
      //// Oval Drawing
      CGRect ovalRect = CGRectMake(CGRectGetMinX(frame) + 34, CGRectGetMinY(frame) + 13, 14, 14);
      if (switchOn)
      {
        ovalRect = CGRectOffset(ovalRect, 27., 0.);
      }
      ovalRect = CGRectInset(ovalRect, 1., 1.);
      UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: ovalRect];
      CGContextSaveGState(context);
      CGContextSetShadowWithColor(context, shadow3Offset, shadow3BlurRadius, shadow3.CGColor);
      CGContextBeginTransparencyLayer(context, NULL);
      [ovalPath addClip];
      CGFloat ovalResizeRatio = MIN(CGRectGetWidth(ovalRect) / 14, CGRectGetHeight(ovalRect) / 14);
      CGContextDrawRadialGradient(context, buttonGradient,
                                  CGPointMake(CGRectGetMidX(ovalRect) + 0 * ovalResizeRatio, CGRectGetMidY(ovalRect) + -0 * ovalResizeRatio), 4.41 * ovalResizeRatio,
                                  CGPointMake(CGRectGetMidX(ovalRect) + 0 * ovalResizeRatio, CGRectGetMidY(ovalRect) + -0 * ovalResizeRatio), 9.03 * ovalResizeRatio,
                                  kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
      CGContextEndTransparencyLayer(context);
      CGContextRestoreGState(context);
      
      [color3 setStroke];
      ovalPath.lineWidth = 1;
      [ovalPath stroke];
    }
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGGradientRelease(buttonGradient);
    CGColorSpaceRelease(colorSpace);
    
  } withSize:CGSizeMake(108., 40.)];
}

@end
