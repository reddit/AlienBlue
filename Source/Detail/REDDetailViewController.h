//  REDDetailViewController.h
//  RedditApp

#import <UIKit/UIKit.h>

#import "Common/Views/ABOutlineViewController.h"

@class CommentNode;
@class Post;

@interface REDDetailViewController : ABOutlineViewController

// Color used for things like the navigation bar.
@property(nonatomic, readonly) UIColor *keyColor;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPost:(Post *)link;

- (void)prepareWebViewControllerWithURL:(NSURL *)url title:(NSString *)title;
- (void)presentWebViewController;

#pragma mark - Comment Interaction

- (void)showMoreOptionsForCommentNode:(CommentNode *)commentNode;
- (void)addCommentToCommentNode:(CommentNode *)commentNode;
//- (void)addCommentToPostNode:(CommentPostHeaderNode *)postHeaderNode;
- (void)voteUpCommentNode:(CommentNode *)commentNode;
- (void)voteDownCommentNode:(CommentNode *)commentNode;

@end
