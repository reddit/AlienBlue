//  REDCommentsController+State.m
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController+State.h"

#import "RedditApp/Detail/REDDetailViewController.h"
#import "Sections/Comments/CommentNode.h"

@interface REDCommentsController (State_)
@property(strong) NSString *autoscrollToCommentName;
@end

@implementation REDCommentsController (State)

SYNTHESIZE_ASSOCIATED_STRONG(NSString, autoscrollToCommentName, AutoscrollToCommentName);

- (id)initWithState:(NSDictionary *)state;
{
  NSDictionary *legacyPostDictionary = [state objectForKey:@"legacyPostDictionary"];
  Post *post = [Post postFromDictionary:legacyPostDictionary];
  self = [self initWithPost:post];
  self.autoscrollToCommentName = [state objectForKey:@"autoscrollToCommentName"];
  return self;
}

- (NSDictionary *)state;
{
  NSMutableDictionary *state = [NSMutableDictionary dictionary];

  [state setObject:self.post.legacyDictionary forKey:@"legacyPostDictionary"];

  // find the top visible comment
  CGPoint cellPoint = CGPointMake(0., self.detailViewController.tableView.contentOffset.y + 20.);
  NSIndexPath *topIndex = [self.detailViewController.tableView indexPathForRowAtPoint:cellPoint];
  if (topIndex) {
    JMOutlineNode *node = [self.detailViewController nodeForRow:topIndex.row];
    if ([node isKindOfClass:[CommentNode class]]) {
      CommentNode *commentNode = (CommentNode *)node;
      [state setObject:commentNode.comment.name forKey:@"autoscrollToCommentName"];
    }
  }

  return state;
}

- (void)handleRestoringStateAutoscroll;
{
  if (!self.autoscrollToCommentName) return;

  BSELF(REDCommentsController);

  CommentNode *matchingNode = [self.nodes first:^BOOL(JMOutlineNode *node) {
      if (![node isKindOfClass:[CommentNode class]]) return NO;

      CommentNode *commentNode = (CommentNode *)node;
      return [commentNode.comment.name equalsString:blockSelf.autoscrollToCommentName];
  }];

  self.autoscrollToCommentName = nil;

  if (matchingNode) {
    [self.detailViewController scrollToNode:matchingNode];
  }
}

@end
