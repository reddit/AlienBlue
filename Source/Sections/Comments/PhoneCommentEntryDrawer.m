#import "PhoneCommentEntryDrawer.h"
#import "UIImage+Skin.h"
#import "Resources.h"

#define kDrawerContentHeight 50.
#define kDrawerPageMargin CGSizeMake(24.,0.)

#define kDrawerCenterGripLeftTag 534
#define kDrawerCenterGripRightTag 535

typedef enum PCEDGripSide {
    PCEDGripSideLeft,
    PCEDGripSideRight
} PCEDGripSide;

@interface PhoneCommentEntryDrawer() <UIGestureRecognizerDelegate>
@property CGFloat edgeExtensionDragStartX;
@property CGFloat edgeExtensionInitialScrollOffsetX;
@property BOOL isHidingGrips;
@property (nonatomic,strong) UIImageView *bgImage;
@property (nonatomic,strong) UIImageView *arrowImage;
@property (nonatomic,strong) UIView *paneLeft;
@property (nonatomic,strong) UIView *paneCenter;
@property (nonatomic,strong) UIView *paneRight;
@property (assign) NSUInteger page;
@property (assign) BOOL collapsed;
- (void)setHighlighted:(BOOL)highlighted;
- (void)createSubviewsInFrame:(CGRect)frame;
- (void)scrollToPage:(NSUInteger)pageIndex;
- (void)addGripImageToView:(UIView *)view onSide:(PCEDGripSide)side withTag:(NSUInteger)tag;
@end

@implementation PhoneCommentEntryDrawer

@synthesize delegate = delegate_;
@synthesize collapsed = collapsed_;
@synthesize arrowImage = arrowImage_;
@synthesize bgImage = bgImage_;
@synthesize scrollView = scrollView_;
@synthesize paneLeft = paneLeft_;
@synthesize paneCenter = paneCenter_;
@synthesize paneRight = paneRight_;
@synthesize page = page_;

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.delegate = nil;
    
}

- (id)initWithFrame:(CGRect)frame;
{
    if ((self = [super initWithFrame:frame]))
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self createSubviewsInFrame:frame];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)didRotate:(NSNotification *)notification;
{
    [self performSelector:@selector(correctOffsetAfterRotation) withObject:nil afterDelay:0.4];
}

- (void)updateScrollViewPanes;
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 3., kDrawerContentHeight);
    
    CGSize boundSize = self.scrollView.bounds.size;
    
    self.paneLeft.frame = CGRectMake(0. * boundSize.width, 0, boundSize.width, boundSize.height);
    self.paneCenter.frame = CGRectMake(1. * boundSize.width, 0, boundSize.width, boundSize.height);
    self.paneRight.frame = CGRectMake(2. * boundSize.width, 0, boundSize.width, boundSize.height);
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    [self updateScrollViewPanes];
}

#pragma mark - View Creation

