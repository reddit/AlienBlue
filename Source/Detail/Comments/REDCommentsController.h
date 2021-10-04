//  REDCommentsController.h
//  RedditApp

#import "Common/Views/ABOutlineViewController.h"
#import "iPad/SlidingDragReleaseProtocol.h"

@class CommentPostHeaderToolbar;
@class REDCommentsController;
@class REDDetailViewController;
@class Post;

@protocol REDCommentsControllerDelegate
- (void)commentsDidFinishLoading:(REDCommentsController *)commentsController;
@end

@interface REDCommentsController : NSObject<SlidingDragReleaseProtocol>
@property(nonatomic, readonly) Post *post;
@property(nonatomic, readonly) NSString *contextId;
@property(nonatomic, readonly, weak) REDDetailViewController *detailViewController;
@property(nonatomic, readonly) CommentPostHeaderToolbar *headerToolbar;
@property(nonatomic, readonly) NSMutableArray *nodes;
@property(weak) id<REDCommentsControllerDelegate> delegate;
- (id)initWithPost:(Post *)post;
- (id)initWithPost:(Post *)post contextId:(NSString *)contextId;
- (id)initWithPost:(Post *)post
               contextId:(NSString *)contextId
    detailViewController:(__weak REDDetailViewController *)detailViewController;
- (void)fetchComments;
- (void)showAllComments;
- (void)commentsDidFinishLoading;
- (void)addPreCommentNodes;
@end
