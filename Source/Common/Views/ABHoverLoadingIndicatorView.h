#import "JMAnimatedControl.h"

#define kABHoverLoadingIndicatorViewProgressRatioForError -21399.

@interface ABHoverLoadingIndicatorView : JMAnimatedControl
- (void)updateWithProgressRatio:(CGFloat)progressRatio;
@end