- (void)addGripImageToView:(UIView *)view onSide:(PCEDGripSide)side withTag:(NSUInteger)tag;
{
    UIImage *gripImage = [UIImage skinImageNamed:@"icons/comment-entry/iphone/grips-normal.png"];
    UIImageView *gripImageView = [[UIImageView alloc] initWithImage:gripImage];
    if (side == PCEDGripSideLeft)
    {
        gripImageView.frame = CGRectMake(3., 0, gripImage.size.width, gripImage.size.height);
    }
    else if (side == PCEDGripSideRight)
    {
        gripImageView.frame = CGRectMake(view.bounds.size.width - gripImage.size.width - 3., 0, gripImage.size.width, gripImage.size.height);
        gripImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    gripImageView.alpha = 0.8;
    gripImageView.tag = tag;
    [view addSubview:gripImageView];
    [gripImageView centerVerticallyInSuperView];
}

- (void)createSubviewsInFrame:(CGRect)frame;
{
    self.bgImage = [[UIImageView alloc] initWithFrame:self.bounds];
    self.bgImage.frame = CGRectOffset(self.bgImage.frame, -5., 0);
    self.bgImage.contentMode = UIViewContentModeCenter;
    self.bgImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.bgImage];
    
    self.arrowImage = [[UIImageView alloc] initWithFrame:self.bounds];
    UIImage *arrowImage = [[self class] arrowImageForDrawerHighlighted:NO];
    self.arrowImage.image = arrowImage;
    [self.arrowImage sizeToFit];
    [self addSubview:self.arrowImage];
    [self.arrowImage centerHorizontallyInSuperView];
    self.arrowImage.frame = CGRectOffset(self.arrowImage.frame, 0, 70.);
    self.arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    [self setHighlighted:NO];
  
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 12., self.bounds.size.width, kDrawerContentHeight)];
    self.scrollView.autoresizesSubviews = YES;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.paneLeft = [[UIView alloc] init];
    self.paneCenter = [[UIView alloc] init];
    self.paneRight = [[UIView alloc] init];
    
    [self.scrollView addSubview:self.paneLeft];
    [self.scrollView addSubview:self.paneCenter];
    [self.scrollView addSubview:self.paneRight];

    [self updateScrollViewPanes];
    
    [self addGripImageToView:self.paneCenter onSide:PCEDGripSideLeft withTag:kDrawerCenterGripLeftTag];
    [self addGripImageToView:self.paneCenter onSide:PCEDGripSideRight withTag:kDrawerCenterGripRightTag];
    [self addGripImageToView:self.paneLeft onSide:PCEDGripSideRight withTag:0];
    [self addGripImageToView:self.paneRight onSide:PCEDGripSideLeft withTag:0];
    
    self.scrollView.delegate = self;
  
    [self scrollToPage:1];
    
    [self addSubview:self.scrollView];

  if (JMIsIOS7())
  {
    // fix iOS 7 not passing touch events through to scrollview near top
    // of the screen
    self.scrollView.panGestureRecognizer.enabled = NO;
    UIPanGestureRecognizer *edgeExtensionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    edgeExtensionPanGesture.delaysTouchesBegan = NO;
    edgeExtensionPanGesture.delaysTouchesEnded = NO;
    edgeExtensionPanGesture.delegate = self;
    [self addGestureRecognizer:edgeExtensionPanGesture];
  }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
  return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
{
  if (JMIsClass(gestureRecognizer, UIPanGestureRecognizer))
  {
    NSUInteger touches = [gestureRecognizer numberOfTouches];
    CGFloat x = (touches > 0) ? [gestureRecognizer locationOfTouch:0 inView:self].x : [gestureRecognizer locationInView:self].x;
    
    BOOL isOverLeftGrip = x < 50;
    BOOL isOverRightGrip = x > self.bounds.size.width - 50.;
    if (!isOverLeftGrip && !isOverRightGrip)
      return NO;
  }
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
  return YES;
}

- (void)didPan:(UIPanGestureRecognizer *)gesture;
{
  if (self.collapsed)
    return;
  
  NSUInteger touches = [gesture numberOfTouches];
  CGFloat x = (touches > 0) ? [gesture locationOfTouch:0 inView:self].x : [gesture locationInView:self].x;

  if (gesture.state == UIGestureRecognizerStateBegan)
  {
 
    self.edgeExtensionDragStartX = x;
    self.edgeExtensionInitialScrollOffsetX = self.scrollView.contentOffset.x;
  }

  CGFloat dragOffset = x - self.edgeExtensionDragStartX;
  CGFloat scrollOffsetX = self.edgeExtensionInitialScrollOffsetX - dragOffset;

  if (gesture.state == UIGestureRecognizerStateChanged)
  {
    
    BOOL hitRightEdge = (scrollOffsetX + self.scrollView.bounds.size.width) > self.scrollView.contentSize.width;
    BOOL hitLeftEdge = scrollOffsetX < 0.;
    
    if (!(hitRightEdge || hitLeftEdge || self.isHidingGrips))
    {
      [self.scrollView setContentOffset:CGPointMake(scrollOffsetX, 0.)];
    }
  }
}



