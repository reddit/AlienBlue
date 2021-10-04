//  REDCommentsController+ReplyInteraction.h
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController.h"
#import "Sections/Comments/CommentEntryViewController.h"

@class CommentPostHeaderNode;
@class CommentNode;
@class BaseStyledTextNode;

@interface REDCommentsController (ReplyInteraction)<CommentEntryDelegate>
- (void)replyToPostNode:(CommentPostHeaderNode *)headerNode;
- (void)replyToCommentNode:(CommentNode *)node;
- (void)afterCommentReply:(NSDictionary *)newComment;
- (BaseStyledTextNode *)nodeForElementId:(NSString *)elementId;
- (void)showLegacyCommentEntryForDictionary:(NSDictionary *)rawDictionary editing:(BOOL)editing;
@end
