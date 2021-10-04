//
//  CommentsViewController+ReplyInteraction.h
//  AlienBlue
//
//  Created by J M on 23/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentEntryViewController.h"

@class CommentPostHeaderNode;
@class CommentNode;
@class BaseStyledTextNode;

@interface CommentsViewController (ReplyInteraction) <CommentEntryDelegate>
- (void)replyToPostNode:(CommentPostHeaderNode *)headerNode;
- (void)replyToCommentNode:(CommentNode *)node;
- (void)afterCommentReply:(NSDictionary *)newComment;
- (BaseStyledTextNode *)nodeForElementId:(NSString *)elementId;
- (void)showLegacyCommentEntryForDictionary:(NSDictionary *)rawDictionary editing:(BOOL)editing;
@end
