#import "RedditAPI+Subreddits.h"
#import "RedditAPI+DeprecationPatches.h"

@interface RedditAPI (Subreddits_)
@property (ab_weak) id subredditListCallBackTarget;
@end

@implementation RedditAPI (Subreddits)
SYNTHESIZE_ASSOCIATED_WEAK(NSObject, subredditListCallBackTarget, SubredditListCallBackTarget);

- (void)searchSubredditsResponse:(id)sender
{
  NSData *data = (NSData *)sender;
  JMJSONParser *parser = [[JMJSONParser alloc] init];
  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  
 	NSMutableDictionary *response = [parser objectWithString:responseString error:nil];
  if (self.subredditListCallBackTarget)
  {
    [self.subredditListCallBackTarget rd_performSelector:@selector(apiSubredditsResponse:) withObject:response];
  }
  self.subredditListCallBackTarget = nil;
}

- (void)subredditInfoForSubredditName:(NSString *)subredditName callBackTarget:(id)target;
{
  NSString * fetchUrl = [[NSString alloc] initWithFormat:@"%@/r/%@/about.json", self.server, subredditName];
  self.subredditListCallBackTarget = target;
  [self doGetURL:fetchUrl withConnectionCategory:kConnectionCategorySubreddit callBackTarget:self callBackMethod:@selector(searchSubredditsResponse:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)resetConnectionsForSubreddits
{
  self.subredditListCallBackTarget = nil;
  [self clearConnectionsWithCategory:kConnectionCategorySubreddit];
}

@end
