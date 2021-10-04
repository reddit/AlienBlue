
// Created to expose AFImageCache
#import "UIImageView+JMAFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface UIImageView (_JMAFNetworking)
+ (AFImageCache *)af_sharedImageCache;
@end

@implementation AFImageCache (JMAFNetworking)
+ (AFImageCache *)sharedImageCache;
{
    return [UIImageView afImageCache];
}
@end


@implementation UIImageView (JMAFNetworking)


+ (AFImageCache *)afImageCache;
{
    return [UIImageView af_sharedImageCache];
}

@end
