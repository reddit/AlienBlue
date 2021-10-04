//  REDListingOrderToolbar.m
//  RedditApp

#import "RedditApp/Listing/REDListingOrderToolbar.h"

#import "Common/AppDelegate/AlienBlueAppDelegate.h"
#import "Helpers/Resources.h"

@interface REDListingOrderToolbar ()<UITextFieldDelegate>

@property(weak) NSObject<REDListingOrderToolbarDelegate> *delegate;
@property(strong) UIImageView *backgroundImageView;
@property(strong) UIButton *sortButton;
@property(strong) UIButton *modButton;

@property(readonly) BOOL showsModerationIndicator;
@end

@implementation REDListingOrderToolbar

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kNightModeSwitchNotification
                                                object:nil];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<REDListingOrderToolbarDelegate>)delegate;
{
  self = [super initWithFrame:frame];
  if (self) {
    self.delegate = delegate;

    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    self.backgroundImageView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.backgroundImageView];

    self.sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sortButton.height = 30.;
    self.sortButton.top = 6.;
    self.sortButton.right = self.width - 10.;
    self.sortButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.sortButton.titleLabel.font = [UIFont skinFontWithName:kBundleFontPostSubtitleBold];
    self.sortButton.titleLabel.shadowOffset = CGSizeMake(1., 1.);
    self.sortButton.titleLabel.shadowColor = [UIColor colorForBevelDropShadow];
    self.sortButton.titleLabel.textColor = [UIColor whiteColor];
    [self.sortButton addTarget:self
                        action:@selector(sortButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sortButton];

    self.modButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.modButton.height = 40.;
    self.modButton.width = 40.;
    self.modButton.top = 2.;
    self.modButton.right = self.width + 10.;
    self.modButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.modButton addTarget:self
                       action:@selector(modButtonTapped)
             forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.modButton];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(respondToStyleChangeNotification)
                                                 name:kNightModeSwitchNotification
                                               object:nil];
    [self respondToStyleChangeNotification];
  }
  return self;
}

- (BOOL)showsModerationIndicator;
{ return [self.delegate listingOrderToolbarShouldShowModerationIcon:self]; }

- (void)setButtonTitle:(NSString *)title animated:(BOOL)animated;
{
  BSELF(REDListingOrderToolbar);

  [UIView jm_animate:^{
      blockSelf.sortButton.width =
          [title sizeWithFont:[UIFont skinFontWithName:kBundleFontPostSubtitleBold]].width + 34.;
      blockSelf.sortButton.right = blockSelf.width - 10.;

      blockSelf.modButton.hidden = ![blockSelf showsModerationIndicator];
      if (!blockSelf.modButton.hidden) {
        blockSelf.modButton.right = blockSelf.sortButton.right + 12.;
        blockSelf.sortButton.right -= 20.;
      }

      [blockSelf.sortButton setTitle:title forState:UIControlStateNormal];

      //    if (!blockSelf.modButton.hidden)
      //    {
      //      blockSelf.modButton.left = blockSelf.sortButton.left - 13.;
      //      blockSelf.scopeButton.right = blockSelf.modButton.left - 10.;
      //    }
      //    else
      //    {
      //      blockSelf.modButton.left = blockSelf.sortButton.left;
      //    }
  } completion:nil];
}

- (void)respondToStyleChangeNotification;
{
  self.backgroundImageView.image = [[self class] imageForBarBackground];
  [self.sortButton setBackgroundImage:[[self class] imageForSortButtonBackgroundHighlighted:NO]
                             forState:UIControlStateNormal];
  [self.sortButton setBackgroundImage:[[self class] imageForSortButtonBackgroundHighlighted:YES]
                             forState:UIControlStateHighlighted];

  [self.modButton setImage:[[self class] imageForModIndicatorButton] forState:UIControlStateNormal];
  //  self.searchTextField.leftView = iconView;
  //  self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark -
#pragma mark - CG drawing for custom components

+ (UIImage *)imageForBarBackground;
{
  UIImage *bgImage = [UIImage
      jm_imageFromDrawingBlock:^(CGRect bounds) {
          UIColor *bgColor = [UIColor colorForBackground];
          [bgColor set];
          [[UIBezierPath bezierPathWithRect:bounds] fill];

          //    [[UIColor colorWithWhite:0. alpha:0.015] set];
          //    [[UIBezierPath bezierPathWithRect:bounds] fill];
          //
          //    CGFloat shadowTransparency = [Resources isNight] ? 0.2 : 0.08;
          //    // top shadow
          //    [UIView drawGradientInRect:CGRectCropToTop(bounds, 3.) minHeight:0.
          //    startColor:[UIColor colorWithWhite:0. alpha:shadowTransparency] endColor:[UIColor
          //    clearColor]];
          //
          //    // bottom shadow
          //    [UIView drawGradientInRect:CGRectCropToBottom(bounds, 3.) minHeight:0.
          //    startColor:[UIColor clearColor] endColor:[UIColor colorWithWhite:0.
          //    alpha:shadowTransparency]];
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
      } opaque:YES withSize:CGSizeMake(31., 31.)
                      cacheKey:[NSString stringWithFormat:@"posts_order_toolbar_background-%d",
                                                          [Resources isNight]]];
  return [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15., 15., 15., 15.)];
}

