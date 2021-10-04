//
//  NSAttributedString+ABAdditions.m
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "NSAttributedString+ABAdditions.h"

@implementation NSAttributedString (ABAdditions)

- (CGFloat)heightConstrainedToWidth:(CGFloat)width;
{
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);

    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self length]), NULL, CGSizeMake(width, CGFLOAT_MAX), NULL);
    
    CGSize finalSize = CGSizeMake(ceilf(suggestedSize.width), ceilf(suggestedSize.height));
    
	CFRelease(framesetter);
    
    return finalSize.height;
    
//    return CGSizeMake(ceilf(suggestedSize.width), ceilf(suggestedSize.height));

//	CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
//	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
//	
//	CGSize newSize = 
//	CTFramesetterSuggestFrameSizeWithConstraints(
//												 framesetter, 
//												 CFRangeMake(0,0),
//												 NULL,
//												 maxSize,
//												 NULL
//												 );
//	CFRelease(framesetter);
//	
//	return roundf(newSize.height);
}

- (void)drawInRect:(CGRect)rect;
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    CFAttributedStringRef markedContent = (__bridge CFAttributedStringRef) self;
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, rect);
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(markedContent);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
												CFRangeMake(0, 0), path, NULL);
	if (frame)
	{
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, 0, rect.origin.y); 	
		CGContextScaleCTM(context, 1.0, -1.0);	
		CGContextTranslateCTM(context, 0, -(rect.origin.y + rect.size.height)); 	
		CTFrameDraw(frame, context);
		CGContextRestoreGState(context);
        CFRelease(frame);
	}
    
	CFRelease(path);
	CFRelease(framesetter);
}

- (void)drawCenteredVerticallyInRect:(CGRect)bounds;
{
    CGFloat textHeight = [self heightConstrainedToWidth:bounds.size.width];
    CGFloat adjustmentY = (bounds.size.height - textHeight) / 2.;
    CGRect textRect = CGRectOffset(bounds, 0, adjustmentY);
    textRect.size.height = textRect.size.height - adjustmentY;

    // on older devices, the bottom part of the text gets cut off
    textRect.size.height += 6.;

    // adjust for text baseline
    textRect.origin.y -= 3.;
    
    [self drawInRect:textRect];
}



@end
