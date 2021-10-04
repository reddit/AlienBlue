#import "BrowserNavigationBar.h"
#import "JMOptimalSwitch.h"
#import "JMOptimalProgressBar.h"
#import "Post.h"
#import "Post+Sponsored.h"
#import "JMActionMenuBarItemView.h"
#import "JMActionMenuView.h"

@interface BrowserNavigationBar()

@property (readonly) BOOL showsCommentsButton;

@property (strong) JMOptimalToolbarCoordinator *toolbarCoordinator;
@property (strong) JMOptimalProgressBar *progressBar;
@property (strong) UIButton *switchToCommentsButton;
@property (strong) UIButton *optimalSwitchButton;
@property (strong) UIImageView *verticalDividerView;
@property (strong) UIView *optimalBarContainerView;
@property (strong) UIImageView *actionMenuBarMaskingView;
@property (strong) Post *post;

@property BOOL shouldDecorateForOptimal;
@property BOOL optimalSwitchIsDisabled;
@property CGFloat progress;
@end

@interface JMOptimalToolbarCoordinator()
- (void)didTapSettingsButton;
- (void)optimalSwitch:(JMOptimalSwitch *)optimalSwitch didChangeOptimalTo:(BOOL)isOptimal;
@end

@implementation BrowserNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
  JM_SUPER_INIT(initWithFrame:frame);
  
  self.showsThinUnderlineViewInCompactMode = YES;
  
  self.optimalBarContainerView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 63., 0.)];
  self.optimalBarContainerView.backgroundColor = [UIColor clearColor];
  self.optimalBarContainerView.autoresizingMask = JMFlexibleSizeMask;
  [self insertSubview:self.optimalBarContainerView atIndex:0];
  
  self.progressBar = [JMOptimalProgressBar new];
  [self.optimalBarContainerView addSubview:self.progressBar];
  
  self.switchToCommentsButton = [[UIButton alloc] initWithSize:CGSizeMake(80., 40.)];
  [self.switchToCommentsButton addTarget:self action:@selector(didTapCommentsButton) forControlEvents:UIControlEventTouchUpInside];
  [self.optimalBarContainerView addSubview:self.switchToCommentsButton];
  
  self.optimalSwitchButton = [[UIButton alloc] initWithSize:CGSizeMake(80., 40.)];
  [self.optimalSwitchButton addTarget:self action:@selector(didTapOptimalSwitch) forControlEvents:UIControlEventTouchUpInside];
  [self.optimalBarContainerView addSubview:self.optimalSwitchButton];
  
  self.actionMenuBarMaskingView = [[UIImageView alloc] initWithSize:CGSizeMake(80., 40.)];
  self.actionMenuBarMaskingView.image = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGRect underlayRect = CGRectCropToLeft(bounds, bounds.size.width - 5.);
    [[UIColor colorForBackground] setFill];
    [[UIBezierPath bezierPathWithRect:underlayRect] fill];
    
    CGRect shadowRect = CGRectCropToRight(bounds, 5.);

    UIImage *verticalGradient = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
      [UIView jm_drawReflectedVerticalGradientInRect:shadowRect withCenterColor:[UIColor blackColor] edgeColor:[[UIColor blackColor] colorWithAlphaComponent:0.] minimumCenterFillRatio:0.2];
    } withSize:bounds.size];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, bounds, verticalGradient.CGImage);
    [UIView jm_drawHorizontalShadowGradientWithOpacity:0.3 inRect:shadowRect];
    
    
  } withSize:self.actionMenuBarMaskingView.size];
  [self addSubview:self.actionMenuBarMaskingView];

  
  UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressOptimalSwitch:)];
  [self.optimalSwitchButton addGestureRecognizer:longPressGesture];

  self.verticalDividerView = [[UIImageView alloc] initWithSize:CGSizeMake(3., 46.)];
  [self updateVerticalDividerContentImage];
  [self.optimalBarContainerView addSubview:self.verticalDividerView];
  
  return self;
}

