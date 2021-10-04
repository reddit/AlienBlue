#import "RedditAPI.h"

@interface RedditAPI (Posts)

@property BOOL loadingPosts;

// Bulk of API functionality has been migrated to Post+API
- (void)resetConnectionsForPosts;

@end
