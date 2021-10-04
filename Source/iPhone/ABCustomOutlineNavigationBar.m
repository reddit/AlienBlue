#import "ABCustomOutlineNavigationBar.h"
#import "JMActionMenuBarItemView.h"
#import "JMActionMenuView.h"
#import "ABActionMenuThemeConfiguration.h"
#import "NavigationManager.h"
#import "OverlayViewContainer.h"
#import "AlienBlueAppDelegate.h"
#import "ABHoverPreviewView.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "Resources.h"

@interface ABCustomOutlineNavigationBar()
@property (strong) OverlayViewContainer *underlineView;
@property (strong) UIView *compactUnderlineView;
@property (strong) JMActionMenuBarItemView *actionMenuBarItemView;
@property (strong) UIButton *backButton;
@property (strong) UIButton *modalCloseButton;
@property (strong) UIButton *customLeftButton;
@property (strong) UIButton *customRightButton;
@property (strong) UILabel *titleLabel;
@property (readonly) BOOL parentViewControllerIsVisible;
@property (readonly) CGFloat topPadding;
@end

@implementation ABCustomOutlineNavigationBar

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
}

- (void)sanitityCheckSizes;
{
  NSAssert(self.defaultBarHeight >= self.minimumBarHeight, @"minimumBarHeight is greater than defaultBarHeight");
  NSAssert(self.maximumBarHeight >= self.defaultBarHeight, @"defaultBarHeight is greater than maximumBarHeight");
}

- (instancetype)initWithFrame:(CGRect)frame
{
  JM_SUPER_INIT(initWithFrame:frame);
  [self sanitityCheckSizes];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyThemeSettings) name:kNightModeSwitchNotification object:nil];
  
  [self createBackButton];
  [self createModalCloseButton];
  [self createUnderlineView];
  
  self.titleLabel = [UILabel new];
  self.titleLabel.autoresizingMask = JMFlexibleHorizontalMarginMask;
  self.titleLabel.height = 60.;
  self.titleLabel.textAlignment = NSTextAlignmentLeft;
  self.titleLabel.font = [UIFont skinFontWithName:kBundleFontNavigationTitle];
  [self addSubview:self.titleLabel];
  [self.titleLabel centerHorizontallyInSuperView];

  self.compactUnderlineView = [[UIView alloc] initWithSize:CGSizeMake(self.bounds.size.width, 1.)];
  self.compactUnderlineView.bottom = self.bounds.size.height;
  self.compactUnderlineView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  self.compactUnderlineView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
  [self addSubview:self.compactUnderlineView];
  
  return self;
}

- (void)didTripleTap;
{
  [[NavigationManager shared] userDidTripleTapNavigationBar];
}

- (void)setCustomLeftButtonWithIcon:(UIImage *)icon onTapAction:(JMAction)onTap;
{
  [self.customLeftButton removeFromSuperview];
  
  self.customLeftButton = [self generateCircularNavigationButtonWithIconImage:icon onTap:^{
    if (onTap)
    {
      onTap();
    }
  }];
  
  [self addSubview:self.customLeftButton];
}

- (void)setCustomLeftButtonWithTitle:(NSString *)title onTapAction:(JMAction)onTap;
{
  [self setCustomLeftButtonWithIcon:[self generateTitleIconWithText:title] onTapAction:onTap];
}

- (void)setCustomRightButtonWithIcon:(UIImage *)icon onTapAction:(JMAction)onTap;
{
  [self.customRightButton removeFromSuperview];
  
  self.customRightButton = [self generateCircularNavigationButtonWithIconImage:icon onTap:^{
    if (onTap)
    {
      onTap();
    }
  }];
  
  [self addSubview:self.customRightButton];
}

- (void)setCustomRightButtonWithTitle:(NSString *)title onTapAction:(JMAction)onTap;
{
  [self setCustomRightButtonWithIcon:[self generateTitleIconWithText:title] onTapAction:onTap];
}

- (UIImage *)generateTitleIconWithText:(NSString *)text;
{
  UIImage *icon = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    [text jm_drawVerticallyCenteredInRect:bounds withFont:[UIFont systemFontOfSize:11.] color:[UIColor colorForHighlightedOptions] horizontalAlignment:NSTextAlignmentCenter];
  } withSize:CGSizeMake(50., 50.)];
  return icon;
}

