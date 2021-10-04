//  ABEventLogger.h
//  AlienBlue

#import <Foundation/Foundation.h>

#import "Post.h"

@interface ABEventLogger : NSObject

+ (ABEventLogger *)shared;

- (id)init NS_DESIGNATED_INITIALIZER;

- (void)logTopic:(NSString *)topic type:(NSString *)type payload:(NSDictionary *)payload;

- (void)logTopic:(NSString *)topic
    type:(NSString *)type
    payload:(NSDictionary *)payload
    obfuscatedPayload:(NSDictionary *)obfuscatedPayload;

// Call this if the user changes the state of an upvote for a post. Call it *before* mutating the
// model.
- (void)logUpvoteChangeForPost:(Post *)post
                     container:(NSString *)container
                       gesture:(NSString *)gesture;

// Call this if the user changes the state of an downvote for a post. Call it *before* mutating the
// model.
- (void)logDownvoteChangeForPost:(Post *)post
                       container:(NSString *)container
                         gesture:(NSString *)gesture;

@end
