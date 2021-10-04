//
//  UIImage+Assets.m
//  AlienBlue
//
//  Created by J M on 15/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "UIImage+Assets.h"
#import "UIImage+Skin.h"
#import "Resources.h"

@implementation UIImage (Assets)

+ (UIImage *)gradientBackground;
{
  UIImage *img = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    UIColor *startColor = [Resources isNight] ? [UIColor colorWithHex:0x222322] : [UIColor colorWithHex:0xf2f2f2];
    UIColor *endColor = [Resources isNight] ? [UIColor colorWithHex:0x1e1e1e] : [UIColor colorWithHex:0xe9e9e9];
    [UIView drawGradientInRect:bounds minHeight:150. startColor:startColor endColor:endColor];
  } opaque:YES withSize:CGSizeMake(51., 51.) cacheKey:[NSString stringWithFormat:@"%d-panel-gradient-bg", [Resources isNight]]];
  return [img jm_resizeable];
}

@end
