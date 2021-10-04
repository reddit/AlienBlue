//
//  CommentNode+LinkThumbs.h
//  AlienBlue
//
//  Created by J M on 18/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "BaseStyledTextNode.h"
#import "CommentLink.h"

@interface BaseStyledTextNode (LinkThumbs)
@property (nonatomic, ab_weak) CommentLink *inlinePreviewLink;
@property (strong) NSNumber *inlineImageAspectRatio;
@end
