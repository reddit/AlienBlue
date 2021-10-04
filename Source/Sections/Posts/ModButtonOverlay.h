#import "JMViewOverlay.h"
#import "VotableElement.h"

@interface ModButtonOverlay : JMViewOverlay

- (id)initAsIndicatorOnly;
- (id)initAsButton;

- (void)updateWithVotableElement:(VotableElement *)votableElement;

+ (UIColor *)indicatorColorForModState:(ModerationState)modState;
+ (void)drawModLightIndicatorWithColor:(UIColor *)indicatorColor inRect:(CGRect)indicatorRect;

@end
