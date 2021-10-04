#import "JMOutlineCustomNavigationBar.h"

@class JMActionMenuBarItemView;

@interface ABCustomOutlineNavigationBar : JMOutlineCustomNavigationBar

@property (readonly) CGFloat recommendedVerticalCenterForBarItems;
@property (readonly) BOOL hidesStatusBarOnCompact;

@property (copy) JMAction customOnBackButtonTap;
@property (copy) JMAction onBackButtonHold;
@property (copy) JMAction onTripleTap;
@property (copy) JMAction customOnModalCloseTapAction;

@property (strong, readonly) UILabel *titleLabel;
@property (strong, readonly) UIView *underlineView;
@property (strong, readonly) JMActionMenuBarItemView *actionMenuBarItemView;
@property (strong, readonly) UIButton *backButton;
@property BOOL showsThinUnderlineViewInCompactMode;

- (void)setTitleLabelText:(NSString *)titleLabelText;
- (void)updateWithActionMenuBarItemView:(UIView *)actionMenuBarItemView;
- (void)updateSubviewContentsBasedOnHeightAnimated:(BOOL)animated;
- (void)applyThemeSettings;

- (void)setCustomLeftButtonWithIcon:(UIImage *)icon onTapAction:(JMAction)onTap;
- (void)setCustomLeftButtonWithTitle:(NSString *)title onTapAction:(JMAction)onTap;

- (void)setCustomRightButtonWithIcon:(UIImage *)icon onTapAction:(JMAction)onTap;
- (void)setCustomRightButtonWithTitle:(NSString *)title onTapAction:(JMAction)onTap;

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

+ (UIImage *)cancelIcon;
+ (UIImage *)addIcon;

@end
