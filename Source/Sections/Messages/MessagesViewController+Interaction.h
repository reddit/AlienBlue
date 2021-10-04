#import "MessagesViewController.h"

@class MessageNode;

@interface MessagesViewController (Interaction)

- (void)voteUpMessageNode:(MessageNode *)messageNode;
- (void)voteDownMessageNode:(MessageNode *)messageNode;
- (void)showContextForMessageNode:(MessageNode *)messageNode;
- (void)showReplyScreenForMessageNode:(MessageNode *)messageNode;

@end
