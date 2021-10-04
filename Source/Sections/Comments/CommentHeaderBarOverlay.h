//
//  CommentHeaderBarOverlay.h
//  AlienBlue
//
//  Created by J M on 17/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMViewOverlay.h"
#import "CommentNode.h"

#define kCommentHeaderBarOverlayHeight 29.

@interface CommentHeaderBarOverlay : JMViewOverlay

@property CGFloat horizontalPadding;

- (void)updateForCommentNode:(CommentNode *)commentNode;

@end
