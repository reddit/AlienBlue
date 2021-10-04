//
//  CommentsViewController+PopoverOptions.h
//  AlienBlue
//
//  Created by J M on 25/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentsViewController.h"
#import <MessageUI/MessageUI.h>

@class Comment;
@interface CommentsViewController (PopoverOptions)
- (void)showOptionsForComment:(Comment *)comment;
- (void)popupExtraOptionsActionSheet:(id)sender;

- (void)showCommentSortOptions;
- (void)showShareOptions;
- (void)addNewComment;
- (void)deletePost;
- (void)loadAllImages;
- (void)openThreadInSafari;

@end