- (void)updateVerticalDividerContentImage;
{
  CGFloat verticalInset = self.isCompacted ? 12. : 0.;
  self.verticalDividerView.image = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    [UIView jm_drawVerticalDottedLineInRect:CGRectInset(bounds, 0., verticalInset) lineWidth:1. lineColor:[UIColor colorForHighlightedOptions]];
  } withSize:self.verticalDividerView.size];
}

//+ (UIBezierPath *)bezierPathForBubbleIconWithSize:(CGSize)size;
//{
////  UIBezierPath* bezierPath = [UIBezierPath bezierPath];
////  [bezierPath moveToPoint: CGPointMake(31, 5)];
////  [bezierPath addLineToPoint: CGPointMake(31, 14)];
////  [bezierPath addCurveToPoint: CGPointMake(27, 18) controlPoint1: CGPointMake(31, 16.21) controlPoint2: CGPointMake(29.21, 18)];
////  [bezierPath addLineToPoint: CGPointMake(19.64, 18)];
////  [bezierPath addCurveToPoint: CGPointMake(13.38, 23) controlPoint1: CGPointMake(17.25, 19.93) controlPoint2: CGPointMake(13.39, 23.04)];
////  [bezierPath addCurveToPoint: CGPointMake(12.72, 18) controlPoint1: CGPointMake(14.43, 20.49) controlPoint2: CGPointMake(13.82, 18.95)];
////  [bezierPath addLineToPoint: CGPointMake(5, 18)];
////  [bezierPath addCurveToPoint: CGPointMake(1, 14) controlPoint1: CGPointMake(2.79, 18) controlPoint2: CGPointMake(1, 16.21)];
////  [bezierPath addLineToPoint: CGPointMake(1, 5)];
////  [bezierPath addCurveToPoint: CGPointMake(5, 1) controlPoint1: CGPointMake(1, 2.79) controlPoint2: CGPointMake(2.79, 1)];
////  [bezierPath addLineToPoint: CGPointMake(27, 1)];
////  [bezierPath addCurveToPoint: CGPointMake(31, 5) controlPoint1: CGPointMake(29.21, 1) controlPoint2: CGPointMake(31, 2.79)];
////  [bezierPath closePath];
////  return bezierPath;
//}

- (void)applyThemeSettings;
{
  [super applyThemeSettings];
  [self updateBarContents];
}

- (void)layoutSubviews;
{
  [super layoutSubviews];
  
  self.verticalDividerView.centerY = self.titleLabel.centerY;
  [self.verticalDividerView centerHorizontallyInSuperView];
  
  self.switchToCommentsButton.centerY = self.verticalDividerView.centerY;
  self.switchToCommentsButton.left = self.verticalDividerView.right + 10.;
  [self.switchToCommentsButton jm_bringToFront];
  
  self.optimalSwitchButton.centerY = self.verticalDividerView.centerY;
  self.optimalSwitchButton.right = self.verticalDividerView.left - 10.;
  [self.optimalSwitchButton jm_bringToFront];
  
  if (!self.showsCommentsButton)
  {
    [self.optimalSwitchButton centerHorizontallyInSuperView];
  }
  
  self.progressBar.width = 68.;
  CGFloat progressBarNudgeX = self.shouldDecorateForOptimal ? -2 : -3.;
  [self.progressBar centerHorizontallyInRect:self.optimalSwitchButton.frame];
  self.progressBar.top = self.optimalSwitchButton.bottom - 7.;
  self.progressBar.left += progressBarNudgeX;
  self.progressBar.height = 7.;
  
  self.actionMenuBarMaskingView.top = self.switchToCommentsButton.top;
  self.actionMenuBarMaskingView.right = self.bounds.size.width - 82.;
  
  BOOL limitedWidth = (self.post && self.bounds.size.width <= 320. && self.actionMenuBarItemView.visibleBadgeCount > 1);
  self.actionMenuBarMaskingView.hidden = !limitedWidth;
}

- (BOOL)showsCommentsButton;
{
  if (!self.post)
    return NO;
  
  if (self.post.promoted && !self.post.sponsoredPostHasCommentThread)
    return NO;
  
  return YES;
}

