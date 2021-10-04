#import "CommentsActionMenuHost.h"

#import "ABActionMenuWatchedPostStatistics.h"
#import "ABEventLogger.h"
#import "CommentLink.h"
#import "CommentsNavigationBar.h"
#import "CommentsViewController+PopoverOptions.h"
#import "NavigationManager.h"
#import "Post+API.h"

@interface CommentsActionMenuHost()
@property (readonly) CommentsViewController *commentsViewController;
@property (readonly) CommentsNavigationBar *commentsNavigationBar;
@end

@implementation CommentsActionMenuHost

- (CommentsViewController *)commentsViewController;
{
  return (CommentsViewController *)self.parentController;
}

- (CommentsNavigationBar *)commentsNavigationBar;
{
  return (CommentsNavigationBar *)self.customNavigationBar;
}

- (Class)classForCustomNavigationBar;
{
  return [CommentsNavigationBar class];
}

- (NSString *)friendlyName;
{
  return @"Comments";
}

- (void)willAttachCustomNavigationBar:(ABCustomOutlineNavigationBar *)customNavigationBar;
{
  [super willAttachCustomNavigationBar:customNavigationBar];
  [ABActionMenuPostRecord addPostToRecentlyVisitedList:self.commentsViewController.post];
}

- (void)updateCustomNavigationBar;
{
  [super updateCustomNavigationBar];
  [self.commentsNavigationBar setLegacyCommentHeaderBar:(UIView *)self.commentsViewController.headerToolbar];
}

+ (JMActionMenuNode *)generateContentUpvoteNode;
{
  BOOL isUpvoted = [NavigationManager shared].lastVisitedPost.voteState == VoteStateUpvoted;
  JMActionMenuNode *upvoteNode = [JMActionMenuNode nodeWithIdent:@"content-upvote" iconName:@"am-icon-content-upvote" title:@"Upvote"];
  upvoteNode.nodeDescription = @"Add a point to the score of this post";
  upvoteNode.color = JMHexColor(f57933);
  upvoteNode.showsBadge = isUpvoted;
  upvoteNode.customLabelText = isUpvoted ? @"Cancel" : @"Upvote";
  upvoteNode.onTap = ^{
    Post *post = [NavigationManager shared].lastVisitedPost;
    [[ABEventLogger shared] logUpvoteChangeForPost:post
                                         container:@"ribbon_detail"
                                           gesture:@"button_press"];
    [post upvote];
    [[NavigationManager shared] interactionIconsNeedUpdate];
  };
  return upvoteNode;
}

+ (JMActionMenuNode *)generateContentDownvoteNode;
{
  BOOL isDownvoted = [NavigationManager shared].lastVisitedPost.voteState == VoteStateDownvoted;
  JMActionMenuNode *downvoteNode = [JMActionMenuNode nodeWithIdent:@"content-downvote" iconName:@"am-icon-content-downvote" title:@"Downvote"];
  downvoteNode.nodeDescription = @"Remove a point from the score of this post";
  downvoteNode.color = JMHexColor(0080db);
  downvoteNode.showsBadge = isDownvoted;
  downvoteNode.customLabelText = isDownvoted ? @"Cancel" : @"Downvote";
  downvoteNode.onTap = ^{
    Post *post = [NavigationManager shared].lastVisitedPost;
    [[ABEventLogger shared] logDownvoteChangeForPost:post
                                           container:@"ribbon_detail"
                                             gesture:@"button_press"];
    [post downvote];
    [[NavigationManager shared] interactionIconsNeedUpdate];
  };
  return downvoteNode;
}

