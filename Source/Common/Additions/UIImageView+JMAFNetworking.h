//
//  UIImageView+UIImageView_JMAFNetworking.h
//  AlienBlue
//
//  Created by J M on 26/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>


#ifndef AlienBlue_AFImageCacheAccess
#define AlienBlue_AFImageCacheAccess
@interface AFImageCache : NSCache
@end
#endif

@interface AFImageCache (JMAFNetworking)
+ (AFImageCache *)sharedImageCache;
@end

@interface UIImageView (AFImageCache)
+ (AFImageCache *)afImageCache;
@end
