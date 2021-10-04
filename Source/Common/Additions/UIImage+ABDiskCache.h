#import <UIKit/UIKit.h>

@interface UIImage (ABDiskCache)

+ (UIImage *)ab_diskCachedImageForKey:(NSString *)url;
+ (void)ab_removeDiskCachedImageForKey:(NSString *)url;
+ (void)ab_setDiskCachedImage:(UIImage *)image forKey:(NSString *)url;

+ (UIImage *)ab_diskCachedImageForKey:(NSString *)cacheKey permanentStorage:(BOOL)isPermanentStorage;
+ (void)ab_setDiskCachedImage:(UIImage *)image forKey:(NSString *)cacheKey permanentStorage:(BOOL)isPermanentStorage;
+ (void)ab_removeDiskCachedImageForKey:(NSString *)cacheKey permanentStorage:(BOOL)isPermanentStorage;

- (void)log;
@end
