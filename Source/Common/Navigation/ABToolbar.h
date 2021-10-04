#import <UIKit/UIKit.h>

@interface ABToolbar : UIToolbar

- (void)registerForNotifications;
- (void)handleTintSwitch;

- (void)setShowsRibbon:(BOOL)showsRibbon;
- (void)setShowsUpArrow:(BOOL)showsUpArrow;

- (void)setToolbarBackgroundColor:(UIColor *)toolbarBackgroundColor;

@property (readonly) UIImageView *jmShadowImageView;
@property (readonly) UIImageView *upArrowImageView;

@end

