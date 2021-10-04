#import "UIImage+ABDiskCache.h"
#import "JMDiskCache.h"
#import "ThumbManager+HitProtection.h"

@implementation UIImage (ABDiskCache)

+ (NSString *)cacheKeyForUrl:(NSString *)url;
{
    NSURL *nUrl = [NSURL URLWithString:url];
    NSString *cacheKey = [[nUrl absoluteString] stringByAppendingFormat:@"#%@", nil];
    return cacheKey;
}

+ (UIImage *)ab_diskCachedImageForKey:(NSString *)cacheKey permanentStorage:(BOOL)isPermanentStorage;
{
    return [[JMDiskCache shared] cachedImageForUrlKey:cacheKey permanent:isPermanentStorage];
}

+ (void)ab_setDiskCachedImage:(UIImage *)image forKey:(NSString *)cacheKey permanentStorage:(BOOL)isPermanentStorage;
{
    [[ThumbManager manager] hitProtectionRequestCompletedForKey:cacheKey];
    
    if (image)
    {
        [[JMDiskCache shared] cacheImage:image forUrlKey:cacheKey writeToDisk:YES permanent:isPermanentStorage];
    }
}

+ (void)ab_removeDiskCachedImageForKey:(NSString *)cacheKey permanentStorage:(BOOL)isPermanentStorage;
{
    [[JMDiskCache shared] removeCachedImageForKey:cacheKey permanent:isPermanentStorage];
}

+ (UIImage *)ab_diskCachedImageForKey:(NSString *)cacheKey;
{
    return [[self class] ab_diskCachedImageForKey:cacheKey permanentStorage:NO];
}

+ (void)ab_setDiskCachedImage:(UIImage *)image forKey:(NSString *)cacheKey;
{
    [[self class] ab_setDiskCachedImage:image forKey:cacheKey permanentStorage:NO];
}

+ (void)ab_removeDiskCachedImageForKey:(NSString *)cacheKey
{
    [[self class] ab_removeDiskCachedImageForKey:cacheKey permanentStorage:NO];
}

- (void)log;
{
//    LogImageData(nil, 1, self.width, self.height, UIImagePNGRepresentation(self));
}


@end
