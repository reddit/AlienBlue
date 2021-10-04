#import "ABTableCellDrawerView.h"
#import "ABBundleManager.h"
#import "UIImage+Skin.h"
#import "Resources.h"

#define kABTableCellDrawerHorizontalMargin 0.

@interface ABTableCellDrawerView()
@property (nonatomic,strong) UIImageView * backgroundImageView;
@property (nonatomic,strong) NSMutableArray *buttons;
@end

@implementation ABTableCellDrawerView

@synthesize backgroundImageView = backgroundImageView_;
@synthesize node = node_;
@synthesize buttons = buttons_;
@synthesize delegate = delegate_;

- (void)dealloc;
{
    self.delegate = nil;
}

- (id)initWithNode:(NSObject *)node;
{
    CGRect frame = CGRectMake(0,0,320., kABTableCellDrawerHeight);
    self = [super initWithFrame:frame];
    if (self)
    {
        self.buttons = [NSMutableArray array];
        self.node = node;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

        UIImage *bgImage = [self generateBackgroundImage];
//        UIImage * bgImage = [[UIImage skinImageNamed:@"backgrounds/drawer-stretchable.png"] jm_resizableImageWithCapInsets:UIEdgeInsetsMake(30., 130., 30., 130.) resizingMode:UIImageResizingModeTile];
        self.backgroundImageView = [[UIImageView alloc] initWithImage:bgImage];
        self.backgroundImageView.frame = self.bounds;
        self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.backgroundImageView];
    }
    return self;
}

- (UIImage *)generateBackgroundImage;
{
  NSString *cacheKey = [NSString stringWithFormat:@"cell-drawer-bg-%d", JMIsNight()];
  UIImage *bgImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {

    [[UIColor colorForBackground] set];
    [[UIBezierPath bezierPathWithRect:bounds] fill];

    // darkened overlay
//    [[UIColor colorWithWhite:0. alpha:0.15] set];
//    [[UIBezierPath bezierPathWithRect:bounds] fill];

    
    // inner shadow
    CGFloat innerShadowOpacity = JMIsNight() ? 0.015 : 0.05;
    [[UIColor colorWithWhite:0. alpha:innerShadowOpacity] set];
    [[UIBezierPath bezierPathWithRect:CGRectCropToTop(bounds, 1.)] fill];
    
    // drop shadow
    CGFloat dropShadowOpacity = JMIsNight() ? 0.015 : 0.2;
    [[UIColor colorWithWhite:1. alpha:dropShadowOpacity] set];
    [[UIBezierPath bezierPathWithRect:CGRectCropToBottom(bounds, 1.)] fill];
    
  } opaque:YES withSize:CGSizeMake(40, 41) cacheKey:cacheKey];
  return bgImage;
}

- (UIButton *)createDrawerButtonWithIconName:(NSString *)iconName highlightColor:(UIColor *)highlightColor target:(id)target action:(SEL)action;
{
  UIImage *rawIcon = [UIImage skinIcon:iconName];
  UIColor *defaultColor = JMIsNight() ? [UIColor colorWithWhite:0.5 alpha:1.] : [UIColor colorWithWhite:0.6 alpha:1.];
//  UIColor *innerShadowColor = JMIsNight() ? [UIColor clearColor] : [UIColor blackColor];
//  UIColor *dropShadowColor = JMIsNight() ? [UIColor blackColor] : [UIColor whiteColor];
  
//  UIColor *innerShadowColor = JMIsIpad() ? [UIColor clearColor] : [UIColor colorForInsetInnerShadow];
//  UIColor *dropShadowColor = [UIColor colorForInsetDropShadow];

  UIImage *decoratedDefaultIcon = [UIImage jm_coloredImageFromImage:rawIcon fillColor:defaultColor];
  UIImage *decoratedHighlightedIcon = [UIImage jm_coloredImageFromImage:rawIcon fillColor:highlightColor];
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button setImage:decoratedDefaultIcon forState:UIControlStateNormal];
  [button setImage:decoratedHighlightedIcon forState:UIControlStateHighlighted];
  
  button.size = CGSizeMake(60, 50);
  
  [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  
  return button;
}

- (CGFloat)totalItemWidth;
{
    CGFloat itemWidths = 0.;
    for (UIView * button in self.buttons)
    {
//        [button sizeToFit];
        itemWidths += button.frame.size.width;
    }
    return itemWidths;
} 

- (void)layoutSubviews;
{
    [super layoutSubviews];
    CGFloat itemWidths = [self totalItemWidth];
    CGFloat boundaryWidth = self.bounds.size.width - (2 * kABTableCellDrawerHorizontalMargin);
    CGFloat xPadding = (boundaryWidth - itemWidths) / ([self.buttons count] - 1);

    CGFloat xOffset = kABTableCellDrawerHorizontalMargin;
    for (UIView * button in self.buttons)
    {
        button.frame = CGRectMake(xOffset, 0, button.frame.size.width,  button.frame.size.height);
        [button centerVerticallyInSuperView];
        xOffset += button.frame.size.width + xPadding;
        button.frame = CGRectIntegral(button.frame);
    }
}

- (void)addButton:(UIButton *)button;
{
    [self.buttons addObject:button];
    [self addSubview:button];
    [self setNeedsLayout];
}

@end
