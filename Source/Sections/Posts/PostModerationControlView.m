#import "PostModerationControlView.h"

#import <QuartzCore/QuartzCore.h>
#import "NavigationManager.h"
#import "BlocksKit.h"
#import "MBProgressHUD.h"
#import "RedditAPI+Account.h"

@interface PostModerationControlView()
@property (strong) UIButton *messageButton;
@property (strong) UIButton *removeButton;
@property (strong) UIButton *approveButton;
@property (readonly) BOOL approved;
@property (readonly) BOOL removed;
@property (strong) Post *post;

//@property BOOL showsSpamButton;
@end

@implementation PostModerationControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
      self.layer.shouldRasterize = YES;
      self.layer.rasterizationScale = [UIScreen mainScreen].scale;
      
      self.backgroundColor = [UIColor colorForBackground];
      
      self.approveButton = [[self class] roundedModButton];
      [self addSubview:self.approveButton];
      self.approveButton.right = self.width - 10.;
      [self.approveButton centerVerticallyInSuperView];
      self.approveButton.top += 2.;
      self.approveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
      [self.approveButton addTarget:self action:@selector(didTapApproveButton) forControlEvents:UIControlEventTouchUpInside];
      
      //  self.removeButton = [[self class] modButtonWithBackgroundColor:[UIColor colorWithHex:0x1c0000]];
      self.removeButton = [[self class] roundedModButton];
      //  [self.removeButton setBackgroundImage:[[self class] resizableModButtonBackgroundWithColor:[UIColor colorWithHex:0x1c0000]] forState:UIControlStateNormal];
      [self.removeButton setTitle:@"Remove" forState:UIControlStateNormal];
      [self addSubview:self.removeButton];
      self.removeButton.top = self.approveButton.top;
      self.removeButton.left = 10.;
      self.removeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
      [self.removeButton addTarget:self action:@selector(didTapRemoveButton) forControlEvents:UIControlEventTouchUpInside];
      
      self.messageButton = [[self class] roundedModButton];
      [self.messageButton setBackgroundImage:[[self class] resizableModButtonBackgroundWithColor:[UIColor colorWithHex:0xffffff]] forState:UIControlStateNormal];
//      [self.messageButton setImage:[UIImage skinEtchedIcon:@"inbox-icon" withColor:[UIColor colorWithWhite:0.2 alpha:1.]] forState:UIControlStateNormal];
      [self.messageButton setImage:[UIImage skinEtchedIcon:@"inbox-icon" shadowColor:[UIColor clearColor] shadowOffset:CGSizeMake(0., -1.) fillColor:[UIColor colorWithWhite:0.9 alpha:1.] scale:1.] forState:UIControlStateNormal];
      [self.messageButton setImageEdgeInsets:UIEdgeInsetsMake(0., 0., 3., 0.)];
      self.messageButton.width = 36.;
      self.messageButton.height -= 1.;
      [self addSubview:self.messageButton];
      self.messageButton.top = self.approveButton.top;
      self.messageButton.right = self.approveButton.right;
      self.messageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
      [self.messageButton addTarget:self action:@selector(didTapMessageButton) forControlEvents:UIControlEventTouchUpInside];
      [self sendSubviewToBack:self.messageButton];
      
      UIImage *modCancelImage = [[self class] modCancelButtonImage];
      UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
      cancelButton.size = modCancelImage.size;
      [cancelButton setImage:modCancelImage forState:UIControlStateNormal];
      [self addSubview:cancelButton];
      [cancelButton centerInSuperView];
      cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
      [cancelButton addTarget:self action:@selector(didTapCancelButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (UIButton *)roundedModButton;
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  //  [button setBackgroundImage:[[self class] resizableModButtonBackgroundWithColor:color] forState:UIControlStateNormal];
  button.titleLabel.font = [UIFont fontWithName: @"HelveticaNeue-Bold" size: 11.5];
  button.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 4., 0.);
//  [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
//  button.titleLabel.shadowOffset = CGSizeMake(0., -1.);
  button.size = CGSizeMake(112., 32.);
  return button;
}

- (BOOL)approved;
{
  return self.post.moderationState == ModerationStateApproved;
}

- (BOOL)removed;
{
  return self.post.moderationState == ModerationStateRemoved;
}

- (void)didTapApproveButton;
{
  [self.post modApprove];
  BSELF(PostModerationControlView);
  self.messageButton.right = self.approveButton.right;
  DO_AFTER_WAITING(0.01, ^{
    [UIView jm_animate:^{
      [blockSelf updateModTools];
    } completion:^{
      if (blockSelf.onModerationStateChange) blockSelf.onModerationStateChange();
    }];
  });
}

- (void)i_removePostMarkAsSpam:(BOOL)markAsSpam;
{
  BSELF(PostModerationControlView);
  if (markAsSpam)
  {
    [self.post modMarkAsSpam];
  }
  else
  {

    [self.post modRemove];    
  }
  
  self.post.bannedBy = [RedditAPI shared].authenticatedUser;
  self.post.approvedBy = nil;
  
  self.messageButton.left = 10.;
  
  DO_AFTER_WAITING(0.01, ^{
    [UIView jm_animate:^{
      [blockSelf updateModTools];
    } completion:^{
      if (blockSelf.onModerationStateChange) blockSelf.onModerationStateChange();
    }];
  });
}

