#import "RedditAPI.h"

@interface RedditAPI (Subreddits)

- (void)resetConnectionsForSubreddits;
- (void)subredditInfoForSubredditName:(NSString *)subredditName callBackTarget:(id)target;

@end
