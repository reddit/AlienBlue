#import "ABToolbar.h"
#import "UIColor+Hex.h"
#import "Resources.h"
#import "AlienBlueAppDelegate.h"

#define kABToolbarUpArrowSize CGSizeMake(40., 7.)

static BOOL s_showsRibbon;
static UIColor *s_toolbarBackgroundColor;

@interface ABToolbar()
@property BOOL i_showsUpArrow;
@property UIImageView *upArrowImageView;
@property UIImageView *jmShadowImageView;
@end;

@implementation ABToolbar

- (void)registerForNotifications;
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)initializeView;
{
  [self registerForNotifications];
  
  self.clipsToBounds = NO;
  
  UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.bounds.size.width, 4.)];
  shadowView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
  
  UIImage *shadowImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    [UIView jm_drawVerticalShadowGradientWithOpacity:0.06 inRect:bounds];
  } opaque:NO withSize:CGSizeMake(1., 5.) cacheKey:@"toolbar-shadow"];
  
  shadowView.image = shadowImage;
  shadowView.contentMode = UIViewContentModeScaleToFill;
  [self addSubview:shadowView];
  shadowView.bottom = 0.;
  shadowView.transform = CGAffineTransformMakeScale(1, -1);
  shadowView.alpha = 1.;
  self.jmShadowImageView = shadowView;
}

- (void)layoutSubviews;
{
  [super layoutSubviews];
  
  // this is a hacky workaround for when custom views stay at an
  // alpha of 0 after a popover is present from the toolbar (ie. showFromToolbar)
  [[self.items select:^BOOL(UIBarButtonItem *item) {
    return [item.customView isKindOfClass:[UIButton class]];
  }] each:^(UIBarButtonItem *item) {
    item.customView.alpha = 1.;
  }];
  
  [[self subviewsMatchingValidation:^BOOL(UIView *view) {
    return [NSStringFromClass(view.class) jm_contains:@"ToolbarButton"] || [NSStringFromClass(view.class) jm_contains:@"ToolbarTextButton"] ;
  }] each:^(UIView *toolbarButtonView) {
    toolbarButtonView.top = -3;
  }];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
      [self initializeView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
  self = [super initWithFrame:frame];
  if (self)
  {
    [self initializeView];
  }
  return self;
}

- (void)setShowsUpArrow:(BOOL)showsUpArrow;
{
  self.i_showsUpArrow = showsUpArrow;
  if (showsUpArrow)
  {
//    [self updateUpArrowImage];
  }
  self.upArrowImageView.hidden = !showsUpArrow;
}

- (void)setShowsRibbon:(BOOL)showsRibbon;
{
  s_showsRibbon = showsRibbon;
  [self setNeedsDisplay];
}

- (void)setToolbarBackgroundColor:(UIColor *)toolbarBackgroundColor;
{
  s_toolbarBackgroundColor = toolbarBackgroundColor;
  [self setNeedsDisplay];
}

- (void)defaultsChanged:(NSNotification *)notification 
{
  [self setNeedsDisplay];
}

- (void) drawGradientInRect:(CGRect) rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 4;
    CGFloat locations[4] = { 0.0, 0.7, 0.98, 1.0};
	
    CGFloat nightModeComponents[16] = {
		1.0, 1.0, 1.0, 0.35,
		1.0, 1.0, 1.0, 0.06, 
		1.0, 1.0, 1.0, 0.06,
		1.0, 1.0, 1.0, 0.45,
	};
	
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
	    
	glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, nightModeComponents, locations, num_locations);	
	
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), currentBounds.size.height);
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
	
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace); 	
}

- (void)handleTintSwitch;
{
  self.tintColor = [UIColor colorForNavigationBar];
  self.backgroundColor = [UIColor colorForToolbar];
}

- (void)drawGradientFill;
{
  UIColor *startColor = [UIColor tintColorWithWhite:1.1];
  UIColor *endColor = [UIColor tintColorWithWhite:0.8];
  [UIView drawGradientInRect:self.bounds minHeight:0. startColor:startColor endColor:endColor];
}

- (void)drawRect:(CGRect)rect;
{
  [self handleTintSwitch];
  
  [[UIColor colorForToolbar] set];
  [[UIBezierPath bezierPathWithRect:self.bounds] fill];
  
  UIBezierPath * bevelLineOne = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., self.bounds.size.width, 0.5)];
  CGFloat upperBevelLineOpacity = JMIsNight() ? 0.14 : 0.15;
  [[UIColor colorWithWhite:0. alpha:upperBevelLineOpacity] set];
  [bevelLineOne fill];
  
  UIBezierPath * bevelLineTwo = [UIBezierPath bezierPathWithRect:CGRectMake(0., 1., self.bounds.size.width, 1.)];
  CGFloat bevelLineOpacity = JMIsNight() ? 0.10 : 0.15;
  [[UIColor colorWithWhite:1. alpha:bevelLineOpacity] set];
  [bevelLineTwo fill];
  

//  if (s_showsRibbon)
//  {
//    [self drawRibbonOnFourthItem];
//  }
}

- (void)drawRibbonOnFourthItem;
{
  CGFloat xCenterLandscape = JMIsIphone5() ? 412. : 409.;
  CGFloat xCenterRatio = JMLandscape() ? (xCenterLandscape / 568.) : (226. / 320.);
  CGFloat ribbonWidth = JMLandscape() ? 57. : 57.;
  
  CGFloat xCenter = xCenterRatio * self.bounds.size.width + 1.;
  CGRect ribbonRect = CGRectMake(xCenter - ribbonWidth / 2., 0., ribbonWidth, self.bounds.size.height);

  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGFloat shadowOpacity = [Resources isNight] ? 0.8 : 0.8;
  CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 2.f, [[UIColor colorWithWhite:0. alpha:shadowOpacity] CGColor]);
  
  UIBezierPath *ribbonPath = [UIBezierPath bezierPathWithRect:ribbonRect];
  
  UIColor *ribbonColor = [UIColor colorForToolbarRibbon];
  [ribbonColor set];
  [ribbonPath fill];
  
  CGContextRestoreGState(context);
  
  [ribbonPath addClip];
  
  CGRect gradientRect = CGRectIntersection(CGRectMake(0., 0., self.bounds.size.width, 20.), ribbonRect);
  [UIView drawGradientInRect:gradientRect minHeight:0. startColor:[UIColor colorWithWhite:1. alpha:0.3] endColor:[UIColor clearColor]];
  
  UIBezierPath * bevelLine = [UIBezierPath bezierPathWithRect:CGRectMake(0., 1., self.bounds.size.width, 1.)];
  [[UIColor colorWithWhite:1. alpha:0.3] set];
  [bevelLine fill];
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (CGSize)sizeThatFits:(CGSize)size;
{
  CGSize s = [super sizeThatFits:size];
  s.height = 40.;
  return s;
}

@end