- (void)didTapRemoveButton;
{
  if (self.removed && !self.post.isSpam)
  {
    [self i_removePostMarkAsSpam:YES];
  }
  else
  {
    [self i_removePostMarkAsSpam:NO];
  }
}

- (void)didTapMessageButton;
{
  if (self.onModerationWillShowTemplateSelectionScreen)
  {
    self.onModerationWillShowTemplateSelectionScreen();
  }
  [[NavigationManager shared] showModerationNotifyScreenForPost:self.post onModerationMessageSentResponse:self.onModerationMessageSentResponse];
}

- (void)didTapCancelButton;
{
  if (self.onCancelTap)
  {
    BSELF(PostModerationControlView);
    DO_AFTER_WAITING(0.1, ^{
      blockSelf.onCancelTap();
    });
  }
}

- (void)updateRemoveButtonAppearance;
{
  self.removeButton.imageEdgeInsets = UIEdgeInsetsMake(0., 36., 3., -4.);
  if (self.removed)
  {
//    UIColor *spamButtonBGColor = self.post.isSpam ? [UIColor colorWithHex:0xff9600] : [UIColor colorWithHex:0xffffff];
    UIColor *spamButtonBGColor = [UIColor colorWithHex:0xffffff];
    UIColor *spamButtonIconColor = self.post.isSpam ? [UIColor colorWithHex:0xffc556] : [UIColor whiteColor];
//    UIColor *spamButtonShadowColor = [UIColor colorWithWhite:0. alpha:0.7];
//    CGSize spamButtonShadowOffset = CGSizeMake(0., -1.);
//    UIColor *spamButtonShadowColor = self.post.isSpam ? [UIColor colorWithWhite:1. alpha:0.8] : [UIColor blackColor];
//    CGSize spamButtonShadowOffset = self.post.isSpam ? CGSizeMake(0., 1.) : CGSizeMake(0., -1.);
    
    [self.removeButton setBackgroundImage:[[self class] resizableModButtonBackgroundWithColor:spamButtonBGColor] forState:UIControlStateNormal];
    [self.removeButton setTitle:@"Spam" forState:UIControlStateNormal];
    [self.removeButton setTitleColor:spamButtonIconColor forState:UIControlStateNormal];
//    [self.removeButton setTitleShadowColor:spamButtonShadowColor forState:UIControlStateNormal];
//    self.removeButton.titleLabel.shadowOffset = spamButtonShadowOffset;
    
    NSString *iconName = self.post.isSpam ? @"tiny-rounded-switch-icon-on" : @"tiny-rounded-switch-icon-off";
    [self.removeButton setImage:[UIImage skinEtchedIcon:iconName shadowColor:[UIColor clearColor] shadowOffset:CGSizeZero fillColor:spamButtonIconColor scale:1.] forState:UIControlStateNormal];
//    [self.removeButton setImage:[UIImage skinEtchedIcon:@"report-icon" shadowColor:[UIColor blackColor] shadowOffset:CGSizeMake(0, -1.) fillColor:spamButtonIconColor] forState:UIControlStateNormal];
    self.removeButton.titleEdgeInsets = UIEdgeInsetsMake(0., -48., 4., 0.);

//    if (self.post.isSpam)
//    {
//      self.removeButton.imageEdgeInsets = UIEdgeInsetsMake(0., 36., 5., -4.);
//    self.removeButton.titleEdgeInsets = UIEdgeInsetsMake(0., -48., 5., 0.);
//    }
  }
  else
  {
    [self.removeButton setImage:nil forState:UIControlStateNormal];
    [self.removeButton setTitle:(self.removed) ? @"Removed" : @"Remove" forState:UIControlStateNormal];
    [self.removeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.removeButton setBackgroundImage:[[self class] resizableModButtonBackgroundWithColor:[UIColor colorWithHex:(self.removed) ? 0xffffff : 0x1F0A0A]] forState:UIControlStateNormal];
    self.removeButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 4., 0.);
    
//    [self.removeButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
//    self.removeButton.titleLabel.shadowOffset = CGSizeMake(0., -1.);
  }
}

- (void)updateModTools;
{
  [self.approveButton setTitle:(self.approved) ? @"Approved" : @"Approve" forState:UIControlStateNormal];
  [self.approveButton setBackgroundImage:[[self class] resizableModButtonBackgroundWithColor:[UIColor colorWithHex:(self.approved) ? 0xffffff : 0x133011]] forState:UIControlStateNormal];
  self.approveButton.width = self.approved ? 70. : 112.;
  
  [self updateRemoveButtonAppearance];
  
  self.removeButton.width = self.removed ? 70. : 112.;
  self.removeButton.left = self.removed ? 50. : 10.;
  
  if (self.removed)
  {
    self.messageButton.right = self.removeButton.left - 4.;
    self.messageButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  }
  else if (self.approved)
  {
    self.messageButton.left = self.approveButton.right + 4.;
    self.messageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  }
}

