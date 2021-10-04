#import <UIKit/UIKit.h>

@interface UIImage (ABAdditions)

+ (UIImage *)etchedImageFromImage:(UIImage *)image fillColor:(UIColor *)fillColor;
+ (UIImage *)etchedImageFromImage:(UIImage *)image shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset fillColor:(UIColor *)fillColor;

- (UIImage *)jm_resizeable;
- (UIImage *)jm_resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode;
@end
