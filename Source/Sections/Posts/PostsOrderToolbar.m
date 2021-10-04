#import "PostsOrderToolbar.h"
#import "Resources.h"
#import "AlienBlueAppDelegate.h"


@interface PostsOrderToolbar() <UITextFieldDelegate>

@property (weak) NSObject<PostsOrderToolbarDelegate> *delegate;
@property (strong) UIImageView *backgroundImageView;
@property (strong) UITextField *searchTextField;
@property (strong) UIButton *sortButton;
@property (strong) UIButton *searchIconButton;
@property (strong) UIButton *scopeButton;
@property (strong) UIButton *modButton;

@property BOOL i_searchActive;
@property BOOL i_scopeRestricted;
@property (readonly) BOOL shouldShowScope;
@property (readonly) BOOL showsModerationIndicator;
@end

@implementation PostsOrderToolbar

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<PostsOrderToolbarDelegate>)delegate;
{
  self = [super initWithFrame:frame];
  if (self)
  {
    self.delegate = delegate;
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.backgroundImageView];
    
    self.scopeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.scopeButton.top = 7.;
    self.scopeButton.size = CGSizeMake(36., 30.);
    self.scopeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.scopeButton addTarget:self action:@selector(scopeButtonTapped) forControlEvents:UIControlEventTouchUpInside];

//    self.scopeButton.backgroundColor = [UIColor greenColor];
    [self addSubview:self.scopeButton];
    
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(44., 6., self.bounds.size.width / 2., self.bounds.size.height - 13.)];
    self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIView *searchTextPaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 14., self.searchTextField.height)];
    UIView *searchTextPaddingRightView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 14., self.searchTextField.height)];
    self.searchTextField.leftView = searchTextPaddingLeftView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextField.rightView = searchTextPaddingRightView;
    self.searchTextField.rightViewMode = UITextFieldViewModeAlways;
    self.searchTextField.font = [UIFont skinFontWithName:kBundleNavbarTitle];
    self.searchTextField.delegate = self;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    [self addSubview:self.searchTextField];
    
    self.searchIconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchIconButton.left = 8.;
    self.searchIconButton.top = 6.;
    [self.searchIconButton addTarget:self action:@selector(searchIconTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.searchIconButton];
    
    self.sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sortButton.height = 30.;
    self.sortButton.top = 6.;
    self.sortButton.right = self.width - 10.;
    self.sortButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.sortButton.titleLabel.font = [UIFont skinFontWithName:kBundleFontPostSubtitleBold];
    self.sortButton.titleLabel.shadowOffset = CGSizeMake(1., 1.);
    self.sortButton.titleLabel.shadowColor = [UIColor colorForBevelDropShadow];
    self.sortButton.titleLabel.textColor = [UIColor whiteColor];
    [self.sortButton addTarget:self action:@selector(sortButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sortButton];

    self.modButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.modButton.height = 40.;
    self.modButton.width = 40.;
    self.modButton.top = 2.;
    self.modButton.right = self.width + 10.;
    self.modButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.modButton addTarget:self action:@selector(modButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.modButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToStyleChangeNotification) name:kNightModeSwitchNotification object:nil];
    [self respondToStyleChangeNotification];
    
    [self setSearchActive:NO animated:NO];
  }
  return self;
}


- (BOOL)shouldShowScope;
{
  return self.i_searchActive && [self.delegate postsOrderToolbarShouldShowScopeIcon:self];
}

- (BOOL)showsModerationIndicator;
{
  return [self.delegate postsOrderToolbarShouldShowModerationIcon:self];
}