- (CGFloat)maximumBarHeight;
{
  return self.defaultBarHeight;
}

- (void)updateBarContents;
{
  self.switchToCommentsButton.hidden = !self.showsCommentsButton;
  self.verticalDividerView.hidden = self.switchToCommentsButton.hidden;
  
  self.optimalSwitchButton.enabled = !self.optimalSwitchIsDisabled;
  self.optimalSwitchButton.alpha = self.optimalSwitchButton.enabled ? 1. : 0.5;
  UIColor *iconColor = [UIColor colorForTint];
  UIColor *textColor = [UIColor colorForText];
  UIFont *textFont = [UIFont skinFontWithName:kBundleFontPostSubtitle];
  BSELF(BrowserNavigationBar);
  
  UIImage *commentsButtonImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    
    UIImage *commentsIcon = [UIImage skinIcon:@"tiny-comment-icon" withColor:iconColor];
    [commentsIcon drawAtPoint:CGPointMake(0., 6.)];
    
    NSUInteger numComments = blockSelf.post.numComments;
    NSString *commentsTruncated = [NSString stringWithFormat:@"%d", numComments];
    [textColor set];
    [commentsTruncated drawAtPoint:CGPointMake(30., 12.) withAttributes:@{NSFontAttributeName : textFont, NSForegroundColorAttributeName : textColor}];
  } withSize:self.switchToCommentsButton.size];
  [self.switchToCommentsButton setImage:commentsButtonImage forState:UIControlStateNormal];
  
  UIImage *optimalButtonImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    
    CGRect indicatorRect = CGRectCropToRight(bounds, 30.);
    indicatorRect = CGRectCenterWithSize(indicatorRect, CGSizeMake(12., 12.));
    UIBezierPath *indicatorPath = [UIBezierPath bezierPathWithOvalInRect:indicatorRect];
    [[UIColor grayColor] setStroke];
    [indicatorPath stroke];
    
    if (blockSelf.shouldDecorateForOptimal)
    {
      [[UIColor skinColorForConstructive] setFill];
      [indicatorPath fill];
    }
    
    NSString *text = blockSelf.shouldDecorateForOptimal ? @"optimal" : @"standard";
    CGFloat textWidth = [text jm_sizeWithFont:textFont].width;
    CGFloat textOffsetX = bounds.size.width - textWidth - 30.;

    [textColor set];
    [text drawAtPoint:CGPointMake(textOffsetX, 12.) withAttributes:@{NSFontAttributeName : textFont, NSForegroundColorAttributeName : textColor}];
    
    
    //    UIImage *commentsIcon = [UIImage skinIcon:@"tiny-comment-icon" withColor:iconColor];
    //    [commentsIcon drawAtPoint:CGPointMake(0., 6.)];
    //
    //    NSUInteger numComments = 123;
    //    NSString *commentsTruncated = [NSString shortFormattedStringFromNumber:numComments];
    //    [commentsTruncated drawAtPoint:CGPointMake(30., 12.) withAttributes:@{NSFontAttributeName : textFont}];
  } withSize:self.switchToCommentsButton.size];
  [self.optimalSwitchButton setImage:optimalButtonImage forState:UIControlStateNormal];
}

- (void)didTapOptimalSwitch;
{
  [self.toolbarCoordinator optimalSwitch:nil didChangeOptimalTo:!self.shouldDecorateForOptimal];
  if (self.onOptimalSwitchChange)
  {
    self.onOptimalSwitchChange(!self.shouldDecorateForOptimal);
  }
}

- (void)didTapCommentsButton;
{
  if (self.onCommentButtonTap)
  {
    self.onCommentButtonTap();
  }
}

- (void)didLongPressOptimalSwitch:(UILongPressGestureRecognizer *)gesture;
{
  if (gesture.state != UIGestureRecognizerStateBegan)
    return;
  
  [self.toolbarCoordinator didTapSettingsButton];
}

