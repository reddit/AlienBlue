//  REDCommentsController+API.m
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController+API.h"

#import "Helpers/Resources.h"
#import "JMOutlineView/JMOutlineViewController+Prerender.h"
#import "RedditApp/Detail/REDDetailViewController.h"
#import "Sections/Comments/CommentNode.h"
#import "Sections/Comments/Comment+API.h"
#import "Sections/Comments/Comment+Preprocess.h"
#import "Sections/Comments/Comment+Style.h"
#import "Sections/Comments/NBaseStyledTextCell.h"

@interface REDCommentsController (_API)
@end

@implementation REDCommentsController (API)
SYNTHESIZE_ASSOCIATED_STRONG(AFHTTPRequestOperation, loadOperation, LoadOperation);
SYNTHESIZE_ASSOCIATED_STRONG(NSString, sortOrder, SortOrder);
SYNTHESIZE_ASSOCIATED_INTEGER(customFetchLimit, CustomFetchLimit);
SYNTHESIZE_ASSOCIATED_BOOL(disallowPrerendingAndAttributedStylePreprocessing,
                           DisallowPrerendingAndAttributedStylePreprocessing);

- (NSUInteger)fetchCount;
{
  NSUInteger fetchCount = 200;

  if (self.customFetchLimit > 0)
    fetchCount = self.customFetchLimit;
  else if ([[NSUserDefaults standardUserDefaults] objectForKey:kABSettingKeyCommentFetchCount])
    fetchCount =
        [[NSUserDefaults standardUserDefaults] integerForKey:kABSettingKeyCommentFetchCount];
  else
    fetchCount = 200;
  return fetchCount;
}

- (NSDictionary *)requestParameters {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];

  [params setObject:[NSNumber numberWithInt:[self fetchCount]] forKey:@"limit"];

  if (self.sortOrder)
    [params setObject:self.sortOrder forKey:@"sort"];
  else
    [params setObject:kCommentSortOrderTop forKey:@"sort"];

  if (self.contextId) [params setObject:[NSNumber numberWithInt:3] forKey:@"context"];

  return params;
};

- (BOOL)shouldFilterComment:(Comment *)comment;
{
  if (![Resources safeFilter]) return NO;

  if ([comment.body contains:@"http://"] &&
      ([comment.body contains:@"nsfw"] || [comment.body contains:@"nsfl"])) {
    return YES;
  }

  return NO;
}

- (void)processCommentThread:(NSDictionary *)commentDictionary
                   withLevel:(NSUInteger)level
                  parentNode:(JMOutlineNode *)parentNode
               appendToArray:(NSMutableArray *)nodeArray;
{
  Comment *comment = [Comment commentFromDictionary:commentDictionary];

  if ([self shouldFilterComment:comment]) return;

  comment.commentIndex = [nodeArray count];

  CommentNode *node = [CommentNode nodeForComment:comment level:level];
  [parentNode addChildNode:node];
  [nodeArray addObject:node];

  NSInteger numReplies = 0;
  if (![[commentDictionary objectForKey:@"replies"] isKindOfClass:[NSString class]]) {
    NSArray *rawComments = [[[commentDictionary objectForKey:@"replies"] objectForKey:@"data"]
        objectForKey:@"children"];
    for (NSDictionary *rawComment in rawComments) {
      // exclude the "more..." threads
      if (![[rawComment valueForKey:@"kind"] isEqualToString:@"more"]) {
        [self processCommentThread:[rawComment objectForKey:@"data"]
                         withLevel:level + 1
                        parentNode:node
                     appendToArray:nodeArray];
        numReplies++;
      }
    }
  }
  comment.numberOfReplies = numReplies;
}

- (void)fetchCommentsOnComplete:(void (^)(NSArray *commentNodes,
                                          CommentPostHeaderNode *postHeaderNode))onComplete;
{
  NSDictionary *params = [self requestParameters];

  [self.loadOperation cancel];
  self.loadOperation = nil;

  BSELF(REDCommentsController);
  self.loadOperation = [Comment
      fetchCommentsForPost:self.post
                 contextId:self.contextId
                    params:params
                onComplete:^(NSArray *commentDictionaries, NSDictionary *postDictionary,
                             BOOL clientError) {

                    blockSelf.loadOperation = nil;
                    // When response is a 400-level error, pass nils to onComplete block
                    if (clientError) {
                      onComplete(nil, nil);
                      return;
                    } else if (!postDictionary || !commentDictionaries) {
                      UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Bad Response Received"
                                    message:@"reddit has responded with an error. The servers may "
                                    @"currently be under heavy load."
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
                      [alert show];
                      return;
                    };

                    Post *headerPost = [Post postFromDictionary:postDictionary];
                    CommentPostHeaderNode *headerNode =
                        [CommentPostHeaderNode nodeForHeaderPost:headerPost];

                    NSMutableArray *commentNodeArray = [NSMutableArray array];

                    [commentDictionaries each:^(NSDictionary *commentDictionary) {
                        if (![[commentDictionary valueForKey:@"kind"] isEqualToString:@"more"]) {
                          [blockSelf processCommentThread:[commentDictionary objectForKey:@"data"]
                                                withLevel:0
                                               parentNode:nil
                                            appendToArray:commentNodeArray];
                        }
                    }];

                    DO_IN_BACKGROUND(^{
                        [JMThreadTools
                            iterateSeriallyInBackgroundAndBlockUntilCompleteWithIterationAction:
                                ^(NSUInteger iteration,
                                  dispatch_block_t callAfterIterationComplete) {
                                    CommentNode *node = [commentNodeArray objectAtIndex:iteration];
                                    NSUInteger commentIndex = iteration;
                                    node.post = headerPost;
                                    if (blockSelf
                                            .disallowPrerendingAndAttributedStylePreprocessing) {
                                      [node.comment preprocessLinksOnly];
                                    } else {
                                      [node.comment preprocessLinksAndAttributedStyle];
                                    }

                                    // precache height calculations

                                    if (!blockSelf
                                             .disallowPrerendingAndAttributedStylePreprocessing) {
                                      CGRect bodyRect = [NBaseStyledTextCell
                                          rectForCommentBodyInNode:node
                                                            bounds:blockSelf.detailViewController
                                                                       .tableView.bounds];
                                      [node.comment
                                          heightForBodyConstrainedToWidth:bodyRect.size.width];
                                    }

                                    NSInteger threshold = [[NSUserDefaults standardUserDefaults]
                                        integerForKey:kABSettingKeyCommentScoreThreshold];
                                    if (node.comment.score < threshold) {
                                      node.state = JMOutlineNodeStateCollapsed;
                                    }

                                    if (![Resources isIPAD]) {
                                      node.firstComment = (commentIndex == 0);
                                    }

                                    if (!blockSelf
                                             .disallowPrerendingAndAttributedStylePreprocessing &&
                                        [Resources isIPAD] && node.comment.score > -2) {
                                      [node prefetchThumbnailsToCacheOnComplete:^{
                                          [blockSelf.detailViewController prerenderNode:node];
                                      }];
                                    }

                                    NSArray *imageLinks =
                                        [node.thumbLinks select:^BOOL(CommentLink *commentLink) {
                                            return (commentLink.linkType == LinkTypePhoto) ||
                                                   (commentLink.linkType == LinkTypeVideo);
                                        }];
                                    headerPost.numberOfImagesInCommentThread += imageLinks.count;
                                    callAfterIterationComplete();
                                } totalIterations:commentNodeArray.count shouldStopWhen:nil];

                        DO_IN_MAIN(^{ onComplete(commentNodeArray, headerNode); });
                    });
                }];
}

@end
