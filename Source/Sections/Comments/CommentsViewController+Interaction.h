//
//  CommentsViewController+Interaction.h
//  AlienBlue
//
//  Created by J M on 20/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentsViewController.h"

@class CommentPostHeaderNode;
@class CommentNode;

@interface CommentsViewController (Interaction)

- (void)toggleSavePostNode:(CommentPostHeaderNode *)postHeaderNode;
- (void)toggleHidePostNode:(CommentPostHeaderNode *)postHeaderNode;
- (void)voteUpPostNode:(CommentPostHeaderNode *)postHeaderNode;
- (void)voteDownPostNode:(CommentPostHeaderNode *)postHeaderNode;

- (void)collapseToRootCommentNode:(CommentNode *)commentNode;
- (void)showMoreOptionsForCommentNode:(CommentNode *)commentNode;
- (void)addCommentToPostNode:(CommentPostHeaderNode *)postHeaderNode;
- (void)voteUpCommentNode:(CommentNode *)commentNode;
- (void)voteDownCommentNode:(CommentNode *)commentNode;

- (void)deleteCommentNode:(CommentNode *)commentNode;
- (void)focusContextCommentNode:(CommentNode *)commentNode;
@end
