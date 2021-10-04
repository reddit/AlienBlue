//
//  ABTableCellView.m
//  AlienBlue
//
//  Created by JM on 13/11/10.
//  Copyright (c) 2010 The Design Shed. All rights reserved.
//

#import "ABTableCellView.h"
#import "Resources.h"
#import "MarkupEngine.h"

@interface ABTableCellView()
@property (nonatomic,strong) ABTableCellDrawerView *drawerView;
@end

@implementation ABTableCellView

@synthesize drawerView = drawerView_;

- (void)dealloc {
	if (_frame)
		CFRelease(_frame);	
    
    
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


- (void) roundCornersForContext:(CGContextRef) c forRect:(CGRect) rect withRadius:(int) corner_radius
{  
    int x_left = rect.origin.x;  
    int x_left_center = rect.origin.x + corner_radius;  
    int x_right_center = rect.origin.x + rect.size.width - corner_radius;  
    int x_right = rect.origin.x + rect.size.width;  
    int y_top = rect.origin.y;  
    int y_top_center = rect.origin.y + corner_radius;  
    int y_bottom_center = rect.origin.y + rect.size.height - corner_radius;  
    int y_bottom = rect.origin.y + rect.size.height;  
	
    CGContextBeginPath(c);  
    CGContextMoveToPoint(c, x_left, y_top_center);  
	
    CGContextAddArcToPoint(c, x_left, y_top, x_left_center, y_top, corner_radius);  
    CGContextAddLineToPoint(c, x_right_center, y_top);  
	
    CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top_center, corner_radius);  
    CGContextAddLineToPoint(c, x_right, y_bottom_center);  
	
    CGContextAddArcToPoint(c, x_right, y_bottom, x_right_center, y_bottom, corner_radius);  
    CGContextAddLineToPoint(c, x_left_center, y_bottom);  
	
    CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom_center, corner_radius);  
    CGContextAddLineToPoint(c, x_left, y_top_center);  
	
    CGContextClosePath(c);  
}

// use this to get the draw rect for an image
- (CGRect)firstRectForNSRange:(NSRange)range; {
    int index = range.location;
    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(_frame);
    for (int i = 0; i < [lines count]; i++) {
        CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        int localIndex = index - lineRange.location;
        if (localIndex >= 0 && localIndex < lineRange.length) {
            int finalIndex = MIN(lineRange.location + lineRange.length,
								 range.location + range.length);
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, index, NULL);
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, finalIndex, NULL);
            CGPoint origin;
			CTFrameGetLineOrigins(_frame, CFRangeMake(i, 1), &origin);
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
			
            return CGRectMake(xStart, origin.y - descent, xEnd - xStart, ascent + descent);
        }
    }
    return CGRectNull;
}

- (NSInteger)closestIndexToPoint:(CGPoint)point {
    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(_frame);
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, lines.count), origins);
	
    for (int i = 0; i < lines.count; i++) {
        if (point.y > origins[i].y) {
            CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
            return CTLineGetStringIndexForPosition(line, point);
        }
    }
    return  -1;
}


- (NSString *) checkForLinkInAttributedString:(NSAttributedString *) attributedString atTouchPoint:(CGPoint)touchPoint
{
	if (![MarkupEngine doesSupportMarkdown])
		return nil;
    
	CFAttributedStringRef attributedContentBody = (__bridge CFAttributedStringRef) attributedString;
	
	if (!attributedContentBody || ![attributedString isKindOfClass:[NSAttributedString class]])
		return nil;
	
	CGPoint np = touchPoint;
	CGRect rect = attributedContentRect;
    
	np = CGPointApplyAffineTransform(np, CGAffineTransformMakeTranslation(-rect.origin.x, -(rect.origin.y + rect.size.height)));
	np = CGPointApplyAffineTransform(np, CGAffineTransformMakeScale(1.0f,-1.0f));
	np = CGPointApplyAffineTransform(np, CGAffineTransformMakeTranslation(0, rect.origin.y));
	
	np.y = np.y - rect.origin.y;
	
//	NSLog(@"Transfor TouchPoint %f : %f", np.x, np.y);	
    
	// here we need to check for links above and below the touch point as well, to reduce the
	// accuracy needed to tap the link
    
	for (int i = -1; i <= 1; i++)
	{
		CGPoint testPoint = np;		
		// we'll use a 5 pixel margin to test for links
		testPoint.y += (i * 5);
		
		CFIndex indexPoint = [self closestIndexToPoint:testPoint];
		if (indexPoint > 0 && indexPoint < CFAttributedStringGetLength(attributedContentBody))
		{
			NSString * link_url = (__bridge NSString *) CFAttributedStringGetAttribute(attributedContentBody, indexPoint, CFSTR("link_url"), NULL);
			if (link_url)
			{
			//	NSLog(@"[*] Link found at location : %@", [link_url description]);
				return link_url;
			}
		}
	}
	
	return nil;	
}


