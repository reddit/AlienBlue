//  REDCommentsController+ReplyInteraction.m
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController+ReplyInteraction.h"

#import <BlocksKit/UIAlertView+BlocksKit.h>

#import "Common/Navigation/NavigationManager.h"
#import "Helpers/RedditAPI.h"
#import "Helpers/RedditAPI+Account.h"
#import "Helpers/RedditAPI+Comments.h"
#import "RedditApp/Detail/REDDetailViewController.h"
#import "Sections/Comments/CommentNode.h"
#import "Sections/Comments/CommentPostHeaderNode.h"
#import "Sections/Comments/Comment+Preprocess.h"

@implementation REDCommentsController (ReplyInteraction)

- (void)showLegacyCommentEntryForDictionary:(NSDictionary *)rawDictionary editing:(BOOL)editing;
{
  NSMutableDictionary *legacyDictionary =
      [NSMutableDictionary dictionaryWithDictionary:rawDictionary];
  if (editing) {
    NSString *body = [rawDictionary objectForKey:@"body"];
    body = [body stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    [legacyDictionary setObject:body forKey:@"replyText"];
    [legacyDictionary setObject:@"YES" forKey:@"editMode"];
  }
  [legacyDictionary setObject:[rawDictionary objectForKey:@"body"] forKey:@"originalBody"];

  UINavigationController *commentEntryViewController =
      [CommentEntryViewController viewControllerWithNavigationForDelegate:self
                                                              withComment:legacyDictionary
                                                                  editing:editing
                                                                  message:NO];
  commentEntryViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self.detailViewController presentModalViewController:commentEntryViewController animated:YES];
}

- (void)showLegacyCommentEntryForDictionary:(NSDictionary *)rawDictionary;
{
  BOOL isEditing = [[rawDictionary objectForKey:@"author"]
                       equalsString:[[RedditAPI shared] authenticatedUser]] &&
                   (![rawDictionary objectForKey:@"is_self"] ||
                    [[rawDictionary objectForKey:@"is_self"] boolValue]);
  [self showLegacyCommentEntryForDictionary:rawDictionary editing:isEditing];
}

- (void)replyToPostNode:(CommentPostHeaderNode *)headerNode;
{ [self showLegacyCommentEntryForDictionary:headerNode.comment.legacyDictionary]; }

- (void)replyToCommentNode:(CommentNode *)node;
{ [self showLegacyCommentEntryForDictionary:node.comment.legacyDictionary]; }

- (BaseStyledTextNode *)nodeForElementId:(NSString *)elementId;
{
  BaseStyledTextNode *node = [self.nodes first:^BOOL(JMOutlineNode *node) {
      if ([node isKindOfClass:[BaseStyledTextNode class]]) {
        return [[(BaseStyledTextNode *)node elementId] equalsString:elementId];
      } else {
        return NO;
      }
  }];
  return node;
}

