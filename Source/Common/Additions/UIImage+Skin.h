#import <Foundation/Foundation.h>

@interface UIImage (Skin)

+ (UIImage *)skinImageNamed:(NSString *)imageName;
+ (UIImage *)skinImageNamed:(NSString *)imageName withColor:(UIColor *)color;
+ (UIImage *)etchedSkinImageNamed:(NSString *)imageName withColor:(UIColor *)color inset:(BOOL)inset;
+ (UIImage *)placeholderThumbImageForUrl:(NSString *)url;
+ (UIImage *)imageForRoundedInsetForSize:(CGSize)size;
+ (UIImage *)imageForRoundedInset;

+ (UIImage *)thumbnailShadowImage;
+ (UIImage *)thumbnailShadowImageFittingSize:(CGSize)size;

+ (UIImage *)skinIcon:(NSString *)iconName withColor:(UIColor *)color;
+ (UIImage *)skinIcon:(NSString *)iconName;
+ (UIImage *)skinEtchedIcon:(NSString *)iconName withColor:(UIColor *)color;
+ (UIImage *)skinEtchedIcon:(NSString *)iconName shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset fillColor:(UIColor *)fillColor scale:(CGFloat)scale;

@end
