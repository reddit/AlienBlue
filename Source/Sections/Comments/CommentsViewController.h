//
//  CommentsViewController.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "ABOutlineViewController.h"
#import "SlidingDragReleaseProtocol.h"

@class CommentPostHeaderToolbar;
@class CommentsViewController;
@class Post;

@protocol CommentsViewControllerDelegate
- (void)commentsDidFinishLoading:(CommentsViewController *)commentsViewController;
@end

@interface CommentsViewController : ABOutlineViewController <SlidingDragReleaseProtocol>
@property (strong, readonly) Post *post;
@property (strong, readonly) NSString *contextId;
@property (strong, readonly) CommentPostHeaderToolbar *headerToolbar;
@property (weak) id<CommentsViewControllerDelegate> delegate;
- (id)initWithPost:(Post *)post;
- (id)initWithPost:(Post *)post contextId:(NSString *)contextId;
- (void)fetchComments;
- (void)showAllComments;
- (void)commentsDidFinishLoading;
- (void)addPreCommentNodes;
@end
