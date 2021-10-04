#import "MessagesViewController+Interaction.h"
#import "NMessageCell.h"
#import "CommentEntryViewController.h"
#import "NavigationManager.h"
#import "Resources.h"
#import "RedditAPI+Comments.h"

@interface MessagesViewController (Interaction_) <CommentEntryDelegate>
@property (strong) Message *parentMessageBeingRepliedTo;
@end

@implementation MessagesViewController (Interaction)

SYNTHESIZE_ASSOCIATED_STRONG(MessagesViewController, parentMessageBeingRepliedTo, ParentMessageBeingRepliedTo);

- (void)voteUpMessageNode:(MessageNode *)messageNode;
{
  [messageNode.message upvote];
  [self reloadRowForNode:messageNode];
}

- (void)voteDownMessageNode:(MessageNode *)messageNode;
{
  [messageNode.message downvote];
  [self reloadRowForNode:messageNode];
}

- (void)voteUpCommentNode:(MessageNode *)commentNode;
{
  [self voteUpMessageNode:commentNode];
}

- (void)voteDownCommentNode:(MessageNode *)commentNode;
{
  [self voteUpMessageNode:commentNode];
}

- (void)showContextForMessageNode:(MessageNode *)messageNode;
{
  Message *m = messageNode.message;
  if (m.wasComment)
  {
    [self jumpToContextAnotherUsersComment:m];
  }
  else
  {
    [self jumpToContextForAuthenticatedUsersComment:m];
  }
}

- (void)showReplyScreenForMessageNode:(MessageNode *)messageNode;
{
  self.parentMessageBeingRepliedTo = messageNode.message;
  NSMutableDictionary *legacyMessageDictionary = messageNode.message.legacyDictionary;
  legacyMessageDictionary[@"originalBody"] = legacyMessageDictionary[@"body"];
  CommentEntryViewController *controller = [CommentEntryViewController viewControllerForDelegate:self withComment:legacyMessageDictionary editing:NO message:YES];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)jumpToContextForAuthenticatedUsersComment:(Message *)message;
{
  if (JMIsEmpty(message.linkIdent))
    return;
  
  if (JMIsEmpty(message.name))
    return;

  NSRange underscorePosition = [message.linkIdent rangeOfString:@"_"];
  NSString *postIdent = [message.linkIdent substringFromIndex:underscorePosition.location + 1];
  if (JMIsEmpty(postIdent))
    return;

  NSDictionary *postDictionary = @{
                                   @"id" : postIdent,
                                   @"type" : @""
                                   };
  Post *post = [Post postFromDictionary:postDictionary];
  
  [[NavigationManager shared] showCommentsForPost:post contextId:message.name fromController:nil];
  [[NavigationManager shared] dismissModalView];
}

- (void)jumpToContextAnotherUsersComment:(Message *)message;
{
  if (!message.wasComment)
    return;
  
  if (JMIsEmpty(message.contextUrl))
    return;
  
  NSString *postIdent = [message.contextUrl extractRedditPostIdent];
  if (JMIsEmpty(postIdent))
    return;
  
  NSDictionary *postDictionary = @{
                                   @"id" : postIdent,
                                   @"type" : @""
                                   };
  Post *post = [Post postFromDictionary:postDictionary];
  [[NavigationManager shared] showCommentsForPost:post contextId:message.name fromController:nil];
  [[NavigationManager shared] dismissModalView];
}

- (void)dismissAfterCommentEntryIfNecessary;
{
  if ([Resources isIPAD] && self.shouldDismissModalAfterReplying)
  {
    [[NavigationManager shared] dismissModalView];
  }
}

- (void)commentExited:(NSDictionary *)dictionary;
{
  [self dismissAfterCommentEntryIfNecessary];
}

- (void)commentEntered:(NSDictionary *)dictionary;
{
  if (JMIsEmpty(dictionary[@"text"]))
  {
    [self dismissAfterCommentEntryIfNecessary];
    return;
  }
  
  NSMutableDictionary *legacyMessageDictionary = self.parentMessageBeingRepliedTo.legacyDictionary;
  legacyMessageDictionary[@"replyText"] = dictionary[@"text"];
  [[RedditAPI shared] replyToItem:legacyMessageDictionary callbackTarget:[NavigationManager shared]];
  [self dismissAfterCommentEntryIfNecessary];
}

@end
