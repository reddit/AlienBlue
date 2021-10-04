//  REDCommentsController+Interaction.h
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController.h"

@class CommentPostHeaderNode;
@class CommentNode;

@interface REDCommentsController (Interaction)

- (void)toggleSavePostNode:(CommentPostHeaderNode *)postHeaderNode;
- (void)toggleHidePostNode:(CommentPostHeaderNode *)postHeaderNode;
- (void)voteUpPostNode:(CommentPostHeaderNode *)postHeaderNode;
- (void)voteDownPostNode:(CommentPostHeaderNode *)postHeaderNode;

- (void)collapseToRootCommentNode:(CommentNode *)commentNode;

- (void)deleteCommentNode:(CommentNode *)commentNode;
- (void)focusContextCommentNode:(CommentNode *)commentNode;
@end