- (void)createModalCloseButton;
{
  UIImage *downwardTriangleIcon = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGPoint triangleCenterPoint = CGPointCenterOfRect(bounds);
    triangleCenterPoint.y += 2.;
    triangleCenterPoint.x += 2.;
    UIBezierPath *trianglePath = [UIBezierPath bezierPathWithTriangleCenter:CGPointZero sideLength:10. angle:180.];
    [trianglePath applyTransform:CGAffineTransformMakeScale(1.3, 1.)];
    [trianglePath applyTransform:CGAffineTransformMakeTranslation(triangleCenterPoint.x, triangleCenterPoint.y)];
    [trianglePath fill];
  } withSize:CGSizeMake(30., 30.)];
  
  BSELF(ABCustomOutlineNavigationBar);
  self.modalCloseButton = [self generateCircularNavigationButtonWithIconImage:downwardTriangleIcon onTap:^{
    [blockSelf didTapModalCloseButton];
  }];
  
  [self addSubview:self.modalCloseButton];
}

- (void)createUnderlineView;
{
  CGFloat maskingDistanceBeneathUnderline = 5.;
  self.underlineView = [[OverlayViewContainer alloc] initWithSize:CGSizeMake(self.bounds.size.width, maskingDistanceBeneathUnderline)];
  JMViewOverlay *overlay = [JMViewOverlay overlayWithFrame:self.underlineView.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    [[UIColor colorForBackground] setFill];
    [[UIBezierPath bezierPathWithRect:bounds] fill];
    
    [[UIColor colorForDivider] setFill];
    CGRect dividerRect = CGRectInset(CGRectCropToTop(bounds, 1.), 12., 0.);
    [[UIBezierPath bezierPathWithRect:dividerRect] fill];
  }];
  overlay.autoresizingMask = JMFlexibleSizeMask;
  [self.underlineView addOverlay:overlay];
  self.underlineView.bottom = self.bounds.size.height + 1.;
  self.underlineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  [self addSubview:self.underlineView];
  [self.underlineView centerHorizontallyInSuperView];
}

- (UIButton *)generateCircularNavigationButtonWithIconImage:(UIImage *)iconImage onTap:(JMAction)onTapAction;
{
  UIButton *b = [[UIButton alloc] initWithSize:CGSizeMake(60., 60.)];
  b.backgroundColor = [UIColor clearColor];
  
  OverlayViewContainer *overlayContainer = [[OverlayViewContainer alloc] initWithFrame:b.bounds];
  overlayContainer.backgroundColor = [UIColor clearColor];
  
  BSELF(ABCustomOutlineNavigationBar);
  JMViewOverlay *buttonOverlay = [JMViewOverlay overlayWithFrame:b.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    ABActionMenuThemeConfiguration *actionMenuThemeConfiguration = [ABActionMenuThemeConfiguration new];
    CGRect circleRect = CGRectCenterWithSize(bounds, CGSizeMake(37., 37.));
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    
    UIColor *fillColor = actionMenuThemeConfiguration.themeBackgroundColor;
    [fillColor setFill];
    [circlePath fill];
    
    UIColor *strokeColor = actionMenuThemeConfiguration.softStrokeColor;
    [strokeColor setStroke];
    
    if (!blockSelf.isCompacted || highlighted)
    {
      CGFloat lineWidth = highlighted ? 3. : 1.;
      [circlePath setLineWidth:lineWidth];
      [circlePath stroke];
    }
    
    UIColor *iconColor = actionMenuThemeConfiguration.themeForegroundColor;
    UIImage *icon = [UIImage jm_coloredImageFromImage:iconImage fillColor:iconColor];
    CGRect iconRect = CGRectCenterWithSize(circleRect, icon.size);
    [icon drawAtPoint:iconRect.origin];
    
  } onTap:^(CGPoint touchPoint) {
    onTapAction();
  }];
  
  buttonOverlay.onPress = ^(CGPoint touchPoint) {
    [blockSelf.parentViewController.tableView setContentOffset:blockSelf.parentViewController.tableView.contentOffset animated:NO];
  };
  [overlayContainer addOverlay:buttonOverlay];
  [b addSubview:overlayContainer];
  return b;
}

