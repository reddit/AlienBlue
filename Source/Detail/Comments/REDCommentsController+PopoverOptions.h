//  REDCommentsController+PopoverOptions.h
//  RedditApp

#import <MessageUI/MessageUI.h>

#import "RedditApp/Detail/Comments/REDCommentsController.h"

@class Comment;
@interface REDCommentsController (PopoverOptions)
- (void)showOptionsForComment:(Comment *)comment;
- (void)popupExtraOptionsActionSheet:(id)sender;

- (void)showCommentSortOptions;
- (void)showShareOptions;
- (void)addNewComment;
- (void)deletePost;
- (void)loadAllImages;
- (void)openThreadInSafari;

@end
