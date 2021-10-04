//
//  UINavigationBar+ABStyle.m
//  AlienBlue
//
//  Created by JM on 29/12/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "UINavigationBar+ABStyle.h"
#import "UIView+Additions.h"

@implementation UINavigationBar (UINavigationBar_ABStyle)

- (void) drawGradientInRect:(CGRect) rect
{
  CGContextRef currentContext = UIGraphicsGetCurrentContext();

  CGGradientRef glossGradient;
  CGColorSpaceRef rgbColorspace;
  size_t num_locations = 4;
  CGFloat locations[4] = { 0.0, 0.7, 0.98, 1.0};

  CGFloat nightModeComponents[16] = {
    0.35, 0.35, 0.35, 0.2,
    0.06, 0.06, 0.06, 0.2, 
    0.06, 0.06, 0.06, 0.2, 
    0.45, 0.45, 0.45, 0.2,
	};
	
  rgbColorspace = CGColorSpaceCreateDeviceRGB();
  glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, nightModeComponents, locations, num_locations);

  CGRect currentBounds = self.bounds;
  CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
  CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), currentBounds.size.height);
  CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);

  CGGradientRelease(glossGradient);
  CGColorSpaceRelease(rgbColorspace); 	
}

@end