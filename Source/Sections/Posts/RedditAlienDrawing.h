//
//  RedditAlienDrawing.h
//  AlienBlue
//
//  Created by J M on 6/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#include <CoreGraphics/CoreGraphics.h>

extern const CGFloat kDrawAlienHeadWidth;
extern const CGFloat kDrawAlienHeadHeight;

extern void DrawAlienHead(CGContextRef context, CGRect bounds, CGColorRef alienColor, CGFloat antennaLength, CGFloat angle1, CGFloat angle2);
extern void DrawAlienLoadingIndicator(CGContextRef context, CGRect bounds, CGColorRef strokeColor, BOOL flipped);
