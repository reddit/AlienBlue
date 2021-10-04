#import "NCommentCell.h"
#import "Message.h"

@interface MessageNode : CommentNode
@property (strong, readonly) Message *message;

@property (copy) JMAction onHeaderBarTap;
@property (copy) JMAction onContentsTap;

- (id)initWithMessage:(Message *)message;

@end

@interface NMessageCell : NCommentCell
@end
