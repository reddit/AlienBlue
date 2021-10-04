#import "JMOutlineCell.h"

@class Message;

@interface MessageSectionHeaderNode : JMOutlineNode

@property (strong, readonly) Message *message;
@property NSUInteger numberOfUnreadChildren;

- (id)initWithTopLevelMessage:(Message *)message;

@end

@interface NMessageSectionHeaderCell : JMOutlineCell

@end
