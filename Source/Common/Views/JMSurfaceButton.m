//
//  JMSurfaceButton.m
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMSurfaceButton.h"
#import "UIColor+Hex.h"
#import "UIImage+Skin.h"

@interface JMSurfaceButton()
@property (strong) UIImage *etchedImage;
@property JMSurfaceLevel surfaceLevel;
@end

@implementation JMSurfaceButton

- (id)initWithFrame:(CGRect)frame skinImageNamed:(NSString *)imageName imageColor:(UIColor *)color surfaceLevel:(JMSurfaceLevel)surfaceLevel;
{
    if ((self = [super initWithFrame:frame]))
    {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.etchedImage = [UIImage etchedSkinImageNamed:imageName withColor:color inset:(surfaceLevel == JMSurfaceLevelInset)];
        self.surfaceLevel = surfaceLevel;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGFloat imageOpacity = self.highlighted ? 0.8 : 1.;
    CGRect imageRect = CGRectInset(self.bounds, (self.bounds.size.width - self.etchedImage.size.width) / 2, (self.bounds.size.height - self.etchedImage.size.height) / 2);
    
    [self.etchedImage drawAtPoint:imageRect.origin blendMode:kCGBlendModeNormal alpha:imageOpacity];

//    UIColor *insetColor = (self.surfaceLevel == JMSurfaceLevelInset) ? [UIColor colorWithWhite:0. alpha:shadowAlpha] : [UIColor colorWithWhite:1. alpha:shadowAlpha];
//    UIColor *shadowColor = (self.surfaceLevel == JMSurfaceLevelInset) ? [UIColor colorWithWhite:1. alpha:shadowAlpha] : [UIColor colorWithWhite:0. alpha:shadowAlpha];    
    
//    // Alter for highlight states
//    shadowOffset = self.highlighted ? (-1. * shadowOffset) : shadowOffset;
//    if (self.surfaceLevel == JMSurfaceLevelOffset)
//    {
//        imageRect = self.highlighted ? CGRectOffset(imageRect, 0, -1 * shadowOffset) : imageRect;
//    }

//    CGFloat shadowAlpha = 0.8;
//    CGFloat shadowBlur = 0.1;
//    CGFloat shadowOffset = 1.;
//    CGFloat imageOpacity = 1.;
//
//    UIColor *insetColor = (self.surfaceLevel == JMSurfaceLevelInset) ? [UIColor colorWithWhite:0. alpha:shadowAlpha] : [UIColor colorWithWhite:1. alpha:shadowAlpha];
//    UIColor *shadowColor = (self.surfaceLevel == JMSurfaceLevelInset) ? [UIColor colorWithWhite:1. alpha:shadowAlpha] : [UIColor colorWithWhite:0. alpha:shadowAlpha];
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    
//    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, -1.0 * shadowOffset), shadowBlur, [insetColor CGColor]);
//    
//    [self.image drawAtPoint:imageRect.origin blendMode:kCGBlendModeNormal alpha:imageOpacity];
//    
//    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0 * shadowOffset), shadowBlur, [shadowColor CGColor]);
//
//    [self.image drawAtPoint:imageRect.origin blendMode:kCGBlendModeNormal alpha:imageOpacity];
//    
//    CGContextRestoreGState(context);    
}

@end

//+ (void) startShadowedDrawWithShadowColor:(UIColor *)shadowColor;
//{
//    if (LEGACY) return;
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 1.f, [shadowColor CGColor]);    
//}
//
//+ (void) startShadowedDrawWithOpacity:(CGFloat)opacity;
//{
//    [UIView startShadowedDrawWithShadowColor:[UIColor colorWithWhite:0. alpha:opacity]];
//}
//
//+ (void) startShadowedDraw;
//{
//    [UIView startShadowedDrawWithOpacity:0.5];
//}
//
//+ (void) endShadowedDraw;
//{
//    if (LEGACY) return;
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextRestoreGState(context);    
//}
