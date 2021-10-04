//
//  CommentPostHeaderNode.h
//  AlienBlue
//
//  Created by J M on 19/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "BaseStyledTextNode.h"
#import "Post.h"
#import "Comment.h"

@interface CommentPostHeaderNode : BaseStyledTextNode
@property (strong) Post *post;
@property (strong) Comment *comment;

@property (strong) NSNumber *inlineImageAspectRatio;
@property BOOL isPlaceholderPost;
@property BOOL forceImageLoad;

+ (CommentPostHeaderNode *)nodeForHeaderPost:(Post *)post;
+ (CommentPostHeaderNode *)placeholderNodeForPost:(Post *)post;

@end
