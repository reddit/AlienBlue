//
//  RedditAlienDrawing.m
//  AlienBlue
//
//  Created by J M on 6/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#include <math.h>
#import "UIBezierPath+Shapes.h"

const CGFloat kDrawAlienHeadWidth = 640.0f;
const CGFloat kDrawAlienHeadHeight = 640.0f;

const CGFloat kAlienLoadingIndicatorWidth = 200.0f;
const CGFloat kAlienLoadingIndicatorHeight = 200.0f;

void DrawAlienHead(CGContextRef context, CGRect bounds, CGColorRef alienColor, CGFloat antennaLength, CGFloat angle1, CGFloat angle2)
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kDrawAlienHeadWidth, kDrawAlienHeadHeight);
	CGFloat alignStroke;
	CGFloat resolution;
	CGMutablePathRef path;
	CGRect drawRect;
	CGFloat stroke;
	CGPoint point;
	CGAffineTransform transform;
	
	transform = CGContextGetUserSpaceToDeviceSpaceTransform(context);
	resolution = sqrtf(fabs(transform.a * transform.d - transform.b * transform.c)) * 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextClipToRect(context, bounds);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Antenna Base
    
    CGPoint p1 = CGPointMake(314.0f, 301.499f);
    
    CGPoint p2;
    p2.x = antennaLength * (cosf(angle1 * M_PI / 180)) + p1.x;
    p2.y = antennaLength * (sinf(angle1 * M_PI / 180)) + p1.y;
    
    CGPoint p3;
    p3.x = antennaLength * (cosf(angle2 * M_PI / 180)) + p2.x;
    p3.y = antennaLength * (sinf(angle2 * M_PI / 180)) + p2.y;
    
    CGRect ballRect = CGRectMake(0, 0, 84.0f, 81.846f);
    ballRect = CGRectOffset(ballRect, p3.x - (ballRect.size.width / 2), p3.y - (ballRect.size.height / 2));
    
	stroke = 20.0f;
	stroke *= resolution;
	if (stroke < 1.0f) {
		stroke = ceilf(stroke);
	} else {
		stroke = roundf(stroke);
	}
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = p1;
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = p2;
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = p3;
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
    
    
    
    //    CGColorRef strokeColor = [UIColor redColor].CGColor;
	CGContextSetStrokeColorWithColor(context, alienColor);
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
	CGContextAddPath(context, path);    
	CGContextStrokePath(context);
	CGPathRelease(path);
    
    
    
	// Layer 2
	
	// Head
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(95.0f, 301.0f, 433.0f, 276.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddEllipseInRect(path, NULL, drawRect);
	CGContextSetFillColorWithColor(context, alienColor);
	CGContextAddPath(context, path);
//	CGContextFillPath(context);
	CGPathRelease(path);
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(79.0f, 328.0f, 104.5f, 101.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddEllipseInRect(path, NULL, drawRect);
	CGContextSetFillColorWithColor(context, alienColor);
	CGContextAddPath(context, path);
//	CGContextFillPath(context);
	CGPathRelease(path);
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(437.0f, 328.0f, 104.5f, 101.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddEllipseInRect(path, NULL, drawRect);
	CGContextSetFillColorWithColor(context, alienColor);
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	

	// Antenna Ball
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
//	drawRect = CGRectMake(426.0f, 191.154f, 84.0f, 81.846f);
	ballRect.origin.x = (roundf(resolution * ballRect.origin.x + alignStroke) - alignStroke) / resolution;
	ballRect.origin.y = (roundf(resolution * ballRect.origin.y + alignStroke) - alignStroke) / resolution;
	ballRect.size.width = roundf(resolution * ballRect.size.width) / resolution;
	ballRect.size.height = roundf(resolution * ballRect.size.height) / resolution;
	CGPathAddEllipseInRect(path, NULL, ballRect);
	CGContextSetFillColorWithColor(context, alienColor);
	CGContextAddPath(context, path);

	
    CGContextFillPath(context);
    
	CGPathRelease(path);
	
	CGContextRestoreGState(context);
}





void DrawAlienLoadingIndicator(CGContextRef context, CGRect bounds, CGColorRef strokeColor, BOOL flipped)
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kAlienLoadingIndicatorWidth, kAlienLoadingIndicatorHeight);
	CGFloat alignStroke;
	CGFloat resolution;
	CGMutablePathRef path;
	CGPoint point;
	CGPoint controlPoint1;
	CGPoint controlPoint2;
	CGFloat stroke;
	CGAffineTransform transform;
	
	transform = CGContextGetUserSpaceToDeviceSpaceTransform(context);
	resolution = sqrtf(fabs(transform.a * transform.d - transform.b * transform.c)) * 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
//    CGFloat horizontalScale = flipped ? -1. : 1.;
//    CGFloat horizontalScale = -1.;
    
	CGContextSaveGState(context);
//	CGContextClipToRect(context, bounds);
    if (flipped)
    {
        CGContextTranslateCTM(context, bounds.origin.x + bounds.size.width, bounds.origin.y);
        CGContextScaleCTM(context, -1. * (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
    }
    else
    {
        CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
        CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
    }
    
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	point = CGPointMake(66.0f, 21.492f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(136.0f, 102.493f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(93.0f, 20.989f);
	controlPoint2 = CGPointMake(135.5f, 43.629f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(66.0f, 182.992f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(136.5f, 161.358f);
	controlPoint2 = CGPointMake(85.5f, 183.495f);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	CGContextSetStrokeColorWithColor(context, strokeColor);
	stroke = 22.0f;
	stroke *= resolution;
	if (stroke < 1.0f) {
		stroke = ceilf(stroke);
	} else {
		stroke = roundf(stroke);
	}
	stroke /= resolution;
	stroke *= 2.0f;
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextSaveGState(context);
	CGContextAddPath(context, path);
	CGContextEOClip(context);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
	CGPathRelease(path);
	
	CGContextRestoreGState(context);
}
