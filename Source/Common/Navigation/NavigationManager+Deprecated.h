#import "NavigationManager.h"

@interface NavigationManager (Deprecated)
@property (readonly) BOOL deprecated_isFullscreen;
@property (nonatomic, strong) NSMutableDictionary *deprecated_legacyPostDictionary;
- (void)deprecated_drawIphoneVotingItems;
- (void)deprecated_drawIphoneBottomToolbarItems;
- (void)deprecated_handleFullscreenWillShowViewControllerAdjustments;
- (void)deprecated_handleFullscreenAdjustmentsAfterRotationIfNecessary;
- (void)deprecated_exitFullscreenMode;
- (void)deprecated_exitFullscreenAnimated:(BOOL)animated;
- (void)deprecated_toggleFullscreen;
- (void)deprecated_applyNightSwitchGestureRecognizer;
@end
