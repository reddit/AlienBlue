//
//  Post+Style.h
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Post.h"

@interface Post (Style)
- (NSAttributedString *)styledTitle;
- (NSAttributedString *)styledTitleWithDetails;

- (CGFloat)titleHeightConstrainedToWidth:(CGFloat)width;

- (void)flushCachedStyles;
- (void)preprocessStyles;

- (void)drawTitleCenteredVerticallyInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawSubdetailsInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawCommentCountInRect:(CGRect)rect context:(CGContextRef)context;
- (void)drawTimeAgoInRect:(CGRect)rect context:(CGContextRef)context;

- (UIColor *)linkFlairBackgroundColorForPresentation;

@end
