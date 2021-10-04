//  REDCommentsController+Interaction.m
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController+Interaction.h"

#import <BlocksKit/UIActionSheet+BlocksKit.h>

#import "Common/Navigation/NavigationManager.h"
#import "Helpers/RedditAPI.h"
#import "Helpers/RedditAPI+Account.h"
#import "RedditApp/Detail/Comments/REDCommentsController+LinkHandling.h"
#import "RedditApp/Detail/Comments/REDCommentsController+PopoverOptions.h"
#import "RedditApp/Detail/Comments/REDCommentsController+ReplyInteraction.h"
#import "RedditApp/Detail/REDDetailViewController.h"
#import "Sections/Comments/CommentNode.h"
#import "Sections/Comments/CommentPostHeaderNode.h"
#import "Sections/Comments/Comment+API.h"
#import "Sections/Posts/Post+API.h"

@implementation REDCommentsController (Interaction)

- (void)toggleSavePostNode:(CommentPostHeaderNode *)postHeaderNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  [postHeaderNode.post toggleSaved];
  [self.detailViewController reloadRowForNode:postHeaderNode];
}

- (void)toggleHidePostNode:(CommentPostHeaderNode *)postHeaderNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  [postHeaderNode.post toggleHide];
  [self.detailViewController reloadRowForNode:postHeaderNode];
}

- (void)voteUpPostNode:(CommentPostHeaderNode *)postHeaderNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  [postHeaderNode.post upvote];
  [self.detailViewController reloadRowForNode:postHeaderNode];
}

- (void)voteDownPostNode:(CommentPostHeaderNode *)postHeaderNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  [postHeaderNode.post downvote];
  [self.detailViewController reloadRowForNode:postHeaderNode];
}

- (void)addCommentToPostNode:(CommentPostHeaderNode *)postHeaderNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;
  [self replyToPostNode:postHeaderNode];
}

- (void)deleteCommentNode:(CommentNode *)commentNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;
  [commentNode.comment deleteComment];
  [self.detailViewController reloadRowForNode:commentNode];
}

- (void)focusContextCommentNode:(CommentNode *)commentNode;
{
  NSString *linkId =
      [commentNode.comment.linkIdent stringByReplacingOccurrencesOfString:@"t3_" withString:@""];
  NSMutableString *contextLink = [NSMutableString string];
  [contextLink appendString:@"http://www.reddit.com/r/"];
  [contextLink appendString:commentNode.comment.subreddit];
  [contextLink appendString:@"/comments/"];
  [contextLink appendString:linkId];
  [contextLink appendString:@"/context/"];
  [contextLink appendString:commentNode.comment.ident];
  [self openLinkUrl:contextLink];
}

- (void)collapseToRootCommentNode:(CommentNode *)commentNode;
{
  CommentNode *parentNode = nil;

  if (commentNode.level == 0) {
    parentNode = commentNode;
  } else {
    NSArray *rootCommentNodes = [self.nodes pick:^BOOL(JMOutlineNode *item) {
        return [item isKindOfClass:[CommentNode class]] && item.level == 0;
    }];

    parentNode = [rootCommentNodes
        first:^BOOL(JMOutlineNode *item) { return [item.allChildren containsObject:commentNode]; }];
  }

  [parentNode collapseNode];

  NSMutableArray *affectedNodes = [NSMutableArray array];
  [affectedNodes addObject:parentNode];
  [affectedNodes addObjectsFromArray:[parentNode allChildren]];
  [self.detailViewController reloadRowsForNodes:affectedNodes];
  [self.detailViewController scrollToNode:parentNode];
}

@end