- (void)setButtonTitle:(NSString *)title animated:(BOOL)animated;
{
  BSELF(PostsOrderToolbar);

  [UIView jm_animate:^{
    blockSelf.sortButton.width = [title sizeWithFont:[UIFont skinFontWithName:kBundleFontPostSubtitleBold]].width + 34.;
    blockSelf.sortButton.right = blockSelf.width - 10.;

    blockSelf.modButton.hidden = ![blockSelf showsModerationIndicator];
    if (!blockSelf.modButton.hidden)
    {
      blockSelf.modButton.right = blockSelf.sortButton.right + 12.;
      blockSelf.sortButton.right -= 20.;
    }
    
    [blockSelf.sortButton setTitle:title forState:UIControlStateNormal];
    
    blockSelf.scopeButton.right = blockSelf.sortButton.left - 10.;

//    if (!blockSelf.modButton.hidden)
//    {
//      blockSelf.modButton.left = blockSelf.sortButton.left - 13.;
//      blockSelf.scopeButton.right = blockSelf.modButton.left - 10.;
//    }
//    else
//    {
//      blockSelf.modButton.left = blockSelf.sortButton.left;
//    }
    
    CGFloat searchFieldRightEdge = blockSelf.shouldShowScope ? blockSelf.scopeButton.left : blockSelf.sortButton.left;
    
    blockSelf.searchTextField.width = searchFieldRightEdge - 10. - blockSelf.searchTextField.left;
  } completion:nil];
}

- (void)respondToStyleChangeNotification;
{
  self.backgroundImageView.image = [[self class] imageForBarBackground];
  self.searchTextField.background = [[self class] imageForSearchField];
  [self.sortButton setBackgroundImage:[[self class] imageForSortButtonBackgroundHighlighted:NO] forState:UIControlStateNormal];
  [self.sortButton setBackgroundImage:[[self class] imageForSortButtonBackgroundHighlighted:YES] forState:UIControlStateHighlighted];
  
  [self.modButton setImage:[[self class] imageForModIndicatorButton] forState:UIControlStateNormal];
//  self.searchTextField.leftView = iconView;
//  self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
  
  [self.scopeButton setImage:[[self class] imageForScopeButtonHighlighted:NO] forState:UIControlStateNormal];
  [self.scopeButton setImage:[[self class] imageForScopeButtonHighlighted:YES] forState:(UIControlStateDisabled | UIControlStateHighlighted | UIControlStateSelected)];
  [self updateSearchButtonIcon];
  
  self.searchTextField.textColor = [UIColor colorForText];
}

#pragma mark -
#pragma mark - CG drawing for custom components

+ (UIImage *)imageForScopeButtonHighlighted:(BOOL)highlighted;
{
  UIImage *image = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    
    UIColor *iconColor = highlighted ? [UIColor darkGrayColor] : [UIColor grayColor];
    UIImage *scopeIcon = [UIImage skinEtchedIcon:@"subreddit-icon" withColor:iconColor];
    [scopeIcon drawInRect:CGRectCenterWithSize(bounds, scopeIcon.size)];
    
    UIColor *dotColor = [UIColor colorWithWhite:0.5 alpha:0.2];
    UIImage *dottedSeparatorIcon = [UIImage skinIcon:@"dotted-separator-icon" withColor:dotColor];
    [dottedSeparatorIcon drawAtPoint:CGPointMake(-14., 0.)];
    [dottedSeparatorIcon drawAtPoint:CGPointMake(19., 0.)];
  } withSize:CGSizeMake(36., 30.)];
  return image;
}

+ (UIImage *)imageForBarBackground;
{
  UIImage *bgImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    UIColor *bgColor = [UIColor colorForBackground];
    [bgColor set];
    [[UIBezierPath bezierPathWithRect:bounds] fill];
    
//    [[UIColor colorWithWhite:0. alpha:0.015] set];
//    [[UIBezierPath bezierPathWithRect:bounds] fill];
//    
//    CGFloat shadowTransparency = [Resources isNight] ? 0.2 : 0.08;
//    // top shadow
//    [UIView drawGradientInRect:CGRectCropToTop(bounds, 3.) minHeight:0. startColor:[UIColor colorWithWhite:0. alpha:shadowTransparency] endColor:[UIColor clearColor]];
//    
//    // bottom shadow
//    [UIView drawGradientInRect:CGRectCropToBottom(bounds, 3.) minHeight:0. startColor:[UIColor clearColor] endColor:[UIColor colorWithWhite:0. alpha:shadowTransparency]];
//    
//    if (![Resources isNight])
//    {
//      // inner shadow stroke
//      [[UIColor colorWithWhite:0. alpha:0.1] set];
//      [[UIBezierPath bezierPathWithRect:CGRectCropToTop(bounds, 1.)] fill];
//      
//      // drop shadow stroke
//      [[UIColor colorForInsetDropShadow] set];
//      [[UIBezierPath bezierPathWithRect:CGRectCropToBottom(bounds, 1.)] fill];
//    }
  } opaque:YES withSize:CGSizeMake(31., 31.) cacheKey:[NSString stringWithFormat:@"posts_order_toolbar_background-%d", [Resources isNight]]];
  return [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15., 15., 15., 15.)];
}

