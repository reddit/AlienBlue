#import "RedditAPI.h"

@interface RedditAPI (Comments)
- (void)replyToItem:(NSMutableDictionary *)item callbackTarget:(id)callbackTarget;
- (void)deleteCommentWithID:(NSString *)commentID;
- (void)resetConnectionsForComments;
@end
