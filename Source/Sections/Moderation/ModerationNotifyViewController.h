#import "TemplatesViewController.h"
#import "Post.h"

@interface ModerationNotifyViewController : TemplatesViewController

- (id)initWithPost:(Post *)post;

@property (copy) void(^onModerationNotifySendComplete)(id response);

@end