+ (JMActionMenuNode *)generateContentSaveNode;
{
  BOOL isSaved = [NavigationManager shared].lastVisitedPost.saved;
  JMActionMenuNode *saveNode = [JMActionMenuNode nodeWithIdent:@"content-save" iconName:@"am-icon-content-save" title:@"Save"];
  saveNode.nodeDescription = @"Bookmark this post on your account";
  saveNode.color = JMHexColor(5abbff);
  saveNode.showsBadge = isSaved;
  saveNode.customLabelText = isSaved ? @"Un-Save" : @"Save";
  saveNode.onTap = ^{
    [[NavigationManager shared].lastVisitedPost toggleSaved];
    [[NavigationManager shared] interactionIconsNeedUpdate];
  };
  return saveNode;
}

+ (JMActionMenuNode *)generateContentHideNode;
{
  BOOL isHidden = [NavigationManager shared].lastVisitedPost.hidden;
  JMActionMenuNode *hideNode = [JMActionMenuNode nodeWithIdent:@"content-hide" iconName:@"am-icon-content-hide" title:@"Hide"];
  hideNode.nodeDescription = @"Hide the post from listing in the future";
  hideNode.color = JMHexColor(546dac);
  hideNode.showsBadge = isHidden;
  hideNode.customLabelText = isHidden ? @"Un-Hide" : @"Hide";
  hideNode.onTap = ^{
    [[NavigationManager shared].lastVisitedPost toggleHide];
    [[NavigationManager shared] interactionIconsNeedUpdate];
  };
  return hideNode;
}

+ (JMActionMenuNode *)generateContentReportNode;
{
  BOOL isReported = [NavigationManager shared].lastVisitedPost.reported;
  JMActionMenuNode *reportNode = [JMActionMenuNode nodeWithIdent:@"content-report" iconName:@"am-icon-content-report" title:@"Report"];
  reportNode.nodeDescription = @"Report this post to moderators";
  reportNode.color = JMHexColor(e8b502);
  reportNode.showsBadge = isReported;
  reportNode.customLabelText = isReported ? @"Reported" : @"Report";
  reportNode.onTap = ^{
    [[NavigationManager shared].lastVisitedPost report];
    [[NavigationManager shared] interactionIconsNeedUpdate];
  };
  return reportNode;
}

