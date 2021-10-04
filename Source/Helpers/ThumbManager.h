//
//  ThumbManager.h
//  AlienBlue
//
//  Created by J M on 5/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThumbManager : NSObject

+ (ThumbManager *)manager;

@property (strong) NSMutableArray *localSiteThumbs;
- (UIImage *)thumbnailForUrl:(NSString *)urlStr fallbackUrl:(NSString *)fallbackUrl useFaviconWhenAvailable:(BOOL)useFaviconWhenAvailable onComplete:(void (^)(UIImage *image))onComplete;
- (UIImage *)resizedImageForUrl:(NSString *)urlStr fallbackUrl:(NSString *)fallbackUrl size:(CGSize)size onComplete:(void (^)(UIImage *image))onComplete;

// no fancy stuff, just grab the image and resize
- (UIImage *)imageForUrl:(NSString *)urlStr scaleToFitWidth:(CGFloat)maxWidth onComplete:(void (^)(UIImage *image))onComplete;
- (UIImage *)imageForUrl:(NSString *)urlStr scaleToFitSize:(CGSize)maxSize allowClipping:(BOOL)allowClipping onComplete:(void (^)(UIImage *image))onComplete;

+ (UIImage *)localImageForUrl:(NSString *)urlStr;

- (UIImage *)subredditIconForSubreddit:(NSString *)subreddit ident:(NSString *)ident onComplete:(void (^)(UIImage *image))onComplete;

- (void)forceCreateResizeServerThumbnailForUrl:(NSString *)urlStr onComplete:(void (^)(UIImage *image))onComplete;

@end
