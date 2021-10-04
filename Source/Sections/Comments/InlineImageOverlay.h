//
//  InlineImageOverlay.h
//  AlienBlue
//
//  Created by J M on 1/01/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMViewOverlay.h"

@class InlineImageNode;

@interface InlineImageOverlay : JMViewOverlay
- (void)updateForNode:(InlineImageNode *)node;
+ (CGFloat)heightForInlinePreviewForNode:(InlineImageNode *)node constrainedToWidth:(CGFloat)width;
+ (void)precacheImageForNode:(InlineImageNode *)node constrainedToWidth:(CGFloat)width;
@end
