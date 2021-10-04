//
//  CommentNode.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "BaseStyledTextNode.h"
#import "Comment.h"
#import "Post.h"

@interface CommentNode : BaseStyledTextNode
@property (strong) Comment *comment;
@property (strong) Post *post;
@property BOOL firstComment;
@property BOOL isContext;
- (id)initWithComment:(Comment *)comment level:(NSUInteger)level;
+ (CommentNode *)nodeForComment:(Comment *)comment level:(NSUInteger)level;
- (void)prefetchThumbnails;
@end
