#import "Message.h"

@interface Message (API)

+ (AFHTTPRequestOperation *)fetchMessagesForPath:(NSString *)path params:(NSDictionary *)params onComplete:(void (^)(NSArray *messages))onComplete;
+ (AFHTTPRequestOperation *)fetchLastSubmittedMessageCommentForUser:(NSString *)username onComplete:(void(^)(Message *messageCommentOrNil))onComplete;
@end