- (void)updateWithPost:(Post *)post;
{
  self.post = post;
  [self updateModTools];
}

#pragma mark - Dynamic Images

+ (UIImage *)modCancelButtonImage;
{
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* gradientStartColor = [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1];
    UIColor* gradientEndColor = [UIColor colorWithRed: 0.749 green: 0.745 blue: 0.745 alpha: 1];
    UIColor* shadow2Color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.3];
    UIColor* shadowColor2 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.3];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)gradientStartColor.CGColor,
                               (id)gradientEndColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    UIColor* shadow = shadowColor2;
    CGSize shadowOffset = CGSizeMake(0, 1);
    CGFloat shadowBlurRadius = 1;
    UIColor* titleInnerShadow = shadow2Color;
    CGSize titleInnerShadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat titleInnerShadowBlurRadius = 0;
    UIColor* shadow2 = [UIColor whiteColor];
    CGSize shadow2Offset = CGSizeMake(0.1, 1.1);
    CGFloat shadow2BlurRadius = 0;
    
    //// Frames
    CGRect frame = CGRectMake(0, 0., 58, 36);
    
    
    //// Rounded Rectangle Drawing
    CGRect roundedRectangleRect = CGRectMake(CGRectGetMinX(frame) + 12, CGRectGetMinY(frame) + 8, 35, 19);
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
    
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 29.72, CGRectGetMinY(frame) + 15.72)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 33.22, CGRectGetMinY(frame) + 12.22)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35.22, CGRectGetMinY(frame) + 14.22)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 31.72, CGRectGetMinY(frame) + 17.72)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35.22, CGRectGetMinY(frame) + 21.22)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 33.22, CGRectGetMinY(frame) + 23.22)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 29.72, CGRectGetMinY(frame) + 19.72)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 26.22, CGRectGetMinY(frame) + 23.22)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.22, CGRectGetMinY(frame) + 21.22)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 27.72, CGRectGetMinY(frame) + 17.72)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.22, CGRectGetMinY(frame) + 14.22)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 26.22, CGRectGetMinY(frame) + 12.22)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 29.72, CGRectGetMinY(frame) + 15.72)];
    [bezierPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor);
    [[UIColor darkGrayColor] setFill];
    [bezierPath fill];
    
    ////// Bezier Inner Shadow
    CGRect bezierBorderRect = CGRectInset([bezierPath bounds], -titleInnerShadowBlurRadius, -titleInnerShadowBlurRadius);
    bezierBorderRect = CGRectOffset(bezierBorderRect, -titleInnerShadowOffset.width, -titleInnerShadowOffset.height);
    bezierBorderRect = CGRectInset(CGRectUnion(bezierBorderRect, [bezierPath bounds]), -1, -1);
    
    UIBezierPath* bezierNegativePath = [UIBezierPath bezierPathWithRect: bezierBorderRect];
    [bezierNegativePath appendPath: bezierPath];
    bezierNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
      CGFloat xOffset = titleInnerShadowOffset.width + round(bezierBorderRect.size.width);
      CGFloat yOffset = titleInnerShadowOffset.height;
      CGContextSetShadowWithColor(context,
                                  CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                  titleInnerShadowBlurRadius,
                                  titleInnerShadow.CGColor);
      
      [bezierPath addClip];
      CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(bezierBorderRect.size.width), 0);
      [bezierNegativePath applyTransform: transform];
      [[UIColor grayColor] setFill];
      [bezierNegativePath fill];
    }
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);
    
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
  } withSize:CGSizeMake(58., 36.)];
}

+ (UIImage *)resizableModButtonBackgroundWithColor:(UIColor *)bgColor;
{
  UIImage *image = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    CGFloat bgColorHSBA[4];
    [bgColor getHue: &bgColorHSBA[0] saturation: &bgColorHSBA[1] brightness: &bgColorHSBA[2] alpha: &bgColorHSBA[3]];
    
    UIColor* gradientStartColor = [UIColor colorWithHue: bgColorHSBA[0] saturation: bgColorHSBA[1] brightness: 0.7 alpha: bgColorHSBA[3]];
    UIColor* gradientEndColor = [UIColor colorWithHue: bgColorHSBA[0] saturation: bgColorHSBA[1] brightness: 0.6 alpha: bgColorHSBA[3]];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)gradientStartColor.CGColor,
                               (id)gradientEndColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    UIColor* shadow = [UIColor colorWithWhite:0 alpha:0.4];
    CGSize shadowOffset = CGSizeMake(0., 1.);
    CGFloat shadowBlurRadius = 1;
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, 41, 36);
    
    //// Rounded Rectangle Drawing
    CGRect roundedRectangleRect = CGRectMake(CGRectGetMinX(frame) + 2, CGRectGetMinY(frame), CGRectGetWidth(frame) - 4, CGRectGetHeight(frame) - 4);
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: roundedRectangleRect cornerRadius: 6];
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
    
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    
  } withSize:CGSizeMake(41., 36.)];
  
  return [image jm_resizableImageWithCapInsets:UIEdgeInsetsMake(20., 18., 20., 18.) resizingMode:UIImageResizingModeTile];
}


@end
