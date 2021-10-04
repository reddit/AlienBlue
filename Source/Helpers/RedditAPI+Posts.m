#import "RedditAPI+Posts.h"

@implementation RedditAPI (Posts)

SYNTHESIZE_ASSOCIATED_BOOL(loadingPosts, LoadingPosts);

- (void)resetConnectionsForPosts
{
  self.loadingPosts = NO;
  [self clearConnectionsWithCategory:kConnectionCategoryPosts];
}

@end
