#import "UIImage+ABAdditions.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIImage (ABAdditions)

+ (UIImage *)etchedImageFromImage:(UIImage *)image shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset fillColor:(UIColor *)fillColor;
{
  CGFloat scale = [[UIScreen mainScreen] scale];
  
  //  CGSize nSize = CGSizeMake(image.size.width + 2, image.size.height + 2);
  
  UIGraphicsBeginImageContextWithOptions(image.size, NO, scale);
  CGContextRef c = UIGraphicsGetCurrentContext();
  
  CGImageRef maskImage = image.CGImage;
  CGRect maskRect = CGRectMake(0., 0., image.size.width, image.size.height);
  
  // draw image and white drop shadow
  CGContextSetShadowWithColor(c, shadowOffset, 0., shadowColor.CGColor);
  [image drawInRect:CGRectOffset(maskRect, 0., 0.)];
  
  CGContextTranslateCTM(c, 0, image.size.height);
  CGContextScaleCTM(c, 1.0, -1.0);
  
  //Clip drawing to mask:
  CGContextClipToMask(c, maskRect, maskImage);
  
  // Fill in the image with colour
  [fillColor set];
  CGContextFillRect(c, maskRect);
  
  UIImage *etchedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return etchedImage;
}


+ (UIImage *)etchedImageFromImage:(UIImage *)image fillColor:(UIColor *)fillColor;
{
  CGFloat scale = [[UIScreen mainScreen] scale];
  
  //  CGSize nSize = CGSizeMake(image.size.width + 2, image.size.height + 2);
  
  UIGraphicsBeginImageContextWithOptions(image.size, NO, scale);
  CGContextRef c = UIGraphicsGetCurrentContext();
  
  CGImageRef maskImage = image.CGImage;
  CGRect maskRect = CGRectMake(0., 0., image.size.width, image.size.height);
  
  UIColor *shadowColor = [UIColor colorForInsetDropShadow];
  // draw image and white drop shadow
  CGContextSetShadowWithColor(c, CGSizeMake(0, 1.), 0., shadowColor.CGColor);
  [image drawInRect:CGRectOffset(maskRect, 0., 0.)];
  
  CGContextTranslateCTM(c, 0, image.size.height);
  CGContextScaleCTM(c, 1.0, -1.0);
  
  
  //Clip drawing to mask:
  CGContextClipToMask(c, maskRect, maskImage);
  
  // Fill in the image with colour
  [fillColor set];
  CGContextFillRect(c, maskRect);

  UIImage *etchedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return etchedImage;
}

- (UIImage *)jm_resizeable;
{
  CGFloat hInset = floorf(self.size.width / 2.);
  CGFloat vInset = floorf(self.size.height / 2.);
  if ([self respondsToSelector:@selector(jm_resizableImageWithCapInsets:resizingMode:)])
  {
    return [self jm_resizableImageWithCapInsets:UIEdgeInsetsMake(vInset, hInset, vInset, hInset) resizingMode:UIImageResizingModeTile];
  }
  else
  {
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(vInset, hInset, vInset, hInset)];
  }
}

- (UIImage *)jm_resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode;
{
  if ([self respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
    return [self resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
  else
    return [self resizableImageWithCapInsets:capInsets];
}

@end