+ (UIImage *)imageForSearchField;
{
  UIImage *bgImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
//    UIColor *bgColor = [UIColor colorForBackground];
//    [bgColor set];
//    [[UIBezierPath bezierPathWithRect:bounds] fill];
//    [[UIColor colorWithWhite:0. alpha:0.015] set];
//    [[UIBezierPath bezierPathWithRect:bounds] fill];

    UIBezierPath *fieldPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 1., 1.) cornerRadius:5.];
    [[UIColor colorWithWhite:0. alpha:0.07] set];
    [fieldPath fill];
//    [fieldPath addClip];
    
//    [[UIColor colorWithWhite:0. alpha:0.14] set];
//    [fieldPath applyTransform:CGAffineTransformMakeTranslation(0., 1)];
//    [fieldPath stroke];

//    if (![Resources isNight])
//    {
//      [[UIColor colorForInsetDropShadow] set];
//      [fieldPath applyTransform:CGAffineTransformMakeScale(1.1, 1.)];
//      [fieldPath applyTransform:CGAffineTransformMakeTranslation(-1.1, -2)];
//      [fieldPath stroke];
//      [fieldPath setLineWidth:2.];
//    }
    
  } opaque:NO withSize:CGSizeMake(31., 31.) cacheKey:[NSString stringWithFormat:@"posts_order_toolbar_search-bg-%d", [Resources isNight]]];
  return [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15., 15., 15., 15.)];
}

+ (UIImage *)imageForSortButtonBackgroundHighlighted:(BOOL)highlighted;
{
    UIImage *bgImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {

//    [UIView startEtchedDraw];
    UIBezierPath *fieldPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 1., 1.) cornerRadius:5.];
    UIColor *buttonColor = nil;
    if ([Resources isNight])
    {
      buttonColor = highlighted ? [UIColor colorWithHex:0x232323] : [UIColor colorWithHex:0x333333];
    }
    else
    {
      buttonColor = highlighted ? [UIColor colorWithHex:0x868686] : [UIColor colorWithHex:0xb9b9b9];
    }
    [buttonColor set];
    [fieldPath fill];
//    [UIView endEtchedDraw];
  } opaque:NO withSize:CGSizeMake(31., 31.) cacheKey:[NSString stringWithFormat:@"posts_order_toolbar_sort-bg-%d-%d", highlighted, [Resources isNight]]];
  return [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15., 15., 15., 15.)];
}

+ (UIImage *)imageForModIndicatorButton;
{
  BOOL hasPressedButtonBefore = [UDefaults boolForKey:kPostsOrderToolbarTrainingHasTappedModButtonPrefKey];
  
  UIImage *bgImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGRect mRect = CGRectMake(11., 0., 12, bounds.size.height - 1.);
    UIBezierPath *mPath = [UIBezierPath bezierPathWithRoundedRect:mRect cornerRadius:2.];
    
    UIBezierPath *tPath = [UIBezierPath bezierPathWithTriangleCenter:CGPointMake(11., 15.) sideLength:9. angle:-90.];
    
    [mPath appendPath:tPath];
    
    UIColor *stdColor = [Resources isNight] ? [UIColor colorForHighlightedOptions] : [UIColor colorWithHex:0xb9b9b9];
//    UIColor *stdColor = [Resources isNight] ? [UIColor colorForHighlightedOptions] : [UIColor colorForTint];
    UIColor *iconColor = hasPressedButtonBefore ? stdColor : [UIColor colorWithHex:0x960000];
    [iconColor set];
//    UIColor *ribbonColor = [Resources isNight] ? [UIColor colorForHighlightedOptions] : [UIColor colorForTint];
//    [ribbonColor set];
    
    [UIView startEtchedDraw];
    [mPath fill];
    [UIView endEtchedDraw];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextRotateCTM(ctx, -M_PI_2);
    CGContextTranslateCTM(ctx, -23., 13.);
    [[UIColor whiteColor] set];
    [@"MOD" drawAtPoint:CGPointMake(0., 0.) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:7]];
    
    CGContextRestoreGState(ctx);
    
  } opaque:NO withSize:CGSizeMake(25., 30.) cacheKey:[NSString stringWithFormat:@"posts_order_toolbar_mod-bg-%d-%d-%d", [Resources isNight], hasPressedButtonBefore, [Resources skinTheme]]];
  return bgImage;
}

