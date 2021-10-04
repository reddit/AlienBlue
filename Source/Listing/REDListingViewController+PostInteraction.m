//  REDListingViewController+PostInteraction.m
//  RedditApp

#import "RedditApp/Listing/REDListingViewController+PostInteraction.h"

#import <BlocksKit/UIActionSheet+BlocksKit.h>

#import "Common/Navigation/NavigationManager.h"
#import "Helpers/RedditAPI+Account.h"
#import "Helpers/RedditAPI.h"
#import "Sections/Posts/Post+API.h"
#import "Sections/Posts/Post+Style.h"

@implementation REDListingViewController (PostInteraction)

- (void)toggleSavePostNode:(PostNode *)postNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  [postNode.post toggleSaved];
  [self reloadRowForNode:postNode];
}

- (void)toggleHidePostNode:(PostNode *)postNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  [postNode.post toggleHide];
  if (postNode.post.hidden) {
    [self removeNode:postNode];
    [self deselectNodes];
  }
}

- (void)voteUpPostNode:(PostNode *)postNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  [postNode.post upvote];
  [postNode.post flushCachedStyles];
  [self reloadRowForNode:postNode];
}

- (void)voteDownPostNode:(PostNode *)postNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  [postNode.post downvote];
  [postNode.post flushCachedStyles];
  [self reloadRowForNode:postNode];
}

- (void)reportPostNode:(PostNode *)postNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  UIActionSheet *action = [UIActionSheet bk_actionSheetWithTitle:@"Report as Spam?"];
  BSELF(REDListingViewController);

  [action bk_setDestructiveButtonWithTitle:@"Report"
                                   handler:^{
                                       [postNode.post report];
                                       [blockSelf reloadRowForNode:postNode];
                                   }];

  [action bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [action jm_showInView:[NavigationManager mainView]];
}

@end
