#import "RedditAPI.h"

@interface RedditAPI (HideQueue)

@property (strong, readonly) NSMutableArray *hideQueue;

- (void)prepareHideQueue;
- (BOOL)isPostInHideQueue:(NSString *)postID;
- (void)addPostToHideQueue:(NSString *)postID;

@end