- (void)applyThemeSettings;
{
  self.backgroundColor = [UIColor colorForBackground];
  [self.underlineView setNeedsDisplay];
  self.titleLabel.textColor = [UIColor colorForBarButtonItem];
  self.titleLabel.shadowColor = [UIColor colorForBarButtonItemShadow];
  self.titleLabel.shadowOffset = SkinShadowOffsetSize();
  [self redrawContentsOfCircularNavigationButton:self.backButton animated:NO];
  [self.actionMenuBarItemView setNeedsDisplay];
}

- (void)createBackButton;
{
  UIImage *backIcon = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGPoint triangleCenterPoint = CGPointCenterOfRect(bounds);
    triangleCenterPoint.y += 1.5;
    triangleCenterPoint.x -= 0.5;
    UIBezierPath *trianglePath = [UIBezierPath bezierPathWithTriangleCenter:triangleCenterPoint sideLength:11.5 angle:270.];
    [trianglePath fill];
  } withSize:CGSizeMake(30., 30.)];
  
  BSELF(ABCustomOutlineNavigationBar);
  self.backButton = [self generateCircularNavigationButtonWithIconImage:backIcon onTap:^{
    [blockSelf didTapBackButton];
  }];
  
  UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressBackButton:)];
  gesture.minimumPressDuration = 0.7;
  [self.backButton addGestureRecognizer:gesture];
  
  [self addSubview:self.backButton];
}

- (void)redrawContentsOfCircularNavigationButton:(UIButton *)button animated:(BOOL)animated;
{
  UIView *buttonOverlayContainerView = [button jm_firstSubviewOfClass:[OverlayViewContainer class]];
  [UIView jm_transition:buttonOverlayContainerView animations:^{
    [buttonOverlayContainerView setNeedsDisplay];
  } completion:nil animated:animated];
}

- (CGFloat)compactedHeightThreshold;
{
  return [super compactedHeightThreshold] - self.topPadding;
}

- (CGFloat)minimumBarHeight;
{
  return 34. + self.topPadding;
}

- (CGFloat)defaultBarHeight;
{
  return 100;
}

- (CGFloat)maximumBarHeight;
{
  return 110;
}

- (CGFloat)topPadding;
{
  return (JMIsIpad() || self.hidesStatusBarOnCompact) ? 0. : 35.;
}

- (BOOL)hidesStatusBarOnCompact;
{
  return [Resources shouldAutoHideStatusBarWhenScrolling] || self.parentViewController.shouldUseCompactNavigationBar;
}

- (void)updateSubviewContentsBasedOnHeightAnimated:(BOOL)animated;
{
  BOOL compact = self.isCompacted;
  [self.actionMenuBarItemView setCompactOpenButton:compact animated:animated];
  [self redrawContentsOfCircularNavigationButton:self.backButton animated:animated];
  [self redrawContentsOfCircularNavigationButton:self.modalCloseButton animated:animated];
  [self redrawContentsOfCircularNavigationButton:self.customLeftButton animated:animated];
  [self redrawContentsOfCircularNavigationButton:self.customRightButton animated:animated];
  [self setTitleLabelHidden:compact animated:animated];
  
  BSELF(ABCustomOutlineNavigationBar);
  [UIView jm_animate:^{
    blockSelf.compactUnderlineView.alpha = compact ? 1. : 0.;
    blockSelf.underlineView.alpha = compact ? 0. : 1.;
  } completion:nil animated:animated];
}

- (void)updateContentsBasedOnHeightAnimated:(BOOL)animated;
{
  [super updateContentsBasedOnHeightAnimated:animated];
  if (JMIsIphone())
  {
    BOOL shouldShowStatusBar = !(self.isCompacted && self.hidesStatusBarOnCompact) && ![ABHoverPreviewView isShowingPreview];
    JMAnimateStatusBarHidden(!shouldShowStatusBar);
  }
  [self updateSubviewContentsBasedOnHeightAnimated:animated];
}

