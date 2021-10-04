//
//  LinkThumbsOverlay.h
//  AlienBlue
//
//  Created by J M on 18/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMViewOverlay.h"
#import "BaseStyledTextNode.h"

@class CommentLink;

@interface LinkThumbsOverlay : JMViewOverlay
@property CGRect commentTextRect;
- (void)updateForNode:(BaseStyledTextNode *)commentNode;
- (void)drawThumbnailForCommentLink:(CommentLink *)commentLink inFrame:(CGRect)thumbnailRect;
+ (CGFloat)heightForLinkThumbsOverlayForNode:(BaseStyledTextNode *)commentNode constrainedToWidth:(CGFloat)width textWidth:(CGFloat)textWidth;
- (void)openCommentLink:(CommentLink *)commentLink forceBrowser:(BOOL)forceBrowser;
@end
