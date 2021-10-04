#import "ABNavigationBar.h"
#import "UIColor+Hex.h"
#import "Resources.h"
#import "AlienBlueAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIApplication+ABAdditions.h"
#import "NavigationBackItemView.h"
#import "UIBarButtonItem+Skin.h"

#define kABNavigationBarButtonItemVerticalPositionOffset (JMIsIOS7() ? 2. : 2.)
#define kABNavigationBarCustomHeight 50.

@interface ABNavigationBar()
@property (assign) BOOL forceDark;
@property (strong) UIImageView *jm_shadowView;
- (void)nightSwitch;
@end

@implementation ABNavigationBar

@synthesize forceDark = forceDark_;

+ (void)initialize;
{
	if (self == [ABNavigationBar class])
  {
    [self setupGlobalAppearanceCustomisations];
	}
}

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)initializeView;
{
  // although it's not kosher, this view can be created in a background thread
  // as part of the sliding navigation image representation
  // we just need to make sure that it doesn't start hooking onto notifications
  // and trying to do night-switching
  if (![NSThread isMainThread])
  {
    return;
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightSwitch) name:kNightModeSwitchNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
 
  self.clipsToBounds = NO;
  
  [self nightSwitch];
  
  [self.jm_shadowView removeFromSuperview];
  self.jm_shadowView = nil;
  
  self.jm_shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.bounds.size.width, 4.)];
  self.jm_shadowView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  
  UIImage *shadowImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    [UIView jm_drawVerticalShadowGradientWithOpacity:0.06 inRect:bounds];
  } opaque:NO withSize:CGSizeMake(1., 5.) cacheKey:@"navigation-bar-shadow"];
 
  self.jm_shadowView.image = shadowImage;
  self.jm_shadowView.contentMode = UIViewContentModeScaleToFill;
  [self addSubview:self.jm_shadowView];
  self.jm_shadowView.top = self.bounds.size.height;
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

+ (UIImage *)ab_barButtonItemBackgroundImage;
{
  NSString *cacheKey = [NSString stringWithFormat:@"bar-button-item-background-%d-%d", JMIsNight(), [Resources skinTheme]];
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
//    CGRect buttonRect = CGRectInset(bounds, 2., 3.);
//    buttonRect.origin.y += kABNavigationBarButtonItemVerticalPositionOffset;
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:3.];
//    UIColor *borderColor = [UIColor colorForTint];
//    [path setLineWidth:JMIsRetina() ? 0.5 : 1.];
//    [borderColor setStroke];
//    [path stroke];
  } opaque:NO withSize:CGSizeMake(30., 30.) cacheKey:cacheKey];
}

+ (UIImage *)ab_barBackButtonItemBackgroundImage;
{
  NSString *cacheKey = [NSString stringWithFormat:@"back-button-item-background-%d-%d", JMIsNight(), [Resources skinTheme]];
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    UIImage *dottedBackImage = [NavigationBackItemView imageForBackButton];
    [dottedBackImage drawAtPoint:CGPointMake(0., 1.)];
  } opaque:NO withSize:CGSizeMake(60, 30.) cacheKey:cacheKey];
}

