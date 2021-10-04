#import "JMViewOverlay.h"

@class MessageNode;

@interface MessageHeaderBarOverlay : JMViewOverlay

- (void)updateForMessageNode:(MessageNode *)messageNode;

+ (CGFloat)recommendedHeaderBarHeightForMessageNode:(MessageNode *)messageNode;

@end
