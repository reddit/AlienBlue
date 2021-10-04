//
//  UIBezierPath+Shapes.m
//  AlienBlue
//
//  Created by J M on 17/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "UIBezierPath+Shapes.h"

CGPoint ShiftPoint(CGPoint point, CGFloat width, CGFloat angle)
{
    CGPoint shiftedPoint;
    shiftedPoint.x = width * (cosf(angle * M_PI / 180)) + point.x;
    shiftedPoint.y = width * (sinf(angle * M_PI / 180)) + point.y;
    return shiftedPoint;
}

@implementation UIBezierPath (Shapes)

+ (UIBezierPath *)bezierPathWithTriangleCenter:(CGPoint)center sideLength:(CGFloat)length angle:(CGFloat)angle;
{
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    CGFloat offset = length * (sinf(60. * M_PI / 180)) / 2.;
    CGPoint ctr = CGPointMake(-offset, offset);
    CGPoint point1 = ShiftPoint(ctr, length, 300.);
    CGPoint point2 = ShiftPoint(point1, length, 60);
    CGPoint point3 = ShiftPoint(point2, length, 180.);
    [aPath moveToPoint:point1];
    [aPath addLineToPoint:point2];
    [aPath addLineToPoint:point3];
    [aPath addLineToPoint:point1];
    
    CGFloat radianAngle = angle * M_PI / 180.;
    CGAffineTransform rotation = CGAffineTransformMakeRotation(radianAngle);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    [aPath applyTransform:rotation];
    [aPath applyTransform:translation];
    return aPath;
}

@end
