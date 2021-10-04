#import "RedditAPI.h"

@interface RedditAPI (ElementInteraction)

- (void)hidePostWithID:(NSString *)postID;
- (void)savePostWithID:(NSString *)postID;
- (void)reportPostWithID:(NSString *)postID;
- (void)unsavePostWithID:(NSString *)postID;
- (void)unhidePostWithID:(NSString *)postID;
- (void)submitVote:(NSMutableDictionary *)item;

@end