- (CGFloat)recommendedVerticalCenterForBarItems;
{
  CGFloat statusBarMinHeight = MIN(self.topPadding, 20.);
  CGFloat statusBarAdjustment = JM_LIMIT(statusBarMinHeight, 20, self.height - self.compactedHeightThreshold);
  CGRect areaForLayoutRect  = CGRectCropToBottom(self.bounds, self.bounds.size.height - statusBarAdjustment);
  CGFloat midY = CGPointCenterOfRect(areaForLayoutRect).y + 1.;
  midY = MIN(midY, 59.);
  return midY;
}

- (void)layoutSubviews;
{
  [super layoutSubviews];
  [self.titleLabel sizeToFit];
  
  CGFloat midY = self.recommendedVerticalCenterForBarItems;
  CGFloat edgePadding = 2.;
  
  self.actionMenuBarItemView.right = self.bounds.size.width - 2.;
  self.actionMenuBarItemView.centerY = midY;
  
  self.backButton.centerY = midY;
  self.backButton.left = edgePadding;
  
  self.customLeftButton.centerY = midY;
  self.customLeftButton.left = edgePadding;
  
  self.customRightButton.centerY = midY;
  self.customRightButton.right = self.bounds.size.width - edgePadding;
  
  self.modalCloseButton.right = self.bounds.size.width - edgePadding;
  self.modalCloseButton.centerY = midY;
  
  self.titleLabel.centerY = midY;
  if (self.actionMenuBarItemView.visibleBadgeCount > 0)
  {
    self.titleLabel.left = (self.backButton.hidden) ? 15. : self.backButton.right + 10.;
  }
  else
  {
    [self.titleLabel centerHorizontallyInSuperView];
  }
  
  [self.titleLabel jm_adjustToPixelBoundaries];
  [self.modalCloseButton jm_adjustToPixelBoundaries];
  [self.backButton jm_adjustToPixelBoundaries];
  [self.actionMenuBarItemView jm_adjustToPixelBoundaries];
  [self.customLeftButton jm_adjustToPixelBoundaries];
  [self.customRightButton jm_adjustToPixelBoundaries];
  
  CGFloat compactedRatio = 1. - JM_LIMIT(0., 1., (self.height - self.minimumBarHeight) / (self.defaultBarHeight - self.minimumBarHeight));
  self.compactUnderlineView.alpha = self.showsThinUnderlineViewInCompactMode ? compactedRatio : 0.;
  [self.compactUnderlineView jm_bringToFront];
}

- (void)setTitleLabelText:(NSString *)titleLabelText;
{
  self.titleLabel.text = titleLabelText;
  [self applyThemeSettings];
  [self setNeedsLayout];
}

- (void)updateWithActionMenuBarItemView:(JMActionMenuBarItemView *)actionMenuBarItemView;
{
  if (self.customRightButton)
    return;
  
  [self.actionMenuBarItemView removeFromSuperview];
  self.actionMenuBarItemView = nil;
  
  self.actionMenuBarItemView = actionMenuBarItemView;
  [self addSubview:actionMenuBarItemView];
  
  // nasty hack: this method can be called during a transition (ie night/day switch)
  // which can create a visible jump if the actionMenuBar is added during
  // the transition. the following line ensures that the menu bar is added, but
  // offscreen - so that it can be repositioned in the next layout cycle through
  // layoutSubviews
  self.actionMenuBarItemView.left = self.bounds.size.width;
  BSELF(ABCustomOutlineNavigationBar);
  self.actionMenuBarItemView.doDuringBadgeAnimations = ^{
    [blockSelf layoutSubviews];
  };
  
  [self.actionMenuBarItemView.parentMenuView showTrainingBadgesIfNecessaryAnimated:NO];
  
  [self updateSubviewContentsBasedOnHeightAnimated:NO];
  [self applyThemeSettings];
}

- (void)setTitleLabelHidden:(BOOL)titleLabelHidden animated:(BOOL)animated;
{
  BSELF(ABCustomOutlineNavigationBar);
  [UIView jm_animate:^{
    blockSelf.titleLabel.alpha = titleLabelHidden ? 0. : 1.;
  } completion:nil animated:animated];
}

- (void)didLongPressBackButton:(UILongPressGestureRecognizer *)gesture;
{
  if (gesture.state == UIGestureRecognizerStateBegan)
  {
    if (self.onBackButtonHold)
    {
      self.onBackButtonHold();
    }
  }
}

