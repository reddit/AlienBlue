//
//  NSAttributedString+ABAdditions.h
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (ABAdditions)

- (CGFloat)heightConstrainedToWidth:(CGFloat)width;

- (void)drawInRect:(CGRect)rect;
- (void)drawCenteredVerticallyInRect:(CGRect)bounds;
@end