- (void)scopeButtonTapped;
{
  self.i_scopeRestricted = !self.i_scopeRestricted;
  BSELF(PostsOrderToolbar);
  double delayInSeconds = 0.01;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    blockSelf.scopeButton.highlighted = blockSelf.i_scopeRestricted;
  });
  [self.delegate postsOrderToolbar:self didChangeScopeRestriction:self.i_scopeRestricted];
}

- (void)enableScopeByDefault;
{
  self.i_scopeRestricted = YES;
  self.scopeButton.highlighted = YES;
  [self.delegate postsOrderToolbar:self didChangeScopeRestriction:self.i_scopeRestricted];
}

- (void)searchIconTapped;
{
  [self setSearchActive:!self.i_searchActive animated:YES];
}

- (void)sortButtonTapped;
{
  [self.delegate postsOrderToolbar:self didTapOrderButtonWithSearchActive:self.i_searchActive];
}

- (void)modButtonTapped;
{
  [self.delegate postsOrderToolbarDidTapModerationButton:self];
}

- (void)setSearchActive:(BOOL)active animated:(BOOL)animated;
{
  BSELF(PostsOrderToolbar);
  
  self.i_searchActive = active;
  
  if (!active)
  {
    self.searchTextField.text = @"";
  }
  
  [self.delegate postsOrderToolbar:blockSelf willChangeSearchActive:active animated:animated];
  
  BOOL showsScope = (active && [self.delegate postsOrderToolbarShouldShowScopeIcon:self]);
  
  [UIView jm_transition:self.searchIconButton options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
    [blockSelf updateSearchButtonIcon];
  } completion:^{
    [blockSelf.delegate postsOrderToolbar:blockSelf didChangeSearchActive:active animated:animated];
  } animated:animated];
  
  [UIView jm_animate:^{
    blockSelf.scopeButton.alpha = showsScope ? 1. : 0.;
  } completion:nil animated:animated];
  
  if (active)
  {
    [blockSelf.searchTextField becomeFirstResponder];
  }
  else
  {
    [blockSelf.searchTextField resignFirstResponder];
  }

}

- (void)updateSearchButtonIcon;
{
  NSString *searchIconName = self.i_searchActive ? @"cancel-icon" : @"search-icon";
  UIColor *iconColor = [Resources isNight] ? [UIColor darkGrayColor] : [UIColor grayColor];
  UIImage *searchIcon = [UIImage skinEtchedIcon:searchIconName withColor:iconColor];
  [self.searchIconButton setImage:searchIcon forState:UIControlStateNormal];
  [self.searchIconButton sizeToFit];
}

- (void)cancelActiveSearch;
{
  if (self.searchTextField.isFirstResponder)
  {
    [self setSearchActive:NO animated:YES];
  }
}

- (void)focusOnSearchField;
{
  if (!self.searchTextField.isFirstResponder)
  {
    [self.searchTextField becomeFirstResponder];
  }

  if (self.shouldShowScope)
  {
    [self enableScopeByDefault];
  }
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
  [textField resignFirstResponder];

  if (![textField.text isEmpty])
  {
    [self.delegate postsOrderToolbar:self didEnterSearchQuery:textField.text];
  }
  else
  {
    [self setSearchActive:NO animated:YES];
  }
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
  [self setSearchActive:YES animated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
  textField.keyboardAppearance = JMIsNight() ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDefault;
  return YES;
}

@end
