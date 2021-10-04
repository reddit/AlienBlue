#import "Post.h"
#import "OverlayViewContainer.h"

#define kCommentPostHeaderToolbarHeight ([Resources useActionMenu] ? 0. : 40.)

@interface CommentPostHeaderToolbar : UIView

@property (copy) void(^onModerationSendMessage)(id response);
@property (copy) void(^onCanvasButtonTap)(void);
@property BOOL shouldHighlightCanvasButton;
+ (CommentPostHeaderToolbar *)postHeaderToolbar;

- (void)updateWithPost:(Post *)post;

- (void)hideModTools;
@end
