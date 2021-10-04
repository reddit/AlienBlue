#import "RedditAPI.h"

@interface RedditAPI (Messages)

- (void)fetchMessagesWithCategoryUrl:(NSString *)categoryUrl afterMessageID:(NSString *)messageID withCallBackTarget:(id)target;
- (void)submitDirectMessage:(NSMutableDictionary *)messageToSubmit withCallBackTarget:(id)target;

- (void)markMessageReadWithID: (NSString *) messageID;
- (void)markAllMessagesAsRead;
- (void)markAllModMailAsRead;

- (void)resetConnectionsForMessages;

@end
