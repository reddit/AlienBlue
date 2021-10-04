//
//  NInlineImageCell.h
//  AlienBlue
//
//  Created by J M on 1/01/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMOutlineCell.h"
#import "CommentLink.h"

@interface InlineImageNode : JMOutlineNode
@property (strong) CommentLink *commentLink;
@property (strong) NSNumber *inlineImageAspectRatio;
@end

@interface NInlineImageCell : JMOutlineCell
@end