- (Comment *)createCommentFromLegacyReplyResponse:(NSDictionary *)comment {
  if (!comment) {
    DLog(@"WARNING: comment received NULL response");
    return nil;
  }

  NSMutableDictionary *nComment = [NSMutableDictionary dictionaryWithCapacity:20];
  if ([comment objectForKey:@"parent"]) {
    [nComment setObject:[comment objectForKey:@"parent"] forKey:@"parent_id"];
  }
  if ([comment objectForKey:@"id"]) {
    [nComment setObject:[comment objectForKey:@"id"] forKey:@"name"];
  }
  if ([comment objectForKey:@"link"]) {
    [nComment setObject:[comment objectForKey:@"link"] forKey:@"link_id"];
  }

  [nComment setObject:[self.post.subreddit copy] forKey:@"subreddit"];

  [nComment setObject:[NSNumber numberWithBool:YES] forKey:@"likes"];
  [nComment setObject:[NSNumber numberWithInt:1] forKey:@"ups"];
  [nComment setObject:[NSNumber numberWithInt:1] forKey:@"score"];
  [nComment setObject:[NSNumber numberWithBool:YES] forKey:@"score_hidden"];
  [nComment setObject:[[RedditAPI shared] authenticatedUser] forKey:@"author"];
  [nComment setObject:[NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970]]
               forKey:@"created_utc"];
  [nComment setValue:[NSNumber numberWithInt:1] forKey:@"voteDirection"];
  // extract id from the name
  NSString *commentName = [nComment objectForKey:@"name"];
  if (!commentName) return nil;

  NSString *commentId = [commentName convertRedditNameToIdent];
  [nComment setObject:commentId forKey:@"id"];

  if ([comment objectForKey:@"contentHTML"]) {
    [nComment setObject:[comment objectForKey:@"contentHTML"] forKey:@"body_html"];
  } else {
    [nComment setObject:@"" forKey:@"body_html"];
  }

  if ([comment objectForKey:@"contentText"]) {
    [nComment setObject:[comment objectForKey:@"contentText"] forKey:@"body"];
    [nComment setObject:[comment objectForKey:@"contentText"] forKey:@"originalBody"];
  } else {
    [nComment setObject:@"" forKey:@"body"];
    [nComment setObject:@"" forKey:@"originalBody"];
  }

  Comment *c = [Comment commentFromDictionary:nComment];
  [c preprocessLinksAndAttributedStyle];
  return c;
}

- (void)afterCommentReply:(NSDictionary *)response;
{
  [self.detailViewController deselectNodes];

  Comment *newComment = [self createCommentFromLegacyReplyResponse:response];

  if (!newComment) {
    UIAlertView *alert =
        [UIAlertView bk_alertViewWithTitle:@"Failed to submit"
                                   message:@"reddit returned an error when submitting. Alien Blue "
                                   @"has saved a backup copy of your comment."];
    [alert bk_setCancelButtonWithTitle:@"OK" handler:nil];
    [alert show];
    return;
  }

  BaseStyledTextNode *nodeMatchingComment = [self nodeForElementId:newComment.ident];
  if (!nodeMatchingComment) {
    BaseStyledTextNode *parentNode = [self nodeForElementId:newComment.parentIdent];
    NSUInteger level =
        (parentNode == nil || [parentNode isKindOfClass:[CommentPostHeaderNode class]])
            ? 0.
            : parentNode.level + 1;
    CommentNode *commentNode = [CommentNode nodeForComment:newComment level:level];
    commentNode.post = self.post;
    if (level > 0) {
      [parentNode addChildNode:commentNode];
      [self.detailViewController insertNode:commentNode afterNode:parentNode];
    } else {
      [self.detailViewController addNode:commentNode];
    }
    [self.detailViewController reload];
    [self.detailViewController scrollToNode:commentNode];
  } else if ([nodeMatchingComment isKindOfClass:[CommentPostHeaderNode class]]) {
    //        CommentPostHeaderNode *postHeaderNode = (CommentPostHeaderNode *)nodeMatchingComment;
    [self fetchComments];
  } else if ([nodeMatchingComment isKindOfClass:[CommentNode class]]) {
    CommentNode *commentNode = (CommentNode *)nodeMatchingComment;
    commentNode.comment = newComment;
    [self.detailViewController reloadRowForNode:commentNode];
  }
}

#pragma -
#pragma Comment Entry View Delegates

- (void)commentExited:(NSMutableDictionary *)entered;
{}

- (void)commentEntered:(NSMutableDictionary *)entered;
{
  NSMutableDictionary *commentDictionary =
      [NSMutableDictionary dictionaryWithDictionary:[entered objectForKey:@"elementDictionary"]];
  [commentDictionary setObject:[entered valueForKey:@"text"] forKey:@"replyText"];
  [[RedditAPI shared] replyToItem:commentDictionary callbackTarget:[NavigationManager shared]];
}

@end
