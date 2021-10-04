//
//  CommentsViewController+Interaction.m
//  AlienBlue
//
//  Created by J M on 20/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentsViewController+Interaction.h"
#import "CommentsViewController+ReplyInteraction.h"
#import "CommentsViewController+LinkHandling.h"
#import "RedditAPI.h"
#import "RedditAPI+Account.h"
#import "CommentNode.h"
#import "CommentPostHeaderNode.h"
#import "Post+API.h"
#import "Comment+API.h"
#import "UIActionSheet+BlocksKit.h"
#import "NavigationManager.h"
#import "CommentsViewController+PopoverOptions.h"

@implementation CommentsViewController (Interaction)

- (void)toggleSavePostNode:(CommentPostHeaderNode *)postHeaderNode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    
    [postHeaderNode.post toggleSaved];
    [self reloadRowForNode:postHeaderNode];
}

- (void)toggleHidePostNode:(CommentPostHeaderNode *)postHeaderNode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    
    [postHeaderNode.post toggleHide];
    [self reloadRowForNode:postHeaderNode];
}

- (void)voteUpPostNode:(CommentPostHeaderNode *)postHeaderNode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    
    [postHeaderNode.post upvote];
    [self reloadRowForNode:postHeaderNode];
}

- (void)voteDownPostNode:(CommentPostHeaderNode *)postHeaderNode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    
    [postHeaderNode.post downvote];
    [self reloadRowForNode:postHeaderNode];
}

- (void)addCommentToPostNode:(CommentPostHeaderNode *)postHeaderNode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [self replyToPostNode:postHeaderNode];
}

- (void)voteUpCommentNode:(CommentNode *)commentNode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    
    [commentNode.comment upvote];
    [self reloadRowForNode:commentNode];
}

- (void)voteDownCommentNode:(CommentNode *)commentNode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    
    [commentNode.comment downvote];
    [self reloadRowForNode:commentNode];
}

- (void)deleteCommentNode:(CommentNode *)commentNode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [commentNode.comment deleteComment];
    [self reloadRowForNode:commentNode];
}

- (void)focusContextCommentNode:(CommentNode *)commentNode;
{
    NSString *linkId = [commentNode.comment.linkIdent stringByReplacingOccurrencesOfString:@"t3_" withString:@""];
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
    
    if (commentNode.level == 0)
    {
        parentNode = commentNode;
    }
    else
    {
        NSArray *rootCommentNodes = [self.nodes pick:^BOOL(JMOutlineNode *item) {
            return [item isKindOfClass:[CommentNode class]] && item.level == 0;
        }];
        
        parentNode = [rootCommentNodes first:^BOOL(JMOutlineNode *item) {
            return [item.allChildren containsObject:commentNode];
        }];
    }

    [parentNode collapseNode];

    NSMutableArray *affectedNodes = [NSMutableArray array];
    [affectedNodes addObject:parentNode];
    [affectedNodes addObjectsFromArray:[parentNode allChildren]];
    [self reloadRowsForNodes:affectedNodes];
    [self scrollToNode:parentNode];
}

- (void)showMoreOptionsForCommentNode:(CommentNode *)commentNode;
{
    [self showOptionsForComment:commentNode.comment];
}

- (void)addCommentToCommentNode:(CommentNode *)commentNode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [self replyToCommentNode:commentNode];
}

@end
