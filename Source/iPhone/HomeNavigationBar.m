#import "HomeNavigationBar.h"
#import "OverlayViewContainer.h"
#import "UIImage+JMActionMenuAssets.h"
#import "MKStoreManager.h"
#import "NavigationManager.h"

#define kHomeNavigationBarProUpgradeOverlayWidth 90.

@interface HomeNavigationBar()
@property (strong) UIView *supplementalBarWrapperView;
@property (strong) JMViewOverlay *inboxButtonOverlay;
@property (strong) JMViewOverlay *settingsButtonOverlay;
@property (strong) JMViewOverlay *centerSectionOverlay;
@end

@implementation HomeNavigationBar

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kProUpgradeNotification object:nil];  
}

- (instancetype)initWithFrame:(CGRect)frame
{
  JM_SUPER_INIT(initWithFrame:frame);
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeProStatus) name:kProUpgradeNotification object:nil];
  
  self.supplementalBarWrapperView = [[UIView alloc] initWithSize:CGSizeMake(self.bounds.size.width, 50.)];
  self.supplementalBarWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.supplementalBarWrapperView.top = 78.;
  self.supplementalBarWrapperView.backgroundColor = [UIColor clearColor];
  [self insertSubview:self.supplementalBarWrapperView belowSubview:self.underlineView];
  
  OverlayViewContainer *overlayContainer = [[OverlayViewContainer alloc] initWithFrame:self.supplementalBarWrapperView.bounds];
  overlayContainer.autoresizingMask = JMFlexibleSizeMask;
  overlayContainer.backgroundColor = [UIColor clearColor];
  [self.supplementalBarWrapperView addSubview:overlayContainer];
  
  self.inboxButtonOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., 50., 50.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    UIColor *iconColor = [UIColor skinColorForDisabledIcon];
    UIColor *iconHighlightColor = [UIColor colorForHighlightedOptions];
    UIImage *icon = [UIImage actionMenuIconWithName:@"am-icon-global-inbox" fillColor:(highlighted ? iconHighlightColor : iconColor)];
    [icon jm_drawCenteredInRect:bounds];
  } onTap:^(CGPoint touchPoint) {
    [[NavigationManager shared] showMessagesScreen];
  }];
  [overlayContainer addOverlay:self.inboxButtonOverlay];

  self.settingsButtonOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., 50., 50.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    UIColor *iconColor = [UIColor skinColorForDisabledIcon];
    UIColor *iconHighlightColor = [UIColor colorForHighlightedOptions];
    UIImage *icon = [UIImage actionMenuIconWithName:@"am-icon-global-settings" fillColor:(highlighted ? iconHighlightColor : iconColor)];
    [icon jm_drawCenteredInRect:bounds];
  } onTap:^(CGPoint touchPoint) {
    [[NavigationManager shared] showSettingsScreen];
  }];
  [overlayContainer addOverlay:self.settingsButtonOverlay];
  
  self.centerSectionOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., kHomeNavigationBarProUpgradeOverlayWidth, 50.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    CGFloat verticalLineInset = 7.;
    if ([MKStoreManager isProUpgraded])
    {
      [UIView jm_drawVerticalDottedLineInRect:CGRectInset(bounds, 0., verticalLineInset) lineWidth:0.5 lineColor:[UIColor colorForDottedDivider] dashScale:0.5];
      return;
    }
    
    [UIView jm_drawVerticalDottedLineInRect:CGRectInset(CGRectCropToLeft(bounds, 1.), 0., verticalLineInset) lineWidth:0.5 lineColor:[UIColor colorForDottedDivider] dashScale:0.5];
    [UIView jm_drawVerticalDottedLineInRect:CGRectInset(CGRectCropToRight(bounds, 1.), 0., verticalLineInset) lineWidth:0.5 lineColor:[UIColor colorForDottedDivider] dashScale:0.5];

    UIColor *iconHighlightColor = [UIColor colorForHighlightedOptions];
    UIColor *color = (highlighted ? iconHighlightColor : [UIColor colorForHighlightedOptions]);
    UIImage *icon = [UIImage skinIcon:@"settings-pro-upgrade-icon" withColor:color];
    
//    NSString *priceText = !JMIsEmpty([MKStoreManager proUpgradePriceInfo]) ? [MKStoreManager proUpgradePriceInfo] : nil;
    NSString *priceText = @"Pro";
    
    if (!priceText)
    {
      [icon jm_drawCenteredInRect:bounds];
    }
    else
    {
      UIFont *priceFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.];
      CGSize priceSize = [priceText jm_sizeWithFont:priceFont];
      
      CGRect priceRect = CGRectCenterWithSize(bounds, CGSizeMake(priceSize.width + icon.width, priceSize.height));
      priceRect = CGRectOffset(priceRect, -5., 0.);
      [priceText jm_drawVerticallyCenteredInRect:priceRect withFont:priceFont color:color horizontalAlignment:NSTextAlignmentRight];
      
      CGPoint iconOrigin = CGPointMake(priceRect.origin.x, 11.);
      [icon drawAtPoint:iconOrigin];
    }
    
  } onTap:^(CGPoint touchPoint) {
    [[NavigationManager shared] showProUpgradeScreen];
  }];
  [overlayContainer addOverlay:self.centerSectionOverlay];
  
  // placeholder only - onTap gets set in RedditsViewController+EditSupport
  [self setCustomLeftButtonWithTitle:@"Edit" onTapAction:nil];

  return self;
}

- (void)layoutSubviews;
{
  [super layoutSubviews];
  self.centerSectionOverlay.width = [MKStoreManager isProUpgraded] ? 30. : kHomeNavigationBarProUpgradeOverlayWidth;
  
  CGFloat totalContentWidth = self.settingsButtonOverlay.width + self.centerSectionOverlay.width + self.inboxButtonOverlay.width;
  CGFloat xOffsetToCenter = (self.bounds.size.width - totalContentWidth) / 2.;
  
  self.settingsButtonOverlay.left = xOffsetToCenter;
  self.centerSectionOverlay.left = self.settingsButtonOverlay.right;
  self.inboxButtonOverlay.left = self.centerSectionOverlay.right;
  
//  self.supplementalBarWrapperView.centerY = self.recommendedVerticalCenterForBarItems;
//  [self.supplementalBarWrapperView jm_adjustToPixelBoundaries];
}

- (CGFloat)defaultBarHeight;
{
  return self.maximumBarHeight;
}

- (CGFloat)maximumBarHeight;
{
  return 130.;
}

- (void)updateContentsBasedOnHeightAnimated:(BOOL)animated;
{
  [super updateContentsBasedOnHeightAnimated:animated];
}

- (void)parentControllerWillBecomeVisible;
{
  [super parentControllerWillBecomeVisible];
  
  // monkey-patch for missing icons in supplemental view when
  // using edge-sliding navigation to go back to Reddits screen
  [self.settingsButtonOverlay.parentView setNeedsDisplay];
}

- (void)didChangeProStatus;
{
  [self updateContentsBasedOnHeightAnimated:NO];
  [self layoutSubviews];
}

@end