+ (void)setupGlobalAppearanceCustomisations;
{
  #define kBarButtonAppearance [UIBarButtonItem appearanceWhenContainedIn:[ABNavigationBar class], nil]
  [kBarButtonAppearance setBackgroundImage:[self ab_barButtonItemBackgroundImage] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  [kBarButtonAppearance setTitlePositionAdjustment:UIOffsetMake(0., kABNavigationBarButtonItemVerticalPositionOffset) forBarMetrics:UIBarMetricsDefault];
  [kBarButtonAppearance setBackButtonBackgroundImage:[self ab_barBackButtonItemBackgroundImage] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  [kBarButtonAppearance setTintColor:[UIColor colorForBarButtonItem]];

  [kBarButtonAppearance setTitleTextAttributes:[self barButtonItemTextAttributes] forState:UIControlStateNormal];
  [kBarButtonAppearance setBackButtonBackgroundVerticalPositionAdjustment:2. forBarMetrics:UIBarMetricsDefault];
  [kBarButtonAppearance setBackButtonTitlePositionAdjustment:UIOffsetMake(9., 0.) forBarMetrics:UIBarMetricsDefault];
}

+ (NSDictionary *)barButtonItemTextAttributes;
{
  NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
  [titleAttributes setObject:[UIFont skinFontWithName:kBundleFontNavigationButtonTitle] forKey:UITextAttributeFont];
  [titleAttributes setObject:[UIColor colorForBarButtonItem] forKey:UITextAttributeTextColor];
  [titleAttributes setObject:[UIColor colorForBarButtonItemShadow] forKey:UITextAttributeTextShadowColor];
  [titleAttributes setObject:[NSValue valueWithUIOffset:UIOffsetMake(0., SkinShadowOffsetSize().height)] forKey:UITextAttributeTextShadowOffset];
  return titleAttributes;
}

- (void)customizeAppearanceOfBarButtonItems;
{
  if (![NSThread isMainThread])
  {
    return;
  }
  
  if (!self.superview)
  {
    return;
  }
  
  NSDictionary *titleAttributes = [[self class] barButtonItemTextAttributes];
  BSELF(ABNavigationBar);
  [self.items each:^(UINavigationItem *nItem) {

    [nItem.rightBarButtonItems each:^(UIBarButtonItem *bItem) {
      [bItem setTitleTextAttributes:titleAttributes forState:UIControlStateNormal];
      [bItem setTitleTextAttributes:titleAttributes forState:UIControlStateHighlighted];
      [bItem setBackgroundImage:[[blockSelf class] ab_barButtonItemBackgroundImage] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
      [bItem setTitlePositionAdjustment:UIOffsetMake(0., kABNavigationBarButtonItemVerticalPositionOffset) forBarMetrics:UIBarMetricsDefault];
    }];

    [nItem.leftBarButtonItems each:^(UIBarButtonItem *bItem) {
      [bItem setTitleTextAttributes:titleAttributes forState:UIControlStateNormal];
      [bItem setTitleTextAttributes:titleAttributes forState:UIControlStateHighlighted];
      [bItem setBackgroundImage:[[blockSelf class] ab_barButtonItemBackgroundImage] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
      [bItem setTitlePositionAdjustment:UIOffsetMake(0., kABNavigationBarButtonItemVerticalPositionOffset) forBarMetrics:UIBarMetricsDefault];
    }];
  }];
}

- (void)defaultsChanged:(NSNotification *)notification
{
    // listen for changes in SkinTheme
    [self setNeedsDisplay];
}

- (void)nightSwitch;
{
  if (JMIsIphone())
  {
    [UIApplication ab_updateStatusBarTint];
  }
  
  self.backgroundColor = [UIColor colorForNavigationBar];
  
  [self.items each:^(UINavigationItem *navItem) {
    
    if ([navItem.leftBarButtonItem respondsToSelector:@selector(applyThemeSettings)])
      [navItem.leftBarButtonItem performSelector:@selector(applyThemeSettings) withObject:nil];
    
    if ([navItem.rightBarButtonItem respondsToSelector:@selector(applyThemeSettings)])
      [navItem.rightBarButtonItem performSelector:@selector(applyThemeSettings) withObject:nil];
    
  }];
  
  [[self subviewsOfClass:[UIView class]] each:^(UIView *subview) {
    [subview setNeedsDisplay];
  }];
  
  [self customizeAppearanceOfBarButtonItems];
  [self setNeedsDisplay];
}

- (void) setBarStyle:(UIBarStyle)barStyle;
{
  [super setBarStyle:barStyle];
  [self setNeedsDisplay];
}

- (void)makeDark;
{
  self.forceDark = YES;
  [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
  [UIApplication ab_updateStatusBarTint];
  [self customizeAppearanceOfBarButtonItems];

  [[UIColor colorForNavigationBar] set];
  [[UIBezierPath bezierPathWithRect:CGRectInsetTop(self.bounds, 0.)] fill];

  if (!JMIsIOS7())
  {
    UIBezierPath * statusBarUnderline = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., self.bounds.size.width, 1.)];
    [[UIColor colorWithWhite:0. alpha:0.04] set];
    [statusBarUnderline fill];

    UIBezierPath * bevelLineTop = [UIBezierPath bezierPathWithRect:CGRectMake(0., 1., self.bounds.size.width, 1.)];
    CGFloat bevelLineOpacity = JMIsNight() ? 0.06 : 0.15;
    [[UIColor colorWithWhite:1. alpha:bevelLineOpacity] set];
    [bevelLineTop fill];
  }

  UIBezierPath * bevelLineBottom = [UIBezierPath bezierPathWithRect:CGRectMake(0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5)];
  CGFloat bottomBevelLineOpacity = JMIsNight() ? 0.14 : 0.15;
  [[UIColor colorWithWhite:0. alpha:bottomBevelLineOpacity] set];
  [bevelLineBottom fill];
}

- (CGSize)sizeThatFits:(CGSize)size;
{
  CGSize s = [super sizeThatFits:size];
  s.height = kABNavigationBarCustomHeight;
  return s;
}

- (void)setFrame:(CGRect)frame;
{
  // despite the sizeThatFits override, showing a prompt
  // will set it back to its factory height
  if (frame.size.height == 44.)
  {
    frame.size.height = kABNavigationBarCustomHeight;
  }
  
  // after prompt in landscape
  if (frame.size.height == 32.)
  {
    frame.size.height = kABNavigationBarCustomHeight;
  }
  
  [super setFrame:frame];
}

- (void)didTapCustomBack;
{
  UINavigationController *navController = JMCastOrNil(self.delegate, UINavigationController);
  [navController popViewControllerAnimated:YES];
}

- (void)replaceNativeButtonViewWithCustomVersion:(UIButton *)nativeButtonView;
{
  BOOL isBackButton = nativeButtonView && !self.backItem.backBarButtonItem && !self.topItem.leftBarButtonItem;
  if (isBackButton)
  {
    NavigationBackItemView *backItemView = [[NavigationBackItemView alloc] initWithNavigationItem:self.backItem];
    [backItemView jm_removeGestureRecognizers];
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:backItemView];
    self.topItem.leftBarButtonItem = customItem;
    nativeButtonView.hidden = YES;
    [backItemView addTarget:self action:@selector(didTapCustomBack) forControlEvents:UIControlEventTouchUpInside];
  }
}

- (void)setNeedsLayout;
{
  [super setNeedsLayout];
  
  [self customizeAppearanceOfBarButtonItems];

  BSELF(ABNavigationBar);
  [[self subviewsMatchingValidation:^BOOL(UIView *view) {
    return [NSStringFromClass(view.class) jm_contains:@"NavigationItemButton"];
  }] each:^(UIButton *nativeButtonView) {
    [blockSelf replaceNativeButtonViewWithCustomVersion:nativeButtonView];
  }];
}

- (void)layoutSubviews;
{
  [super layoutSubviews];
  
  CGFloat yOffset = self.bounds.size.height - kABNavigationBarCustomHeight;
  
  UIButton *nativeBackView = [[self subviewsMatchingValidation:^BOOL(UIView *view) {
    return [NSStringFromClass(view.class) jm_contains:@"NavigationItemButton"];
  }] first];
  nativeBackView.left = 0;
  
  UIView *customBackView = [self subviewsOfClass:[NavigationBackItemView class]].first;
  customBackView.top = yOffset - 1.;
  
  UILabel *promptLabel = (UILabel *)[[self jm_subviewsMatchingValidation:^BOOL(UIView *view) {
    return JMIsClass(view, UILabel) && (view.width == 300 || view.width == 548);
  }] first];
  if (promptLabel && !JMIsEmpty(promptLabel.text))
  {
    UILabel *replacementPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10., 10., self.bounds.size.width, 16.)];
    replacementPromptLabel.autoresizingMask = JMFlexibleHorizontalMarginMask;
    replacementPromptLabel.textAlignment = NSTextAlignmentCenter;
    replacementPromptLabel.backgroundColor = [UIColor clearColor];
    replacementPromptLabel.font = promptLabel.font;
    replacementPromptLabel.textColor = [UIColor colorForBarButtonItem];
    replacementPromptLabel.shadowOffset = CGSizeMake(0., 1.);
    replacementPromptLabel.shadowColor = [UIColor colorForInsetDropShadow];
    replacementPromptLabel.text = promptLabel.text;
    promptLabel.text = @"";
    [promptLabel.superview addSubview:replacementPromptLabel];
  }
  
  // layout custom/skinbaritems
  [[self jm_subviewsMatchingValidation:^BOOL(UIView *view) {
    UIButton *b = JMCastOrNil(view, UIButton);
    return b.imageView.image != nil;
  }] each:^(UIView *customButtonItemView) {
    [customButtonItemView centerVerticallyInSuperView];
    customButtonItemView.top -= 3.;
  }];

  // layout system bar items
  [[self jm_subviewsMatchingValidation:^BOOL(UIView *view) {
    BOOL isSystemBarItem = [NSStringFromClass(view.class) jm_contains:@"NavigationItemButton"];
    UIButton *b = JMCastOrNil(view, UIButton);
    return isSystemBarItem && b.titleLabel.text != nil;
  }] each:^(UIView *customButtonItemView) {
    [customButtonItemView centerVerticallyInSuperView];
  }];
  
  [[self jm_subviewsMatchingValidation:^BOOL(UIView *view) {
    return [NSStringFromClass(view.class) jm_contains:@"NavigationButton"];
  }] each:^(UIView *navigationButton) {
    [navigationButton centerVerticallyInSuperView];
    navigationButton.top -= 2.;
  }];

  [[self jm_subviewsMatchingValidation:^BOOL(UIView *view) {
    return [NSStringFromClass(view.class) jm_contains:@"TransparentToolbar"];
  }] each:^(UIView *transparentToolbar) {
    [transparentToolbar centerVerticallyInSuperView];
    transparentToolbar.top -= 8.;
    transparentToolbar.left -= 30.;
  }];

  [[self jm_subviewsOfClass:[UIView class]] each:^(UIView *subview) {
    [subview setNeedsDisplay];
    [subview setNeedsLayout];
  }];
  
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated;
{
  [super setItems:items animated:animated];
  [self setNeedsLayout];
}

@end
