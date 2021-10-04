#import "UIImage+Skin.h"
#import "ABBundleManager.h"
#import "Resources.h"
#import "CommentLink.h"

@implementation UIImage (Skin)

+(UIImage *) skinImageNamed:(NSString *)imageName;
{
    UIImage *skinImage = [[ABBundleManager sharedManager] imageNamed:imageName];
    return skinImage;
}

+ (UIImage *) skinImageNamed:(NSString *)imageName withColor:(UIColor *)color;
{
    NSString *imageKey = [NSString stringWithFormat:@"%@-%f-%f",imageName, CGColorGetComponents(color.CGColor)[0], CGColorGetComponents(color.CGColor)[1]];
    UIImage *cached = [UIImage jm_cachedImageForKey:imageKey];
    if (cached)
    {
        return cached;
    }

    // load the image
    UIImage *img = [UIImage skinImageNamed:imageName];
    
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    //CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  
    [UIImage jm_cacheImage:coloredImg key:imageKey];
    
    //return the color-burned image
    return coloredImg;    
}

+ (UIImage *)etchedSkinImageNamed:(NSString *)imageName withColor:(UIColor *)color inset:(BOOL)inset;
{
    NSString *imageKey = [NSString stringWithFormat:@"%@-%f-%@",imageName, CGColorGetComponents(color.CGColor)[0], @"etched"];
    UIImage *cached = [UIImage jm_cachedImageForKey:imageKey];
    if (cached)
    {
        return cached;
    }    
    
    CGFloat shadowBlur = 0.;
    CGFloat shadowOffset = 1.;
    
    UIColor *insetColor = (inset) ? [UIColor colorForInsetInnerShadow] : [UIColor colorForInsetDropShadow];
    UIColor *shadowColor = (inset) ? [UIColor colorForInsetDropShadow] : [UIColor colorForInsetInnerShadow];

    
    UIImage *img = [UIImage skinImageNamed:imageName withColor:color];
    
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, -1.0 * shadowOffset), shadowBlur, [insetColor CGColor]);
    UIGraphicsPushContext(context);
    [img drawAtPoint:CGPointZero];
    UIGraphicsPopContext();
    
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0 * shadowOffset), shadowBlur, [shadowColor CGColor]);
    
    UIGraphicsPushContext(context);
    [img drawAtPoint:CGPointZero];
    UIGraphicsPopContext();
        
    UIImage *etchedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  
    [UIImage jm_cacheImage:etchedImage key:imageKey];
    
    //return the color-burned image
    return etchedImage;  
}

+ (UIImage *)placeholderThumbImageForUrl:(NSString *)url;
{
//    NSString *img = nil;
    LinkType linkType = [CommentLink linkTypeFromUrl:url];
  
    NSString *iconName = nil;
    
    if ([url contains:@".gif"])
      iconName = @"gif-icon";
    else if ([url jm_contains:@"imgur.com"] && ([url jm_contains:@"/a/"] || [url jm_contains:@"gallery"]))
      iconName = @"album-icon";
    else if (linkType == LinkTypePhoto)
      iconName = @"photo-icon";
    else if (linkType == LinkTypeVideo)
      iconName = @"video-icon";
    else
      iconName = @"browser-icon";

  UIColor *placeholderColor = JMIsNight() ? [UIColor colorWithWhite:0.2 alpha:1.] : [UIColor colorWithWhite:0.7 alpha:1.];
  UIImage *placeholderImage = [UIImage skinIcon:iconName withColor:placeholderColor];
  return placeholderImage;

  
//    if (linkType == LinkTypePhoto)
//        img = @"photo";
//    else if (linkType == LinkTypeVideo)
//        img = @"video";
//    else
//        img = @"article";
//  
//    img = [NSString stringWithFormat:@"icons/link-icons/%@", img];
//    
//    UIImage *placeholderImage = [UIImage skinImageNamed:img withColor:[UIColor colorForHighlightedText]];
    return placeholderImage;
}

//+ (UIImage *)thumbnailShadowImageFittingSize:(CGSize)size;
//{
//    if (size.width == 50)
//        return [UIImage skinImageNamed:@"section/post-list/thumbnail-frame.png"];
//    else if (size.width == 60)
//        return [UIImage skinImageNamed:@"section/post-list/thumbnail-frame-60.png"];
//    else
//        return [UIImage skinImageNamed:@"section/post-list/thumbnail-frame-small.png"];    
//}

