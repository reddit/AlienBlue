#import "UIView+Additions.h"
#import "ABBundleManager.h"
#import "Resources.h"
#import <QuartzCore/QuartzCore.h>

#define kABUIViewBlurOverlayTag 918732623

CGSize SkinShadowOffsetSize()
{
//  CGFloat factor = ([Resources isNight] || [Resources skinTheme] == SkinThemeLion || [Resources skinTheme] == SkinThemeLionAlt) ? 1. : -1.;
  CGFloat factor = 1.;
  return CGSizeMake(0., factor * 1.);
}

@implementation UIView (UIView_Additions)

- (void) drawRectangleWithRect:(CGRect)rect withColor:(UIColor *) color;
{
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);	
}

- (void) drawNoise;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect bounds = self.bounds;
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:bounds];
    
    CGContextAddPath(context, [path CGPath]);
    CGContextClip(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    UIImage * noise = [[ABBundleManager sharedManager] imageNamed:@"backgrounds/noise-tile.png"];
    [noise drawAsPatternInRect:bounds];
    
    CGContextRestoreGState(context);
}

- (void) drawTapGlowAtPoint:(CGPoint) touchPoint
{
	if (CGPointEqualToPoint(touchPoint, CGPointZero))
	{
		return;
	}
    UIImage * tapGlowImage = [[ABBundleManager sharedManager] imageNamed:@"common/tap-glow.png"];
	CGRect rect = CGRectMake(touchPoint.x - 40, touchPoint.y - 40, 80, 80);
	[tapGlowImage drawInRect:rect];
}

- (void) clearSubviews;
{
	for (UIView * subview in self.subviews)
	{
		[subview removeFromSuperview];
	}
}

- (void)drawInnerShadowInRect:(CGRect)rect fillColor:(UIColor *)fillColor;
{
    CGRect bounds = [self bounds];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat outsideOffset = 20.f;
    CGFloat radius = 0.5f * CGRectGetHeight(bounds);
    
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGPathMoveToPoint(visiblePath, NULL, bounds.size.width-radius, bounds.size.height);
    CGPathAddArc(visiblePath, NULL, bounds.size.width-radius, radius, radius, 0.5f*M_PI, 1.5f*M_PI, YES);
    CGPathAddLineToPoint(visiblePath, NULL, radius, 0.f);
    CGPathAddArc(visiblePath, NULL, radius, radius, radius, 1.5f*M_PI, 0.5f*M_PI, YES);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.size.width-radius, bounds.size.height);
    CGPathCloseSubpath(visiblePath);
    
    [fillColor setFill];
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, -outsideOffset, -outsideOffset);
    CGPathAddLineToPoint(path, NULL, bounds.size.width+outsideOffset, -outsideOffset);
    CGPathAddLineToPoint(path, NULL, bounds.size.width+outsideOffset, bounds.size.height+outsideOffset);
    CGPathAddLineToPoint(path, NULL, -outsideOffset, bounds.size.height+outsideOffset);
    
    CGPathAddPath(path, NULL, visiblePath);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, visiblePath); 
    CGContextClip(context);         
    
    UIColor * shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 4.0f), 8.0f, [shadowColor CGColor]);
    [shadowColor setFill];   
    
    CGContextSaveGState(context);   
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGPathRelease(path);    
    CGPathRelease(visiblePath);     
    CGContextRestoreGState(context);
}

+ (void) startShadowedDrawWithShadowColor:(UIColor *)shadowColor;
{
    FAST_DEVICE_ONLY;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 1.f, [shadowColor CGColor]);    
}

+ (void) startShadowedDrawWithOpacity:(CGFloat)opacity;
{
    FAST_DEVICE_ONLY;
    
    [UIView startShadowedDrawWithShadowColor:[UIColor colorWithWhite:0. alpha:opacity]];
}

+ (void) startShadowedDraw;
{
    FAST_DEVICE_ONLY;
    
    [UIView startShadowedDrawWithOpacity:0.5];
}

+ (void) endShadowedDraw;
{
    FAST_DEVICE_ONLY;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRestoreGState(context);    
}


+ (void)startEtchedDraw;
{
    FAST_DEVICE_ONLY;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 0.f, [[UIColor colorForInsetDropShadow] CGColor]);
}

+ (void)endEtchedDraw;
{
    FAST_DEVICE_ONLY;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRestoreGState(context);    
}


+ (void)startEtchedInnerShadowDraw;
{
    FAST_DEVICE_ONLY;

    [UIView startEtchedInnerShadowDrawWithColor:[UIColor colorForInsetInnerShadow]];
}

+ (void)endEtchedInnerShadowDraw;
{
    FAST_DEVICE_ONLY;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRestoreGState(context);    
}

+ (void)startEtchedDropShadowDraw;
{
    FAST_DEVICE_ONLY;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 0.f, [[UIColor colorForInsetDropShadow] CGColor]);
}

+ (void)endEtchedDropShadowDraw;
{
    FAST_DEVICE_ONLY;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRestoreGState(context);    
}


+ (void)startEtchedInnerShadowDrawWithColor:(UIColor *)color;
{
    FAST_DEVICE_ONLY;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, -1.0f), 0.25f, [color CGColor]);
}

