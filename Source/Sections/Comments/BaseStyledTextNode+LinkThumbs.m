//
//  CommentNode+LinkThumbs.m
//  AlienBlue
//
//  Created by J M on 18/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "BaseStyledTextNode+LinkThumbs.h"

@implementation BaseStyledTextNode (LinkThumbs)
SYNTHESIZE_ASSOCIATED_STRONG(NSNumber, inlineImageAspectRatio, InlineImageAspectRatio);
SYNTHESIZE_ASSOCIATED_WEAK(CommentLink, inlinePreviewLink, InlinePreviewLink);
@end
