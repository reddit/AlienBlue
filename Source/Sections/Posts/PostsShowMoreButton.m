#import "PostsShowMoreButton.h"
#import "JMSlider.h"
#import "Resources.h"
#import "UIImage+Skin.h"

@implementation PostsShowMoreButton

@synthesize showGrips = showGrips_;
@synthesize forceDark = forceDark_;

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (id)initForSlider:(JMSlider *)slider withTitle:(NSString *)title;
{
    self = [super initForSlider:slider withTitle:title];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];        
    }
    return self;
}

- (void)defaultsChanged:(NSNotification *)notification 
{
    // listen for changes in SkinTheme
    [self setNeedsDisplay];
}


- (void)drawButtonInRect:(CGRect)rect;
{
    if (self.activityView)
    {
      UIColor *bgColor = [UIColor colorForBackground];
      [bgColor setFill];

      CGRect circularRect = CGRectCenterWithSize(self.bounds, CGSizeMake(39., 39.));
      circularRect = CGRectOffset(circularRect, 0.5, 0.);
      UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circularRect];
      [circlePath fill];
      [[UIColor colorWithWhite:0.5 alpha:0.2] setStroke];
      [circlePath stroke];
      return;
    }
  
    UIColor * backgroundColor = [UIColor colorForBackground];
    [backgroundColor set];
    UIBezierPath * backgroundPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:(self.bounds.size.height / 2.)];
    [backgroundPath fill];
    [[UIColor colorWithWhite:0.5 alpha:0.2] setStroke];
    [backgroundPath stroke];
  
    if (self.highlighted)
    {
        [[UIColor colorWithWhite:0.5 alpha:0.3] setStroke];
        [backgroundPath stroke];

//        UIColor * outlineColor = [Resources isNight] ? [UIColor lightGrayColor] : kJMButtonOutlineColor;
//        [outlineColor set];
//        UIBezierPath * outline = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, -3., -3.) cornerRadius:6];
//        [outline stroke];
    }
    
    if (!self.activityView)
    {
        CGFloat textOpacity = 1. - fabs([self.slider slideRatio]);
        UIColor *textColor = [[UIColor colorForHighlightedText] colorWithAlphaComponent:textOpacity];
        [textColor set];
        [self.title drawInRect:CGRectOffset(rect, 0, kJMButtonPadding.height -1.) withFont:kJMButtonFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
    }
    
    if (self.showGrips)
    {
        UIImage *grips = [UIImage skinImageNamed:@"icons/comment-entry/iphone/grips-normal.png"];
        [grips drawAtPoint:CGPointMake(rect.origin.x + 5., rect.origin.y + 5.) blendMode:kCGBlendModeNormal alpha:0.4];
        [grips drawAtPoint:CGPointMake(rect.size.width + rect.origin.x - 20., rect.origin.y + 5.) blendMode:kCGBlendModeNormal alpha:0.4];
    }
}
  
- (NSString *)accessibilityLabel;
{
  return @"More";
}

- (NSString *)accessibilityIdentifier;
{
  return @"Load More Button";
}

- (BOOL)isAccessibilityElement
{
  return YES;
}

- (void)setLoading:(BOOL)loading;
{
  [super setLoading:loading];
  self.activityView.activityIndicatorViewStyle = JMIsNight() ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
  [self.activityView centerInSuperView];
  self.activityView.left += 1.;
  [self setNeedsDisplay];
}

@end
