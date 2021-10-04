//  REDListingViewController+State.m
//  RedditApp

#import "RedditApp/Listing/REDListingViewController+State.h"

#import "Sections/Posts/NPostCell.h"

@interface REDListingViewController (State_)
@property(readonly) NSString *subreddit;
@property(readonly) NSString *subredditTitle;
@property(strong) NSString *autoscrollToPostName;
@end

@implementation REDListingViewController (State)

SYNTHESIZE_ASSOCIATED_STRONG(NSString, autoscrollToPostName, AutoscrollToPostName);

- (id)initWithState:(NSDictionary *)state;
{
  NSString *subreddit = [state objectForKey:@"subreddit"];
  NSString *subredditTitle = [state objectForKey:@"subredditTitle"];
  self = [self initWithSubreddit:subreddit title:subredditTitle];
  self.autoscrollToPostName = [state objectForKey:@"autoscrollToPostName"];

  //    // restore posts list
  //    BSELF(REDListingViewController);
  //    NSArray *posts = [state objectForKey:@"posts"];
  //    [posts each:^(Post *post) {
  //        PostNode *postNode = [PostNode nodeForPost:post];
  //        [blockSelf addNode:postNode];
  //    }];

  return self;
}

- (NSDictionary *)state;
{
  NSMutableDictionary *state = [NSMutableDictionary dictionary];
  [state setObject:self.subreddit forKey:@"subreddit"];
  [state setObject:self.subredditTitle forKey:@"subredditTitle"];

  // find the top visible post
  CGPoint cellPoint = CGPointMake(0., self.tableView.contentOffset.y + 20.);
  NSIndexPath *topIndex = [self.tableView indexPathForRowAtPoint:cellPoint];
  BSELF(REDListingViewController);
  if (topIndex) {
    JMOutlineNode *node = [blockSelf nodeForRow:topIndex.row];
    if ([node isKindOfClass:[PostNode class]]) {
      PostNode *postNode = (PostNode *)node;
      [state setObject:postNode.post.name forKey:@"autoscrollToPostName"];
    }
  }

  //    // persists the posts list
  //    __block NSMutableArray *posts = [NSMutableArray array];
  //    [self.nodes each:^(JMOutlineNode *node) {
  //        if ([node isKindOfClass:[PostNode class]])
  //        {
  //            PostNode *postNode = (PostNode *)node;
  //            [posts addObject:postNode.post];
  //        }
  //    }];
  //    [state setObject:posts forKey:@"posts"];

  return state;
}

- (void)handleRestoringStateAutoscroll;
{
  if (!self.autoscrollToPostName) return;

  BSELF(REDListingViewController);

  PostNode *matchingNode = [self.nodes first:^BOOL(JMOutlineNode *node) {
      if (![node isKindOfClass:[PostNode class]]) return NO;

      PostNode *postNode = (PostNode *)node;
      return [postNode.post.name equalsString:blockSelf.autoscrollToPostName];
  }];

  self.autoscrollToPostName = nil;

  if (matchingNode) {
    [self scrollToNode:matchingNode];
  }
}

@end
