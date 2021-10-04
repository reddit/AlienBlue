#import "ModerationSupportedTableDrawerView.h"
#import "PostModerationControlView.h"
#import "JMOutlineCell.h"

#define kOptionsDrawerLastShowedModPrefKey @"kOptionsDrawerLastShowedModPrefKey"

@interface ModerationSupportedTableDrawerView()
@property (strong) PostModerationControlView *modControlView;
@property (readonly) VotableElement *modableElement;
@end

@implementation ModerationSupportedTableDrawerView

- (VotableElement *)modableElement;
{
  // setup appropriate accessors in subclasses
  return nil;
}

- (void)addModButtons;
{
  self.modControlView = [[PostModerationControlView alloc] initWithFrame:self.bounds];
  [self addSubview:self.modControlView];
  self.modControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.modControlView updateWithPost:(Post *)self.modableElement];
  BSELF(ModerationSupportedTableDrawerView);
  self.modControlView.onCancelTap = ^{
    [UDefaults setBool:NO forKey:kOptionsDrawerLastShowedModPrefKey];
    [blockSelf exitModModeAnimated:YES];
  };
  self.modControlView.onModerationStateChange = ^{
    [(JMOutlineNode *)blockSelf.node refresh];
  };
  self.modControlView.top += 1.;
}

- (void)enterModModeAnimated:(BOOL)animated;
{
  BSELF(ModerationSupportedTableDrawerView);
  
  [self addModButtons];
  self.modControlView.alpha = 1.;
  [UIView jm_transition:self options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
    [[blockSelf subviewsOfClass:[ABButton class]] each:^(ABButton *button) {
      button.hidden = YES;
    }];
  } completion:nil animated:animated];
}

- (void)exitModModeAnimated:(BOOL)animated;
{
  BSELF(ModerationSupportedTableDrawerView);
  
  [[self subviewsOfClass:[ABButton class]] each:^(ABButton *button) {
    button.hidden = NO;
  }];
  
  [UIView jm_transition:self options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
    [blockSelf.modControlView removeFromSuperview];
  } completion:^{
    blockSelf.modControlView = nil;
  } animated:animated];
}

- (BOOL)shouldShowModToolsByDefault;
{
  return self.modableElement.isModdable && [UDefaults boolForKey:kOptionsDrawerLastShowedModPrefKey];
}

- (void)showModTools;
{
  [UDefaults setBool:YES forKey:kOptionsDrawerLastShowedModPrefKey];
  BSELF(ModerationSupportedTableDrawerView);
  DO_AFTER_WAITING(0.1, ^{
    [blockSelf enterModModeAnimated:YES];
  });
}

#pragma mark - Dynamic Images

- (UIButton *)generateModButton;
{
  UIButton *modButton = [self createDrawerButtonWithIconName:@"small-mod-icon" highlightColor:JMHexColor(39B54A) target:self action:@selector(showModTools)];
//  ABButton *modButton = [[ABButton alloc] initWithIcon:[[self class] iconForModButton]];
//  [modButton addTarget:self action:@selector(showModTools) forControlEvents:UIControlEventTouchUpInside];
  return modButton;
}

+ (UIImage *)iconForModButton;
{
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* gradientStartColor = [UIColor colorWithRed: 0.996 green: 0.996 blue: 0.996 alpha: 1];
    UIColor* gradientEndColor = [UIColor colorWithRed: 0.749 green: 0.745 blue: 0.745 alpha: 1];
    UIColor* shadowColor2 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.75];
    UIColor* modTitleColor = [UIColor colorWithWhite:0.2 alpha:1.];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)gradientStartColor.CGColor,
                               (id)gradientEndColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    UIColor* shadow = shadowColor2;
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 2;
    UIColor* titleInnerShadow = [UIColor clearColor];
    CGSize titleInnerShadowOffset = CGSizeMake(0.1, -1.1);
    CGFloat titleInnerShadowBlurRadius = 0;
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, 58, 36);
    
    
    //// Abstracted Attributes
    NSString* titleContent = @"MOD";
    
    
    //// Rounded Rectangle Drawing
    CGRect roundedRectangleRect = CGRectMake(CGRectGetMinX(frame) + 12, CGRectGetMinY(frame) + 10, 35, 19);
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect cornerRadius: 4];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    CGContextBeginTransparencyLayer(context, NULL);
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient,
                                CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMinY(roundedRectangleRect)),
                                CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMaxY(roundedRectangleRect)),
                                0);
    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);
    
    
    
    //// Title Drawing
    CGRect titleRect = CGRectIntegral(CGRectMake(CGRectGetMinX(frame) + 12, CGRectGetMinY(frame) + 12, 36, 18));
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, titleInnerShadowOffset, titleInnerShadowBlurRadius, titleInnerShadow.CGColor);
    [modTitleColor setFill];
    [titleContent drawInRect: titleRect withFont: [UIFont fontWithName: @"HelveticaNeue-Bold" size: 11] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
  } opaque:NO withSize:CGSizeMake(58., 36.) cacheKey:@"mod-button"];
}

@end