+ (UIImage *)imageForSearchField;
{
  UIImage *bgImage = [UIImage
      jm_imageFromDrawingBlock:^(CGRect bounds) {
          //    UIColor *bgColor = [UIColor colorForBackground];
          //    [bgColor set];
          //    [[UIBezierPath bezierPathWithRect:bounds] fill];
          //    [[UIColor colorWithWhite:0. alpha:0.015] set];
          //    [[UIBezierPath bezierPathWithRect:bounds] fill];

          UIBezierPath *fieldPath =
              [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 1., 1.) cornerRadius:5.];
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

      } opaque:NO withSize:CGSizeMake(31., 31.)
                      cacheKey:[NSString stringWithFormat:@"posts_order_toolbar_search-bg-%d",
                                                          [Resources isNight]]];
  return [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15., 15., 15., 15.)];
}

+ (UIImage *)imageForSortButtonBackgroundHighlighted:(BOOL)highlighted;
{
  UIImage *bgImage = [UIImage
      jm_imageFromDrawingBlock:^(CGRect bounds) {

          //    [UIView startEtchedDraw];
          UIBezierPath *fieldPath =
              [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 1., 1.) cornerRadius:5.];
          UIColor *buttonColor = nil;
          if ([Resources isNight]) {
            buttonColor =
                highlighted ? [UIColor colorWithHex:0x232323] : [UIColor colorWithHex:0x333333];
          } else {
            buttonColor =
                highlighted ? [UIColor colorWithHex:0x868686] : [UIColor colorWithHex:0xb9b9b9];
          }
          [buttonColor set];
          [fieldPath fill];
          //    [UIView endEtchedDraw];
      } opaque:NO withSize:CGSizeMake(31., 31.)
                      cacheKey:[NSString stringWithFormat:@"posts_order_toolbar_sort-bg-%d-%d",
                                                          highlighted, [Resources isNight]]];
  return [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15., 15., 15., 15.)];
}

+ (UIImage *)imageForModIndicatorButton;
{
  BOOL hasPressedButtonBefore =
      [UDefaults boolForKey:kREDListingOrderToolbarTrainingHasTappedModButtonPrefKey];

  UIImage *bgImage = [UIImage
      jm_imageFromDrawingBlock:^(CGRect bounds) {
          CGRect mRect = CGRectMake(11., 0., 12, bounds.size.height - 1.);
          UIBezierPath *mPath = [UIBezierPath bezierPathWithRoundedRect:mRect cornerRadius:2.];

          UIBezierPath *tPath = [UIBezierPath bezierPathWithTriangleCenter:CGPointMake(11., 15.)
                                                                sideLength:9.
                                                                     angle:-90.];

          [mPath appendPath:tPath];

          UIColor *stdColor = [Resources isNight] ? [UIColor colorForHighlightedOptions]
                                                  : [UIColor colorWithHex:0xb9b9b9];
          //    UIColor *stdColor = [Resources isNight] ? [UIColor colorForHighlightedOptions] :
          //    [UIColor colorForTint];
          UIColor *iconColor = hasPressedButtonBefore ? stdColor : [UIColor colorWithHex:0x960000];
          [iconColor set];
          //    UIColor *ribbonColor = [Resources isNight] ? [UIColor colorForHighlightedOptions] :
          //    [UIColor colorForTint];
          //    [ribbonColor set];

          [UIView startEtchedDraw];
          [mPath fill];
          [UIView endEtchedDraw];

          CGContextRef ctx = UIGraphicsGetCurrentContext();
          CGContextSaveGState(ctx);
          CGContextRotateCTM(ctx, -M_PI_2);
          CGContextTranslateCTM(ctx, -23., 13.);
          [[UIColor whiteColor] set];
          [@"MOD" drawAtPoint:CGPointMake(0., 0.)
                     withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:7]];

          CGContextRestoreGState(ctx);

      } opaque:NO withSize:CGSizeMake(25., 30.)
                      cacheKey:[NSString stringWithFormat:@"posts_order_toolbar_mod-bg-%d-%d-%d",
                                                          [Resources isNight],
                                                          hasPressedButtonBefore,
                                                          [Resources skinTheme]]];
  return bgImage;
}

- (void)sortButtonTapped;
{ [self.delegate listingOrderToolbar:self didTapOrderButtonWithSearchActive:NO]; }

- (void)modButtonTapped;
{ [self.delegate listingOrderToolbarDidTapModerationButton:self]; }

@end