- (void) drawImagesInAttributedString:(NSAttributedString *) attributedString
{
//	return;
//	NSLog(@"drawImagesInAttributedString in");
	NSString * stringRep = [attributedString string];
	NSInteger startIndex = 0;
	NSInteger location = -1;
	while((location = [stringRep rangeOfString:@"\ufffc" options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex, [stringRep length] - startIndex)].location) != NSNotFound)
	{
//	//	NSLog(@"found image at location: %d", location);

		NSAttributedString * imageAttributedString = [attributedString attributedSubstringFromRange:NSMakeRange(location,1)];
		UIImage * image = [imageAttributedString attribute:kABCoreTextImage atIndex:0 effectiveRange:nil];
		CGRect imageRect = [self firstRectForNSRange:NSMakeRange(location,1)];

		CGRect rect = attributedContentRect;
		CGRect transformedRect = imageRect;		

		transformedRect = CGRectApplyAffineTransform(transformedRect, CGAffineTransformMakeTranslation(-rect.origin.x, -(rect.origin.y + rect.size.height)));		
		transformedRect = CGRectApplyAffineTransform(transformedRect, CGAffineTransformMakeScale(1.0f,-1.0f));		
		transformedRect = CGRectApplyAffineTransform(transformedRect, CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y));

		transformedRect.origin.y -= rect.origin.y;
		transformedRect.origin.x += rect.origin.x;

		// this check handles the callback ascent bug (seen in iOS < 4.2).  if this bug exists, we skip drawing the
		// image, otherwise it will render over text.
//			fabs(imageRect.size.height - image.size.height) < 1.)		
		if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.0"] ||
			[[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.1"])
		{
			[image drawInRect:CGRectMake(transformedRect.origin.x, transformedRect.origin.y - 6., 28., 28. * [image size].width / [image size].height)];
		}
		else 
		{
			[image drawInRect:CGRectMake(transformedRect.origin.x, transformedRect.origin.y, [image size].width, [image size].height)];
		}
		startIndex = location + 1;
	}
}

- (void) drawAttributedString:(NSAttributedString *) attributedString inBounds:(CGRect) rect
{
    CFAttributedStringRef markedContent = (__bridge CFAttributedStringRef) attributedString;
	attributedContentRect	= rect;
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, rect);
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(markedContent);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
												CFRangeMake(0, 0), path, NULL);
    
	if (_frame)
		CFRelease(_frame);
	
	_frame = frame;
	
	CFRelease(path);
	CFRelease(framesetter);
	if (frame)
	{
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, 0, rect.origin.y); 	
		CGContextScaleCTM(context, 1.0, -1.0);	
		CGContextTranslateCTM(context, 0, -(rect.origin.y + rect.size.height)); 	
		CTFrameDraw(frame, context);
		CGContextRestoreGState(context);
        
		_context = context;			
	}    

    
	// render any images that were added to this attributed string
	[self drawImagesInAttributedString:attributedString];
	
}

//- (void) initialiseBaseOriginForIndex:(int)anIndex inBounds:(CGRect) frameBounds;
//{
//	CGPoint baselineOriginOffset = CGPointZero;
//	CTFrameGetLineOrigins(_frame, CFRangeMake(anIndex, 1), &baselineOriginOffset);
//	_baselineOrigin = CGPointMake(frameBounds.origin.x + baselineOriginOffset.x, frameBounds.origin.y + baselineOriginOffset.y);
//}
//
//- (CGPoint)baselineOriginForCharacterAtIndex:(CFIndex)anIndex
//{
//    CGFloat charOffset = 0.0;
//    CTLineGetOffsetForStringIndex(_line, anIndex, &charOffset);
//    return CGPointMake(_baselineOrigin.x + charOffset, _baselineOrigin.y);
//}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	currentTouchPoint = [[touches anyObject] locationInView:self];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	currentTouchPoint = CGPointZero;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	currentTouchPoint = [[touches anyObject] locationInView:self];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	currentTouchPoint = CGPointZero;
}

- (void) addDrawerView:(ABTableCellDrawerView *)drawerView;
{
    [self removeDrawerView];
    self.drawerView = drawerView;
    CGRect drawerFrame = CGRectMake(0., self.bounds.size.height - kABTableCellDrawerHeight, self.bounds.size.width, kABTableCellDrawerHeight);
    self.drawerView.frame = drawerFrame;
    [self addSubview:self.drawerView];
}

- (void)removeDrawerView;
{
    [self.drawerView removeFromSuperview];
    self.drawerView = nil;
}

@end
