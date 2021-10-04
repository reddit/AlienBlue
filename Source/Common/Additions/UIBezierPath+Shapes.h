//
//  UIBezierPath+Shapes.h
//  AlienBlue
//
//  Created by J M on 17/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Shapes)
+ (UIBezierPath *)bezierPathWithTriangleCenter:(CGPoint)center sideLength:(CGFloat)length angle:(CGFloat)angle;
@end