- (void)didTapBackButton;
{
  if (self.customOnBackButtonTap)
  {
    self.customOnBackButtonTap();
  }
  else
  {
    [self.parentViewController jm_dismiss];
  }
}

- (void)didTapModalCloseButton;
{
  if (self.customOnModalCloseTapAction)
  {
    self.customOnModalCloseTapAction();
  }
  else
  {
    [self.parentViewController jm_dismiss];
  }
}

- (void)parentControllerWillBecomeVisible;
{
  [super parentControllerWillBecomeVisible];
  
  JMOutlineViewController *controller = self.parentViewController;
  UINavigationController *navController = controller.navigationController;
  BOOL parentIsTopAndOnlyController = (navController.topViewController == controller && navController.viewControllers.count == 1);
  
  self.backButton.hidden = parentIsTopAndOnlyController && !self.customLeftButton;
  self.modalCloseButton.hidden = !parentIsTopAndOnlyController || !self.parentViewController.presentingViewController;
  [self updateContentsBasedOnHeightAnimated:NO];
}

- (void)parentControllerDidAppear;
{
  [self.actionMenuBarItemView.parentMenuView hideTrainingBadgesIfNecessaryAnimated:YES];
}

- (BOOL)parentViewControllerIsVisible;
{
  if (!self.parentViewController)
    return NO;
  
  JMOutlineViewController *controller = self.parentViewController;
  UINavigationController *navController = controller.navigationController;
  BOOL parentIsTopController = (navController.topViewController == controller);
  return parentIsTopController;
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
{
  BSELF(ABCustomOutlineNavigationBar);

  if (hidden)
  {
    [UIView jm_animate:^{
      blockSelf.alpha = 0;
      JMAnimateStatusBarHidden(YES);
    } completion:^{
      blockSelf.hidden = YES;
    } animated:animated];
  }
  else
  {
    self.hidden = NO;
    [self updateContentsBasedOnHeightAnimated:animated];
    [UIView jm_animate:^{
      blockSelf.alpha = 1.;
    } completion:nil animated:animated];
  }
}

#pragma mark - Common Icons

+ (UIImage *)cancelIcon;
{
  UIImage *icon = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGRect b = CGRectInset(bounds, 11, 11);
    CGFloat barLength = b.size.height;
    CGFloat barWidth = 1.;
    
    CGRect bar1Rect = CGRectCenterWithSize(b, CGSizeMake(barWidth, barLength));
    UIBezierPath *b1Path = [UIBezierPath bezierPathWithRect:bar1Rect];
    
    CGRect bar2Rect = CGRectCenterWithSize(b, CGSizeMake(barLength, barWidth));
    UIBezierPath *b2Path = [UIBezierPath bezierPathWithRect:bar2Rect];
    
    [b1Path appendPath:b2Path];

    [b1Path applyTransform:CGAffineTransformMakeTranslation(-bounds.size.width / 2., -bounds.size.height / 2.)];
    [b1Path applyTransform:CGAffineTransformMakeRotation(M_PI_4)];
    [b1Path applyTransform:CGAffineTransformMakeTranslation(bounds.size.width / 2., bounds.size.height / 2.)];
    [b1Path fill];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(bounds, 7., 7.)];
    [circlePath setLineWidth:1.];
    [circlePath stroke];
  } withSize:CGSizeMake(30., 30.)];
  return icon;
}

+ (UIImage *)addIcon;
{
  UIImage *icon = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGRect b = CGRectInset(bounds, 11, 11);
    CGFloat barLength = b.size.height;
    CGFloat barWidth = 1.;
    
    CGRect bar1Rect = CGRectCenterWithSize(b, CGSizeMake(barWidth, barLength));
    UIBezierPath *b1Path = [UIBezierPath bezierPathWithRect:bar1Rect];
    
    CGRect bar2Rect = CGRectCenterWithSize(b, CGSizeMake(barLength, barWidth));
    UIBezierPath *b2Path = [UIBezierPath bezierPathWithRect:bar2Rect];
    
    [b1Path appendPath:b2Path];
    [b1Path fill];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(bounds, 7., 7.)];
    [circlePath setLineWidth:1.];
    [circlePath stroke];
  } withSize:CGSizeMake(30., 30.)];
  return icon;
}

@end
