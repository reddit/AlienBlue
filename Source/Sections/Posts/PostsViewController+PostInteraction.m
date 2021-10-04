//
//  PostsViewController+PostInteraction.m
//  AlienBlue
//
//  Created by J M on 10/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController+PostInteraction.h"
#import "RedditAPI.h"
#import "NavigationManager.h"
#import "Post+API.h"
#import "Post+Style.h"
#import "UIActionSheet+BlocksKit.h"
#import "RedditAPI+Account.h"

@implementation PostsViewController (PostInteraction)

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
    if (postNode.post.hidden)
    {
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
    BSELF(PostsViewController);
    
    [action bk_setDestructiveButtonWithTitle:@"Report" handler:^{
        [postNode.post report];
        [blockSelf reloadRowForNode:postNode];
    }];
    
    [action bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [action jm_showInView:[NavigationManager mainView]];
}

@end