- (void)fadeGripsIn;
{
    self.isHidingGrips = NO;
    [self.paneCenter viewWithTag:kDrawerCenterGripLeftTag].alpha = 0.7;
    [self.paneCenter viewWithTag:kDrawerCenterGripRightTag].alpha = 0.7;
}

- (void)fadeGripsOut;
{
    self.isHidingGrips = YES;
    [self.paneCenter viewWithTag:kDrawerCenterGripLeftTag].alpha = 0.;
    [self.paneCenter viewWithTag:kDrawerCenterGripRightTag].alpha = 0.;
}

#pragma mark - Setting Panes

- (void)setCenterView:(UIView *)view;
{
    view.frame = CGRectInset(self.paneCenter.bounds, kDrawerPageMargin.width, kDrawerPageMargin.height);
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.paneCenter addSubview:view];
}

- (void)setLeftView:(UIView *)view;
{
    view.frame = CGRectInset(self.paneLeft.bounds, kDrawerPageMargin.width, kDrawerPageMargin.height);
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.paneLeft addSubview:view];
}

- (void)setRightView:(UIView *)view;
{
    view.frame = CGRectInset(self.paneRight.bounds, 20., 0);
    view.frame = CGRectOffset(view.frame, 12., 2);
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.paneRight addSubview:view];
    [view setNeedsLayout];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    self.page = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
}

- (void)scrollToPage:(NSUInteger)pageIndex;
{
    self.page = pageIndex;
    [self.scrollView setContentOffset:CGPointMake(pageIndex * self.scrollView.bounds.size.width, 0) animated:YES];
}

- (void)correctOffsetAfterRotation;
{
    [self scrollToPage:self.page];
}

- (void)toggleDrawerAnimated:(BOOL)animated;
{
    self.collapsed = !self.collapsed;
    
    if (self.collapsed)
    {
        [self.delegate performSelector:@selector(drawerWillCollapse:) withObject:self afterDelay:0.6];
    }
    else
    {
        [self.delegate performSelector:@selector(drawerWillExpand:) withObject:self];        
    }
    
    if (animated)
    {
        [UIView beginAnimations:@"commentDrawer" context:(__bridge void *)(self)];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
    }
    CGFloat yOffset = self.collapsed ? -1 * kDrawerContentHeight - 14. : -14.;
    CGFloat arrowRotation = self.collapsed ? M_PI : 2 * M_PI;
    self.arrowImage.transform = CGAffineTransformMakeRotation(arrowRotation);
    self.frame = CGRectMake(self.frame.origin.x, yOffset, self.frame.size.width, self.frame.size.height);
    [self correctOffsetAfterRotation];
    if (animated)
    {
        [UIView commitAnimations];        
    }
}

#pragma mark - Touch Events

- (BOOL)isTouchingTab:(NSSet *)touches;
{
	CGPoint currentTouchPoint = [[touches anyObject] locationInView:self];
    if ((currentTouchPoint.x > self.center.x - 35.) &&  (currentTouchPoint.x < self.center.x + 35.))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (UIImage *)arrowImageForDrawerHighlighted:(BOOL)highlighted;
{
  NSString *cacheKey = [NSString stringWithFormat:@"comment-entry-drawer-arrow-%d-%d-%d", JMIsNight(), highlighted, [Resources skinTheme]];
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    UIBezierPath *arrowPath = [UIBezierPath bezierPathWithTriangleCenter:CGPointCenterOfRect(bounds) sideLength:8. angle:0.];
    UIColor *arrowColor = highlighted ? [UIColor colorForHighlightedOptions] : [UIColor grayColor];
    [arrowColor setFill];
    
    [arrowPath fill];
   
  } opaque:NO withSize:CGSizeMake(15., 15.) cacheKey:cacheKey];
}