+ (void)addRoundedRectToPathForContext:(CGContextRef)context rect:(CGRect)rect ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
{
	float fw, fh;
	if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
	}
	CGContextSaveGState(context);
	CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM (context, ovalWidth, ovalHeight);
	fw = CGRectGetWidth (rect) / ovalWidth;
	fh = CGRectGetHeight (rect) / ovalHeight;
	CGContextMoveToPoint(context, fw, fh/2);
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

+ (void)drawGradientInRect:(CGRect)rect minHeight:(CGFloat)minHeight startColor:(UIColor *)startColor endColor:(UIColor *)endColor;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

////    size_t num_locations = 4;
////    CGFloat locations[4] = { 0.0, 0.7, 0.98, 1.0};
////	
////    CGFloat nightModeComponents[16] = {
////		1.0, 1.0, 1.0, 0.35,
////		1.0, 1.0, 1.0, 0.06, 
////		1.0, 1.0, 1.0, 0.06,
////		1.0, 1.0, 1.0, 0.45,
////	};
////	
////    CGFloat dayModeComponents[16] = {
////		0.69, 0.737, 0.803, 1.,
////		0.427, 0.5176, 0.6353, 1., 
////		0.427, 0.5176, 0.6353, 1.,
////		1.0, 1.0, 1.0, 0.35
////	};
////	
//
////    rgbColorspace = CGColorSpaceCreateDeviceRGB();
////    
////	glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, nightModeComponents, locations, num_locations);	
////	
////    CGRect currentBounds = self.bounds;
////    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
////    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), currentBounds.size.height);
////    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
////	
////    CGGradientRelease(glossGradient);
////    CGColorSpaceRelease(rgbColorspace); 	

    if (rect.size.height < minHeight)
    {
        CGFloat drawScale = minHeight / rect.size.height;
        CGContextScaleCTM(context, 1., drawScale);
    }
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = { 0. , 1. };
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
    CGContextDrawLinearGradient(context, gradient, rect.origin, CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
    CGContextRestoreGState(context);
}

+ (void)drawGradientBackgroundInRect:(CGRect)rect;
{
    UIColor *startColor = [Resources isNight] ? [UIColor colorWithHex:0x222322] : [UIColor colorWithHex:0xf2f2f2];
    UIColor *endColor = [Resources isNight] ? [UIColor colorWithHex:0x2d2d2d] : [UIColor colorWithHex:0xe9e9e9];
    
    [UIView drawGradientInRect:rect minHeight:200. startColor:startColor endColor:endColor];
}

+ (void)drawVerticalText:(NSString *)value context:(CGContextRef)context point:(CGPoint)point font:(UIFont *)font;
{
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);

    CGAffineTransform textTransform = CGAffineTransformMakeRotation(-1.57);
    CGContextConcatCTM(context, textTransform);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    [value drawAtPoint:point withFont:font];
    CGContextRestoreGState(context);
}

- (UIColor *)colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

- (UIView *)findFirstResponder;
{
    if (self.isFirstResponder)
        return self;

    for (UIView *v in self.subviews)
    {
        if ([v isFirstResponder])
            return v;

        if ([v findFirstResponder])
            return [v findFirstResponder];
    }
    return nil;
}

- (UIImage *)imageRepresentation;
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

- (UIImageView *)imageViewRepresentation;
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageRepresentation]];
    return imageView;
}

- (NSArray *)subviewsMatchingValidation:(BOOL(^)(UIView *view))validation;
{
  NSMutableArray *matching = [NSMutableArray array];
  [matching addObjectsFromArray:[self.subviews select:validation]];
  
  [self.subviews each:^(UIView *subview) {
    [matching addObjectsFromArray:[subview subviewsMatchingValidation:validation]];
  }];
  return matching;
}

- (NSArray *)subviewsOfClass:(Class)klass;
{
  return [self subviewsMatchingValidation:^BOOL(UIView *view) {
    return [view isKindOfClass:klass];
  }];
}

- (UIView *)firstSubviewOfClass:(Class)klass;
{
  NSArray *matchingSubviews = [self subviewsOfClass:klass];
  
  if (!matchingSubviews || matchingSubviews.count == 0)
    return nil;
  
  return [matchingSubviews objectAtIndex:0];
}

+ (void)jm_animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(void))completion animated:(BOOL)animated;
{
  if (!animated)
  {
    if (animations) animations();
    if (completion) completion();
    return;
  }

  [UIView animateWithDuration:duration animations:^{
    if (animations) animations();
  } completion:^(BOOL finished) {
    if (completion) completion();
  }];
}

+ (void)jm_animateFast:(void (^)(void))animations completion:(void (^)(void))completion animated:(BOOL)animated;
{
  [UIView jm_animateWithDuration:0.2 animations:animations completion:completion animated:animated];
}

+ (void)jm_animateSlow:(void (^)(void))animations completion:(void (^)(void))completion animated:(BOOL)animated;
{
  [UIView jm_animateWithDuration:0.45 animations:animations completion:completion animated:animated];
}



@end
