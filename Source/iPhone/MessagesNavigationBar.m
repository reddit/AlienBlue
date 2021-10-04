#import "MessagesNavigationBar.h"
#import "OverlayViewContainer.h"

@interface MessagesNavigationBar()
@property (weak) UIView *boxTabView;
@property (strong) OverlayViewContainer *boxSelectorDividerView;
@end

@implementation MessagesNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
  JM_SUPER_INIT(initWithFrame:frame);

  self.boxSelectorDividerView = [[OverlayViewContainer alloc] initWithSize:CGSizeMake(self.bounds.size.width - 100, 7.)];
  JMViewOverlay *dividerOverlay = [JMViewOverlay overlayWithFrame:self.boxSelectorDividerView.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    UIBezierPath *dividerPath = [UIBezierPath bezierPath];
    
    CGFloat dividerThickness = 1.;
    CGSize s = CGSizeMake(bounds.size.width, bounds.size.height - dividerThickness);
    CGPoint centerPoint = CGPointCenterOfRect(bounds);
    CGFloat arrowLength = 10.;

    // top path section
    [dividerPath moveToPoint:CGPointMake(0., s.height)];
    [dividerPath addLineToPoint:CGPointMake(centerPoint.x - arrowLength, s.height)];
    [dividerPath addLineToPoint:CGPointMake(centerPoint.x, 0)];
    [dividerPath addLineToPoint:CGPointMake(centerPoint.x + arrowLength, s.height)];
    [dividerPath addLineToPoint:CGPointMake(s.width, s.height)];

    // bottom path section for closed path
    [dividerPath addLineToPoint:CGPointMake(s.width, s.height + dividerThickness)];
    [dividerPath addLineToPoint:CGPointMake(centerPoint.x + arrowLength - dividerThickness, s.height + dividerThickness)];
    [dividerPath addLineToPoint:CGPointMake(centerPoint.x, dividerThickness)];
    [dividerPath addLineToPoint:CGPointMake(centerPoint.x - arrowLength + dividerThickness, s.height + dividerThickness)];

    [dividerPath addLineToPoint:CGPointMake(0., s.height + dividerThickness)];
    
    [dividerPath closePath];

    UIImage *horizontalGradient = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
      [UIView jm_drawReflectedHorizontalGradientInRect:bounds withColor:[UIColor blackColor] minimumCenterFillRatio:0.7];
    } withSize:bounds.size];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, bounds, horizontalGradient.CGImage);
    
    [[UIColor colorForDivider] setFill];
    [dividerPath fill];
  }];
  dividerOverlay.autoresizingMask = JMFlexibleSizeMask;
  [self.boxSelectorDividerView addOverlay:dividerOverlay];
  self.boxSelectorDividerView.backgroundColor = [UIColor clearColor];
  self.boxSelectorDividerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self addSubview:self.boxSelectorDividerView];
  
  UIImage *tickIcon = [UIImage skinIcon:@"small-tick-icon" withColor:[UIColor whiteColor]];
  BSELF(MessagesNavigationBar);
  [self setCustomLeftButtonWithIcon:tickIcon onTapAction:^{
    [blockSelf didTapMarkAsReadButton];
  }];
  
  return self;
}

- (void)didTapMarkAsReadButton;
{
  if (self.onMarkAsReadTap)
  {
    self.onMarkAsReadTap();
  }
}


- (void)layoutSubviews;
{
  [super layoutSubviews];
  self.boxSelectorDividerView.top = 90.;
  [self.boxSelectorDividerView centerHorizontallyInSuperView];
  
  self.boxTabView.top = 100.;
  [self.boxTabView centerHorizontallyInSuperView];
}

- (void)updateSubviewContentsBasedOnHeightAnimated:(BOOL)animated;
{
  [super updateSubviewContentsBasedOnHeightAnimated:animated];
}

- (CGFloat)defaultBarHeight;
{
  return self.maximumBarHeight;
}

- (CGFloat)maximumBarHeight;
{
  return 150.;
}

- (void)attachBoxTabView:(UIView *)boxTabView;
{
  [self.boxTabView removeFromSuperview];
  
  self.boxTabView = boxTabView;
  self.boxTabView.transform = CGAffineTransformMakeScale(0.78, 0.78);
  [self addSubview:self.boxTabView];
  [self.boxTabView jm_sendToBack];
  
  [self setNeedsLayout];
}

@end
