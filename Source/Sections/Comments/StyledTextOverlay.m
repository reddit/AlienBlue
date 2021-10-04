//
//  StyledTextOverlay.m
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "StyledTextOverlay.h"
#import "MarkupEngine.h"

@interface StyledTextOverlay()
@property (strong) NSAttributedString *attributedString;
@property CGRect attributedContentRect;
@property CTFrameRef ctFrame;
@property CGContextRef context;
@property CGPoint lastTouchPoint;
- (NSString *)checkForLinkInAttributedString:(NSAttributedString *)attributedString atTouchPoint:(CGPoint)touchPoint;
@end

@implementation StyledTextOverlay
@synthesize attributedContentRect = attributedContentRect_;
@synthesize ctFrame = ctFrame_;
@synthesize context = context_;

- (void)dealloc
{
	if (ctFrame_)
		CFRelease(ctFrame_);	
}

- (id)init;
{
    self = [super init];
    if (self)
    {
        self.allowTouchPassthrough = NO;
        self.redrawsOnTouch = NO;
        
        BSELF(StyledTextOverlay);
        self.onTap = ^(CGPoint touchPoint) 
        {
            blockSelf.lastTouchPoint = touchPoint;
            NSString *link = [blockSelf checkForLinkInAttributedString:blockSelf.attributedString atTouchPoint:touchPoint];
            blockSelf.linkTapped(link, touchPoint);
        };
        self.onPress = ^(CGPoint touchPoint)
        {
            blockSelf.lastTouchPoint = touchPoint;
            NSString *link = [blockSelf checkForLinkInAttributedString:blockSelf.attributedString atTouchPoint:touchPoint];
            blockSelf.linkPressed(link, touchPoint);
        };
    }
    return self;
}

//- (void)setFrame:(CGRect)frame;
//{
//    self.redrawsOnTouch = frame.size.height < 350.;
//    [super setFrame:frame];
//}

- (void)updateWithAttributedString:(NSAttributedString *)attributedString;
{
    self.attributedString = attributedString;
//    self.redrawsOnTouch = [attributedString length] < 10;
    [self setNeedsDisplay];
}

// use this to get the draw rect for an image
- (CGRect)firstRectForNSRange:(NSRange)range;
{
    int index = range.location;
    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(ctFrame_);
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
			CTFrameGetLineOrigins(ctFrame_, CFRangeMake(i, 1), &origin);
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
			
            return CGRectMake(xStart, origin.y - descent, xEnd - xStart, ascent + descent);
        }
    }
    return CGRectNull;
}

- (NSInteger)closestIndexToPoint:(CGPoint)point {
    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(ctFrame_);
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(ctFrame_, CFRangeMake(0, lines.count), origins);
	
    for (int i = 0; i < lines.count; i++) {
        if (point.y > origins[i].y) {
            CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
            return CTLineGetStringIndexForPosition(line, point);
        }
    }
    return  -1;
}


- (NSString *)checkForLinkInAttributedString:(NSAttributedString *)attributedString atTouchPoint:(CGPoint)touchPoint
{
	if (![MarkupEngine doesSupportMarkdown])
		return nil;
    
	CFAttributedStringRef attributedContentBody = (__bridge CFAttributedStringRef) attributedString;
	
	if (!attributedContentBody || ![attributedString isKindOfClass:[NSAttributedString class]])
		return nil;
	
	CGPoint np = touchPoint;
	CGRect rect = self.attributedContentRect;
    
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
        
		CGRect rect = self.attributedContentRect;
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

//- (void) drawAttributedString:(NSAttributedString *) attributedString inBounds:(CGRect)rect cropRect:(CGRect)cropRect;
- (void) drawAttributedString:(NSAttributedString *) attributedString inBounds:(CGRect)rect;
{
    CFAttributedStringRef markedContent = (__bridge CFAttributedStringRef) attributedString;
	self.attributedContentRect	= rect;
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, rect);
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(markedContent);

    if (framesetter)
    {
        CTFrameRef cframe = CTFramesetterCreateFrame(framesetter,
                                                    CFRangeMake(0, 0), path, NULL);
        if (cframe)
        {
        
            if (ctFrame_)
                CFRelease(ctFrame_);
            
            ctFrame_ = cframe;
            
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, 0, rect.origin.y); 	
            CGContextScaleCTM(context, 1.0, -1.0);	
            CGContextTranslateCTM(context, 0, -(rect.origin.y + rect.size.height));

//            if (!CGRectEqualToRect(cropRect, rect))
//            {
//                CGRect cropRect_ = cropRect;
//                cropRect_.origin.y = rect.size.height - cropRect.size.height - cropRect.origin.y;
//                CGContextClipToRect(context, cropRect_);
//            }
            CTFrameDraw(cframe, context);
            CGContextRestoreGState(context);
            
            context_ = context;			
        }
                
        CFRelease(framesetter);
        
        // render any images that were added to this attributed string
        [self drawImagesInAttributedString:attributedString];
    }
    
    if (path)
    {
        CFRelease(path);
    }

}

- (void)drawRect:(CGRect)dirtyRect;
{
//    [[UIColor orangeColor] set];
//    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    
    // Bump the bounds slightly, as 4.2.1 renders the text a bit lower, so it cuts off
    // the last line.
    CGRect bounds = self.bounds;
    bounds.size.height += 20.;
    
//    DLog(@"dirtyRect: %@", NSStringFromCGRect(dirtyRect));
//    DLog(@"drawing: %d", self.highlighted);

//    CGRect cropRect = bounds;
//
    if (self.highlighted)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetAlpha(context, 0.7);
    }
    
//    [UIView startEtchedDraw];
    [self drawAttributedString:self.attributedString inBounds:bounds];
//    [UIView endEtchedDraw];
}

@end