- (NSArray *)generateScreenSpecificActionMenuNodes;
{
  BSELF(CommentsActionMenuHost);
  Post *post = self.commentsViewController.post;

  JMActionMenuNode *upvoteNode = [[self class] generateContentUpvoteNode];
  JMActionMenuNode *downvoteNode = [[self class] generateContentDownvoteNode];
  JMActionMenuNode *saveNode = [[self class] generateContentSaveNode];
  JMActionMenuNode *hideNode = [[self class] generateContentHideNode];
  JMActionMenuNode *reportNode = [[self class] generateContentReportNode];
  
  upvoteNode.showsBadgeForTraining = YES;
  downvoteNode.showsBadgeForTraining = YES;
  
  JMActionMenuNode *addCommentNode = [JMActionMenuNode nodeWithIdent:@"comments-add-comment" iconName:@"am-icon-comments-add-comment" title:@"New Comment"];
  addCommentNode.nodeDescription = @"Leave a comment related to this post";
  addCommentNode.color = JMHexColor(dc55bb);
  addCommentNode.onTap = ^{
    [blockSelf.commentsViewController addNewComment];
  };
 
  JMActionMenuNode *gotoUserNode = [JMActionMenuNode nodeWithIdent:@"content-goto-user" iconName:@"am-icon-content-goto-user" title:@"Author"];
  gotoUserNode.nodeDescription = @"Show details about author of the post";
  gotoUserNode.color = JMHexColor(70c218);
  gotoUserNode.customLabelText = post.author;
  gotoUserNode.onTap = ^{
    [[NavigationManager shared] showUserDetails:post.author];
  };
  gotoUserNode.hiddenByDefault = YES;
  
  JMActionMenuNode *gotoSubredditNode = [JMActionMenuNode nodeWithIdent:@"content-goto-subreddit" iconName:@"am-icon-global-goto-subreddit" title:@"Subreddit"];
  gotoSubredditNode.nodeDescription = @"Show more posts from this subreddit";
  gotoSubredditNode.customLabelText = [post.subreddit convertToSubredditTitle];
  gotoSubredditNode.color = JMHexColor(b480f3);
  gotoSubredditNode.onTap = ^{
    [[NavigationManager shared] showPostsForSubreddit:post.subreddit title:nil animated:YES];
  };
  gotoSubredditNode.hiddenByDefault = YES;
  
  JMActionMenuNode *switchToBrowserNode = [JMActionMenuNode nodeWithIdent:@"comments-switch-to-browser" iconName:@"am-icon-comments-switch-to-browser" title:@"Show Link"];
  switchToBrowserNode.nodeDescription = @"Show the article, photo or video";
  switchToBrowserNode.color = JMHexColor(ff5a9c);
  switchToBrowserNode.customLabelText = [NSString stringWithFormat:@"View %@", [CommentLink friendlyNameFromLinkType:post.linkType]];
  switchToBrowserNode.onTap = ^{
    [[NavigationManager shared] switchToArticle];
  };
  switchToBrowserNode.disabled = post.selfPost;
  switchToBrowserNode.hiddenByDefault = YES;
  
  JMActionMenuNode *shareNode = [JMActionMenuNode nodeWithIdent:@"content-share" iconName:@"am-icon-content-share" title:@"Share"];
  shareNode.nodeDescription = @"Share a link with friends";
  shareNode.color = JMHexColor(ff666d);
  shareNode.onTap = ^{
    [blockSelf.commentsViewController showShareOptions];
  };
  
  JMActionMenuNode *openInSafariNode = [JMActionMenuNode nodeWithIdent:@"comments-open-in-safari" iconName:@"am-icon-browser-open-in-safari" title:@"Safari"];
  openInSafariNode.nodeDescription = @"Open this thread in the Safari browser";
  openInSafariNode.color = JMHexColor(5a6aff);
  openInSafariNode.onTap = ^{
    [blockSelf.commentsViewController openThreadInSafari];
  };
  openInSafariNode.hiddenByDefault = YES;
  
  JMActionMenuNode *sortCommentsNode = [JMActionMenuNode nodeWithIdent:@"comments-sort" iconName:@"am-icon-comments-sort" title:@"Sort"];
  sortCommentsNode.nodeDescription = @"Change the display order of comments";
  sortCommentsNode.color = JMHexColor(5a6aff);
  sortCommentsNode.onTap = ^{
    [blockSelf.commentsViewController showCommentSortOptions];
  };
  
  JMActionMenuNode *showAllImagesNode = [JMActionMenuNode nodeWithIdent:@"comments-show-all-images" iconName:@"am-icon-comments-show-all-images" title:@"Show Images"];
  showAllImagesNode.nodeDescription = @"Loads all images inline with comments";
  showAllImagesNode.color = JMHexColor(9bb748);
  showAllImagesNode.onTap = ^{
    [blockSelf.commentsViewController loadAllImages];
  };
  showAllImagesNode.hiddenByDefault = YES;

  JMActionMenuNode *deletePostNode = [JMActionMenuNode nodeWithIdent:@"comments-delete-post" iconName:@"am-icon-comments-delete-post" title:@"Delete Post"];
  deletePostNode.nodeDescription = @"Removes the post from Reddit";
  deletePostNode.color = [UIColor skinColorForDestructive];
  deletePostNode.onTap = ^{
    [blockSelf.commentsViewController deletePost];
  };
  deletePostNode.disabled = !post.isMine;
  
  return @[
           upvoteNode,
           downvoteNode,
           addCommentNode,
           switchToBrowserNode,
           gotoUserNode,
           gotoSubredditNode,
           shareNode,
           openInSafariNode,
           saveNode,
           hideNode,
           reportNode,
           sortCommentsNode,
           showAllImagesNode,
           deletePostNode
           ];
}

@end