+ (UIImage *)thumbnailShadowImageFittingSize:(CGSize)size;
{
  CGSize shadowSize = CGSizeMake(size.width, size.height);
  NSString *cacheKey = [NSString stringWithFormat:@"thumb-overlay-%@-%d", NSStringFromCGSize(size), [Resources isNight]];
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGRect shadowRect = CGRectInset(bounds, -2., -2.);
    shadowRect.origin.x = -2.;

    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:CGRectOffset(bounds, 0, 0) cornerRadius:3.];
    UIColor *innerBorderColor = JMIsNight() ? [UIColor colorWithWhite:0.1 alpha:1.] : [UIColor colorWithWhite:0.6 alpha:1.];
    [innerBorderColor set];
    CGFloat lineWidth = JMIsNight() ? 1. : 0.5;
    [clipPath setLineWidth:lineWidth];
    [clipPath stroke];
    [clipPath addClip];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:shadowRect cornerRadius:4.];
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeZero, 2., [UIColor colorWithWhite:0. alpha:0.5].CGColor);
      [[UIColor darkGrayColor] setStroke];
      [shadowPath setLineWidth:4];
      [shadowPath stroke];
  } opaque:NO withSize:shadowSize cacheKey:cacheKey];
}


+ (UIImage *)thumbnailShadowImage;
{
    return [UIImage thumbnailShadowImageFittingSize:[Resources thumbSize]];
//    else
//    {
//        UIImage *shadowImage = [UIImage skinImageNamed:@"section/post-list/thumbnail-frame.png"];
//        return [shadowImage stretchableImageWithLeftCapWidth:25. topCapHeight:25.];
//    }
}

+ (UIImage *)imageForRoundedInsetForSize:(CGSize)size;
{
    NSString *bgColorStr = [Resources isNight] ? @"blck" : @"wht";
    NSString *insetCacheKey = [NSString stringWithFormat:@"5rounded-inset-%@-%@.jpg", NSStringFromCGSize(size), bgColorStr];
//    UIImage *insetRounded = [[ImageCache sharedImageCache] imageForKey:insetCacheKey];
    UIImage *insetRounded = [UIImage ab_diskCachedImageForKey:insetCacheKey];
    
    if (!insetRounded)
    {
//        DLog(@"need to create inset for: %@", insetCacheKey);
        UIImage *stretchableImage = [[UIImage skinImageNamed:@"common/inset-rounded"] resizableImageWithCapInsets:UIEdgeInsetsMake(20., 20., 20., 20.)];
        
        UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIGraphicsPushContext(context);

        [[UIColor colorForBackground] set];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
        
        [stretchableImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIGraphicsPopContext();
        
        insetRounded = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [UIImage ab_setDiskCachedImage:insetRounded forKey:insetCacheKey];
    }
    else {
//        DLog(@"using cached inset for: %@", insetCacheKey);
    }
    return insetRounded;
}

+ (UIImage *)imageForRoundedInset;
{
    return [[UIImage skinImageNamed:@"common/inset-rounded"] resizableImageWithCapInsets:UIEdgeInsetsMake(20., 20., 20., 20.)];
}

+ (UIImage *)skinIcon:(NSString *)iconName withColor:(UIColor *)color;
{
  NSString *imageName = [NSString stringWithFormat:@"generated/%@", iconName];
  return [UIImage skinImageNamed:imageName withColor:color];
}

+ (UIImage *)skinIcon:(NSString *)iconName;
{
  return [UIImage skinIcon:iconName withColor:[UIColor blackColor]];
}

//+ (UIImage *)etchedImageFromImage:(UIImage *)image shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset fillColor:(UIColor *)fillColor;

+ (UIImage *)skinEtchedIcon:(NSString *)iconName withColor:(UIColor *)color;
{
  return [UIImage skinEtchedIcon:iconName shadowColor:[UIColor colorForInsetDropShadow] shadowOffset:CGSizeMake(0., 1.) fillColor:color scale:1.];
}

+ (UIImage *)skinEtchedIcon:(NSString *)iconName shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset fillColor:(UIColor *)fillColor scale:(CGFloat)scale;
{
  NSString *imageKey = [NSString stringWithFormat:@"%@-%d-%f-%f-%@",iconName, [Resources isNight], CGColorGetComponents(fillColor.CGColor)[0], CGColorGetComponents(shadowColor.CGColor)[0], @"etched"];
  UIImage *cached = [UIImage jm_cachedImageForKey:imageKey];
  if (cached)
  {
    return cached;
  }
  
  UIImage *img = [UIImage skinIcon:iconName];
  if (scale != 1.)
  {
    CGSize nSize = CGSizeMake(img.size.width * scale, img.size.height * scale);
    img = [img jm_resizeAndCropToSize:nSize];
  }

  UIImage *etchedImage = [UIImage etchedImageFromImage:img shadowColor:shadowColor shadowOffset:shadowOffset fillColor:fillColor];
  
  [UIImage jm_cacheImage:etchedImage key:imageKey];
  
  return etchedImage;
}


@end