+ (UIImage *)backgroundImageForDrawerHighlighted:(BOOL)highlighted;
{
//    UIImage * drawerImage = highlighted ? [UIImage skinImageNamed:@"icons/comment-entry/iphone/drawer-highlighted.png"] : [UIImage skinImageNamed:@"icons/comment-entry/iphone/drawer-normal.png"];
  NSString *cacheKey = [NSString stringWithFormat:@"comment-entry-drawer-bg-%d-%d-%d", JMIsNight(), highlighted, [Resources skinTheme]];
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    UIBezierPath* drawerPath = [UIBezierPath bezierPath];
    [drawerPath moveToPoint: CGPointMake(680.88, 65.54)];
    [drawerPath addLineToPoint: CGPointMake(443.63, 65.54)];
    [drawerPath addCurveToPoint: CGPointMake(384.08, 65.54) controlPoint1: CGPointMake(443.63, 65.54) controlPoint2: CGPointMake(390.61, 65.54)];
    [drawerPath addCurveToPoint: CGPointMake(356.89, 92.73) controlPoint1: CGPointMake(370.2, 65.54) controlPoint2: CGPointMake(371.27, 92.73)];
    [drawerPath addCurveToPoint: CGPointMake(342.56, 92.73) controlPoint1: CGPointMake(342.51, 92.73) controlPoint2: CGPointMake(348.38, 92.73)];
    [drawerPath addCurveToPoint: CGPointMake(328.24, 92.73) controlPoint1: CGPointMake(336.75, 92.73) controlPoint2: CGPointMake(342.33, 92.73)];
    [drawerPath addCurveToPoint: CGPointMake(301.05, 65.54) controlPoint1: CGPointMake(314.16, 92.73) controlPoint2: CGPointMake(314.56, 65.54)];
    [drawerPath addCurveToPoint: CGPointMake(241.49, 65.54) controlPoint1: CGPointMake(294.52, 65.54) controlPoint2: CGPointMake(241.49, 65.54)];
    [drawerPath addLineToPoint: CGPointMake(-10.5, 65.54)];
    [drawerPath addLineToPoint: CGPointMake(-10.5, -1.5)];
    [drawerPath addLineToPoint: CGPointMake(680.88, -1.5)];
    [drawerPath addLineToPoint: CGPointMake(680.88, 65.54)];
    [drawerPath closePath];
    drawerPath.miterLimit = 4;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadow(UIGraphicsGetCurrentContext(), CGSizeMake(0., 1.), 1.);
    
    UIColor *baseColor = JMIsNight() ? [UIColor colorWithWhite:0.1 alpha:1.] : [UIColor colorWithWhite:0.2 alpha:1.];
    UIColor *bgColor = baseColor;
    
    [bgColor setFill];
    [drawerPath fill];
    CGContextRestoreGState(context);
    
    UIColor *strokeColor = highlighted ? [UIColor colorForHighlightedOptions] : [UIColor grayColor];
    [strokeColor setStroke];

    [drawerPath setLineWidth:highlighted ? 3. : 2.];
    [drawerPath stroke];
  } opaque:NO withSize:CGSizeMake(674., 100.) cacheKey:cacheKey];
}

- (void)setHighlighted:(BOOL)highlighted;
{
  self.bgImage.image = [[self class] backgroundImageForDrawerHighlighted:highlighted];
  self.arrowImage.image = [[self class] arrowImageForDrawerHighlighted:highlighted];
//  UIImage * drawerImage = highlighted ? [UIImage skinImageNamed:@"icons/comment-entry/iphone/drawer-highlighted.png"] : [UIImage skinImageNamed:@"icons/comment-entry/iphone/drawer-normal.png"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [super touchesBegan:touches withEvent:event];
    if ([self isTouchingTab:touches])
    {
        [self setHighlighted:YES];
    }
    else
    {
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [self setHighlighted:NO];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [super touchesEnded:touches withEvent:event];
    if ([self isTouchingTab:touches])
    {
        [self setHighlighted:NO];
        [self toggleDrawerAnimated:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [super touchesMoved:touches withEvent:event];
    [self setHighlighted:NO];
}

//-(void)drawRect:(CGRect)rect;
//{
//    UIImage * drawerImage = self.highlighted ? [UIImage skinImageNamed:@"icons/comment-entry/iphone/drawer-highlighted.png"] : [UIImage skinImageNamed:@"icons/comment-entry/iphone/drawer-normal.png"];
//    [drawerImage drawAtPoint:CGPointMake(0, 0)];
//}

@end
