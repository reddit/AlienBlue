//
//  Comment+Style.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Comment.h"

@interface Comment (Style)
@property (readonly) NSAttributedString *styledBody;
- (CGFloat)heightForBodyConstrainedToWidth:(CGFloat)width;
- (void)flushCachedStyles;
@end
