//
//  Post+Style_iPad.h
//  AlienBlue
//
//  Created by J M on 20/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "Post.h"

@interface Post (Style_iPad)
- (void)drawSubdetailsInRect_iPad:(CGRect)rect context:(CGContextRef)context;
- (NSAttributedString *)styledTitleWithDetails_iPad;
@end