- (void)updateWithWithToolbarCoordinator:(JMOptimalToolbarCoordinator *)optimalToolbarCoordinator forPost:(Post *)post displaysOptimalByDefault:(BOOL)displaysOptimalByDefault hidesOptimalBar:(BOOL)hidesOptimalBar;
{
  if (self.toolbarCoordinator == optimalToolbarCoordinator)
    return;
  
  self.post = post;
  self.titleLabel.hidden = !hidesOptimalBar;
  self.toolbarCoordinator = optimalToolbarCoordinator;
  
  BSELF(BrowserNavigationBar);
  optimalToolbarCoordinator.onSetOptimalAnimatedAction = ^(BOOL isOptimal, BOOL animated){
    blockSelf.shouldDecorateForOptimal = isOptimal;
    [UIView jm_transition:blockSelf.optimalSwitchButton animations:^{
      [blockSelf updateBarContents];
    } completion:nil];
  };
  
  optimalToolbarCoordinator.onSetOptimalSwitchDisabledAction = ^(BOOL isOptimalDisabled)
  {
    blockSelf.optimalSwitchIsDisabled = isOptimalDisabled;
    [blockSelf updateBarContents];
  };
  
  optimalToolbarCoordinator.onSetOptimalSwitchHideAction = ^(BOOL isOptimalSwitchHidden)
  {
    blockSelf.optimalSwitchButton.hidden = isOptimalSwitchHidden;
    blockSelf.titleLabel.hidden = !isOptimalSwitchHidden;
  };
  
  optimalToolbarCoordinator.onSetProgressAction = ^(CGFloat progress){
    [blockSelf updateWithProgress:progress];
  };
  
  optimalToolbarCoordinator.onStartIndeterminateProgressAction = ^{
    [blockSelf didStartIndeterminateProgress];
  };
  
  optimalToolbarCoordinator.onFinishIndeterminateProgressAction = ^{
    [blockSelf didFinishIndeterminateProgress];
  };
  
  self.shouldDecorateForOptimal = displaysOptimalByDefault;
  [self updateBarContents];
  
  if (hidesOptimalBar)
  {
    self.optimalBarContainerView.hidden = YES;
  }
}

- (void)didStartIndeterminateProgress;
{
  if (!self.isCompacted)
  {
    self.progressBar.alpha = 1.;
  }
  self.progressBar.progressBarMode = JMOptimalProgressBarModeDeterminate;
  [self.progressBar start];
}

- (void)didFinishIndeterminateProgress;
{
  [self.progressBar stop];
  [self fadeProgressBarOut];
}

- (void)fadeProgressBarOut;
{
  BSELF(BrowserNavigationBar);
  [UIView jm_animate:^{
    blockSelf.progressBar.alpha = 0.;
  } completion:nil];
}

- (void)updateWithProgress:(CGFloat)progress;
{
  if (!self.isCompacted)
  {
    self.progressBar.alpha = 1.;
  }
  self.progressBar.progress = progress;
  self.progressBar.progressBarMode = (progress == 1.) ? JMOptimalProgressBarModeComplete : JMOptimalProgressBarModeDeterminate;
  if (progress == 1.)
  {
    [self fadeProgressBarOut];
  }
}

- (void)updateSubviewContentsBasedOnHeightAnimated:(BOOL)animated;
{
  [super updateSubviewContentsBasedOnHeightAnimated:animated];
  BSELF(BrowserNavigationBar);
  [UIView jm_animate:^{
    [blockSelf updateVerticalDividerContentImage];
    if (blockSelf.isCompacted)
    {
      blockSelf.progressBar.alpha = 0.;
    }
  } completion:nil animated:animated];
}

- (void)makeOptimalBarVisible;
{
  BSELF(BrowserNavigationBar);
  [UIView jm_animate:^{
    blockSelf.optimalBarContainerView.alpha = 1.;
  } completion:nil];
}

- (void)updateWithActionMenuBarItemView:(UIView *)actionMenuBarItemView;
{
  [super updateWithActionMenuBarItemView:actionMenuBarItemView];
  [self.actionMenuBarMaskingView jm_bringToFront];
  [self.optimalBarContainerView jm_bringToFront];
}

@end
