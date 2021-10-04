#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostModerationControlView : UIView

@property (copy) ABAction onCancelTap;
@property (copy) ABAction onModerationStateChange;
@property (copy) void(^onModerationWillShowTemplateSelectionScreen)(void);
@property (copy) void(^onModerationMessageSentResponse)(id response);

- (void)updateWithPost:(Post *)post;

@end
