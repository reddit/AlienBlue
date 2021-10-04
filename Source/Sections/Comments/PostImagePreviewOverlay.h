//
//  PostImagePreviewOverlay.h
//  AlienBlue
//
//  Created by J M on 20/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMViewOverlay.h"

#import "CommentPostHeaderNode.h"

@interface PostImagePreviewOverlay : JMViewOverlay

- (void)updateForNode:(CommentPostHeaderNode *)node;
+ (CGFloat)heightForInlinePreviewForNode:(CommentPostHeaderNode *)node constrainedToWidth:(CGFloat)width;
@end
