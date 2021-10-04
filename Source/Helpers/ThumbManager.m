//
//  ThumbManager.m
//  AlienBlue
//
//  Created by J M on 5/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "ThumbManager.h"
#import "NSString+Base64.h"
#import "NSData+md5.h"
#import "NSString+ABAdditions.h"
#import "AFNetworking.h"
#import "Resources.h"
#import "UIImage+ABDiskCache.h"
#import "UIImage+Resize.h"
#import "ThumbManager+HitProtection.h"
#import "NSTimer+BlocksKit.h"
#import "JMSiteMedia.h"
#import "NSString+ABLegacyLinkTypes.h"

#define kThumbnailDownloadSizeThresholdBytes 20000

#define kSubredditIconThumbBase @"http://alienblue-static.s3.amazonaws.com/subreddit-icons/"

// these features are no longer needed - as high-res thumbs are now provided by
// reddit natively
#define kThumbHostBase @""
#define kS3HostBase @""
#define kS3Folder @""
#define kThumbHostBaseForced @""


@interface ThumbManager()
@end

@implementation ThumbManager

+ (ThumbManager *)manager;
{
    JM_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (id)init
{
    if ((self = [super init]))
    {
        [self initialiseHitProtection];
        
        self.localSiteThumbs = [NSMutableArray array];
        [self.localSiteThumbs addObject:@"apple.com"];
        [self.localSiteThumbs addObject:@"facebook.com"];
        [self.localSiteThumbs addObject:@"google.com"];
        [self.localSiteThumbs addObject:@"imdb.com"];
        [self.localSiteThumbs addObject:@"reddit.com"];
        [self.localSiteThumbs addObject:@"twitter.com"];
        [self.localSiteThumbs addObject:@"wikipedia.org"];
    }
    return self;
}

+ (NSString *)uriHash:(NSString *)uri
{
    NSString *uriHash = [NSString base64FromString:uri];
    return uriHash;
}

+ (NSString *)requestToken:(NSString *)uri
{
    NSString *uriK = [NSString stringWithFormat:@"ab_%@",uri];
    NSString *vToken = [[uriK dataUsingEncoding:NSUTF8StringEncoding] md5];
    return vToken;
}

+ (NSString *)ab_thumbProcessLinkForUrl:(NSString *)urlStr withSize:(NSString *)size;
{
    NSString *uriHash = [ThumbManager uriHash:urlStr];
    NSString *vToken = [ThumbManager requestToken:urlStr];
    NSString *processUrl = [NSString stringWithFormat:@"%@/%@/%@/%@", kThumbHostBase, uriHash, vToken, size];
    return  processUrl;
}

+ (NSString *)ab_forcedThumbProcessLinkForUrl:(NSString *)urlStr withSize:(NSString *)size;
{
    NSString *uriHash = [ThumbManager uriHash:urlStr];
    NSString *vToken = [ThumbManager requestToken:urlStr];
    NSString *processUrl = [NSString stringWithFormat:@"%@/%@/%@/%@", kThumbHostBaseForced, uriHash, vToken, size];
    return  processUrl;    
}

+ (NSString *)ab_s3LinkForUrl:(NSString *)urlStr withSize:(NSString *)size;
{
    NSString *s3Folder = kS3Folder;
    
    NSString *uriHash = [ThumbManager uriHash:urlStr];
    NSString *vToken = [ThumbManager requestToken:urlStr];
    NSString *complete = [NSString stringWithFormat:@"%@%@", uriHash, vToken];
    NSString *fnHash = [[complete dataUsingEncoding:NSUTF8StringEncoding] md5];
    
    NSString *s3Path = [NSString stringWithFormat:@"%@/%@/%@_%@.jpg", kS3HostBase, s3Folder, fnHash, size];
    return s3Path;
}

+ (NSMutableURLRequest *)ab_requestForUrl:(NSString *)urlStr useCache:(BOOL)useCache
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";
    NSURLRequestCachePolicy cachePolicy =  useCache ? NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringLocalCacheData;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:30.0];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];

    return request;
}

#define SAFE_IMAGE_COMPLETE(IMAGE) if(onComplete && IMAGE) onComplete(IMAGE);

- (UIImage *)resizeServerThumbnailForUrl:(NSString *)urlStr fallbackUrl:(NSString *)fallbackUrl onComplete:(void (^)(UIImage *image))onComplete;
{
    if (![Resources isPro])
      return nil;
  
    if ([urlStr contains:@"reddit.com/"])
    {
        SAFE_IMAGE_COMPLETE(nil);
        return nil;
    }
    
    NSString *size = @"thumb";
    if ([Resources isIPAD] && JMIsRetina())
    {
        size = [size stringByAppendingString:@"120"];
    }
    else
    {
        size = [size stringByAppendingString:@"2x"];
    }
//    if ([Resources retina])
//    {

//    }
        
    NSString *s3urlLink = [ThumbManager ab_s3LinkForUrl:urlStr withSize:size];
    
    UIImage *cachedImage = [UIImage ab_diskCachedImageForKey:s3urlLink];
    if (cachedImage)
    {        
        SAFE_IMAGE_COMPLETE(cachedImage);
        return cachedImage;
    }
    
    if (![self hitProtectionAllowRequestForKey:s3urlLink])
    {
        SAFE_IMAGE_COMPLETE(nil);
        return nil;
    }
    [self hitProtectionRequestBeganForKey:s3urlLink];
    
    NSMutableURLRequest *s3Request = [ThumbManager ab_requestForUrl:s3urlLink useCache:YES];

    typedef void (^FallbackAction)(NSString *fallbackUrl, NSString *cacheKey, UIImage *image);
    FallbackAction fallbackAction = ^(NSString *fallbackUrl, NSString *cacheKey, UIImage *image){
        if (fallbackUrl && (!image || CGSizeEqualToSize(image.size, CGSizeZero)))
        {
            NSURLRequest *fallbackRequest = [ThumbManager ab_requestForUrl:fallbackUrl useCache:YES];

            AFImageRequestOperation *fallbackImageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:fallbackRequest imageProcessingBlock:^UIImage *(UIImage *fImage) {
                return [fImage resizeAndCropToSize:[Resources thumbSize]];
            } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *fallbackImage) {
                // set the fallback image as the cached version of the original url
                // so that subsequent requests can be handled immediately.
                [UIImage ab_setDiskCachedImage:fallbackImage forKey:cacheKey];
                SAFE_IMAGE_COMPLETE(fallbackImage);
            } failure:nil];            
            [fallbackImageOperation start];
        }
    };
    
    AFImageRequestOperation *s3RequestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:s3Request imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if ([response statusCode] == 403)
        {
//            NSLog(@"hitting the resize server.");
            [UIImage ab_removeDiskCachedImageForKey:s3urlLink];
            NSString *processUrlLink = [ThumbManager ab_thumbProcessLinkForUrl:urlStr withSize:size];
            NSMutableURLRequest *resizeRequest = [ThumbManager ab_requestForUrl:processUrlLink useCache:NO];
            AFImageRequestOperation *resizeRequestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:resizeRequest imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *thumbImg) {
                                                                    if (thumbImg && !CGSizeEqualToSize(thumbImg.size, CGSizeZero))
                                                                    {
                                                                        // all good
                                                                        [UIImage ab_setDiskCachedImage:thumbImg forKey:s3urlLink];
                                                                        SAFE_IMAGE_COMPLETE(thumbImg);
                                                                    }
                                                                    fallbackAction(fallbackUrl, s3urlLink, thumbImg);
                                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                   fallbackAction(fallbackUrl, s3urlLink, nil);
                                                               }];
            [resizeRequestOperation start];            
        }
        else
        {
            if (image && !CGSizeEqualToSize(image.size, CGSizeZero))
            {
                [UIImage ab_setDiskCachedImage:image forKey:s3urlLink];
                SAFE_IMAGE_COMPLETE(image);
            }
           fallbackAction(fallbackUrl, s3urlLink, image);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
       fallbackAction(fallbackUrl, s3urlLink, nil);
    }];
    
    [s3RequestOperation start];
    return nil;    
}

- (UIImage *)quickMemeThumbnailForUrl:(NSString *)qkUrl fallbackUrl:(NSString *)fallbackUrl onComplete:(void (^)(UIImage *image))onComplete;
{
    NSURL *qkURL = [NSURL URLWithString:qkUrl];
    NSString *imgId = [qkURL lastPathComponent];
    NSString *thumbUrl = [NSString stringWithFormat:@"http://t.qkme.me/%@.jpg", imgId];
    return [self resizedImageForUrl:thumbUrl fallbackUrl:fallbackUrl size:[Resources thumbSize] onComplete:onComplete];
}

- (UIImage *)imgurThumbnailForUrl:(NSString *)imgurUrl fallbackUrl:(NSString *)fallbackUrl onComplete:(void (^)(UIImage *image))onComplete;
{
    NSString *thumbUrl = nil;
    NSString *imgUrl = imgurUrl;
    NSString *secondaryUrl = fallbackUrl;
    
    BOOL isGif = [imgurUrl contains:@".gif"];
    if (isGif)
    {
        imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@".gif" withString:@".jpg"];
    }
    
    if (!isGif && [Resources thumbSize].width >= 60. && JMIsRetina())
    {
        thumbUrl = [NSString ab_useMediumThumbnailImgurVersion:imgUrl];
        secondaryUrl = [NSString ab_useTinyResImgurVersion:imgUrl];
    }
    else
    {
        thumbUrl = [NSString ab_useTinyResImgurVersion:imgUrl];
    }
        
    return [self resizedImageForUrl:thumbUrl fallbackUrl:secondaryUrl size:[Resources thumbSize] onComplete:onComplete];
}

+ (UIImage *)localImageForUrl:(NSString *)urlStr;
{
    NSString *domain = [urlStr domainFromUrl];

    if (!domain || [domain isEmpty])
        domain = @"reddit.com";

    if ([urlStr equalsString:@"default"])
      domain = @"reddit.com";
  
    if ([[[ThumbManager manager] localSiteThumbs] containsObject:domain])
    {
        NSUInteger width = [Resources thumbSize].width;
        if (width == 40.)
        {
          width = 50.;
        }
        return [UIImage skinImageNamed:[NSString stringWithFormat:@"site-thumbs/%d/%@.png", width, domain]];
    }
    else
    {
        return nil;
    }
}

- (UIImage *)thumbnailForUrl:(NSString *)urlStr fallbackUrl:(NSString *)fallbackUrl useFaviconWhenAvailable:(BOOL)useFaviconWhenAvailable onComplete:(void (^)(UIImage *image))onComplete;
{
    if (![Resources showRetinaThumbnails])
    {
      return [self resizedImageForUrl:fallbackUrl size:[Resources thumbSize] onComplete:onComplete];
    }

    // check skin bundle to see if a local thumb already exists
    UIImage *siteThumbnail = [ThumbManager localImageForUrl:urlStr];
    if (siteThumbnail)
    {
        return siteThumbnail;
    }
      
    if ([urlStr contains:@"imgur.com"] && ![urlStr contains:@"/a/"])
    {
        return [self imgurThumbnailForUrl:urlStr fallbackUrl:fallbackUrl onComplete:onComplete];
    }
    else if (![urlStr contains:@".jpg"] && ([urlStr contains:@"qkme.me"] || [urlStr contains:@"quickmeme.com"]))
    {
        return [self quickMemeThumbnailForUrl:urlStr fallbackUrl:fallbackUrl onComplete:onComplete];
    }
 
    if ([JMSiteMedia hasThumbnailForURL:urlStr.URL])
    {
      BSELF(ThumbManager);
      NSString *cacheKey = [NSString stringWithFormat:@"JMSiteMedia-%@-%0.f",urlStr,floorf([Resources thumbSize].width)];
      UIImage *cachedImage = [UIImage ab_diskCachedImageForKey:cacheKey];
      if (!cachedImage)
      {
        void(^onSuccessfulThumbnailFetch)(UIImage *thumbImage) = ^(UIImage *thumbImage)
        {
          [UIImage ab_setDiskCachedImage:thumbImage forKey:cacheKey];
          if (onComplete && thumbImage) onComplete(thumbImage);
        };
        
        [JMSiteMedia thumbnailURLForLinkURL:urlStr.URL onComplete:^(NSURL *thumbURL) {
          [blockSelf resizedImageForUrl:thumbURL.absoluteString fallbackUrl:nil size:[Resources thumbSize] onComplete:^(UIImage *image) {
            if (image)
            {
              onSuccessfulThumbnailFetch(image);
            }
          } onFailure:^{
            NSString *secondPassUrl = [(thumbURL.absoluteString) jm_contains:@"hqdefault"] ? [thumbURL.absoluteString jm_replace:@"hqdefault" withString:@"default"] : fallbackUrl;
            [blockSelf resizedImageForUrl:secondPassUrl size:[Resources thumbSize] onComplete:onSuccessfulThumbnailFetch];
          }];
        } onFailure:nil];
      }
      return cachedImage;
    }
  
//    if (![Resources isPro])
//    {
      if (useFaviconWhenAvailable)
      {
        return [self retrieveAppleTouchSiteIconForUrl:urlStr fallbackUrl:fallbackUrl onComplete:onComplete];
      }
      else
      {
        return [self resizedImageForUrl:fallbackUrl size:[Resources thumbSize] onComplete:onComplete];
      }
//    }
//  
//    return [self resizeServerThumbnailForUrl:urlStr fallbackUrl:fallbackUrl onComplete:onComplete];
}

- (UIImage *)retrieveAppleTouchSiteIconForUrl:(NSString *)urlStr fallbackUrl:(NSString *)fallbackUrl onComplete:(void (^)(UIImage *image))onComplete;
{
  NSString *baseUrl = [[NSURL URLWithString:urlStr] jm_baseURL].absoluteString;
  NSString *cachedKey = [NSString stringWithFormat:@"%@-%0.f",baseUrl,floorf([Resources thumbSize].width)];
  UIImage *cachedImage = [UIImage ab_diskCachedImageForKey:cachedKey];
  if (cachedImage)
  {
    SAFE_IMAGE_COMPLETE(cachedImage);
    return cachedImage;
  }
  
  NSString *touchIconNameFirstPassUrl = [NSString stringWithFormat:@"%@/apple-touch-icon.png", baseUrl];
  NSString *touchIconNameSecondPassUrl = [NSString stringWithFormat:@"%@/apple-touch-icon-precomposed.png", baseUrl];
  
  void(^onTouchIconRetrieveSuccess)(UIImage *touchIcon) = ^(UIImage *touchIcon){
    if (touchIcon)
    {
      [UIImage ab_setDiskCachedImage:touchIcon forKey:cachedKey];
      SAFE_IMAGE_COMPLETE(touchIcon);
    }
  };
  
  [self resizedImageForUrl:touchIconNameFirstPassUrl fallbackUrl:touchIconNameSecondPassUrl size:[Resources thumbSize] onComplete:^(UIImage *image) {
    if (!image)
    {
      [self resizedImageForUrl:fallbackUrl size:[Resources thumbSize] onComplete:^(UIImage *fallbackImage) {
        onTouchIconRetrieveSuccess(fallbackImage);
      }];
    }
    else
    {
      onTouchIconRetrieveSuccess(image);
    }
  }];
  return nil;
}

- (UIImage *)resizedImageForUrl:(NSString *)urlStr size:(CGSize)size onComplete:(void (^)(UIImage *image))onComplete;
{
    return [self resizedImageForUrl:urlStr fallbackUrl:nil size:size onComplete:onComplete];
}

- (UIImage *)imageForUrl:(NSString *)urlStr scaleToFitWidth:(CGFloat)maxWidth onComplete:(void (^)(UIImage *image))onComplete;
{
    NSString *cachedKey = [NSString stringWithFormat:@"%@-%0.f",urlStr,floorf(maxWidth)];
    
    UIImage *cachedImage = [UIImage ab_diskCachedImageForKey:cachedKey];
    if (cachedImage)
    {        
        SAFE_IMAGE_COMPLETE(cachedImage);
        return cachedImage;
    }

    if (![self hitProtectionAllowRequestForKey:cachedKey])
    {
        SAFE_IMAGE_COMPLETE(nil);
        return nil;
    }
    [self hitProtectionRequestBeganForKey:cachedKey];
        
    NSURLRequest *request = [ThumbManager ab_requestForUrl:urlStr useCache:YES];
    AFImageRequestOperation *imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *rawImage) {
        CGFloat aspectRatio = rawImage.size.height / rawImage.size.width;
        CGSize imageSize = CGSizeMake(maxWidth, aspectRatio * maxWidth);
        return [rawImage resizeAndCropToSize:imageSize];
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (image && !CGSizeEqualToSize(image.size, CGSizeZero))
        {
            // all good
            [UIImage ab_setDiskCachedImage:image forKey:cachedKey];
            SAFE_IMAGE_COMPLETE(image);
        }
    } failure:nil];
    [imageOperation start];
    return nil;
}

- (UIImage *)imageForUrl:(NSString *)urlStr scaleToFitSize:(CGSize)maxSize allowClipping:(BOOL)allowClipping onComplete:(void (^)(UIImage *image))onComplete;
{
    NSString *cachedKey = [NSString stringWithFormat:@"%@-%0.f",urlStr,floorf(maxSize.width)];
    
    UIImage *cachedImage = [UIImage ab_diskCachedImageForKey:cachedKey];
    if (cachedImage)
    {        
        SAFE_IMAGE_COMPLETE(cachedImage);
        return cachedImage;
    }
    
    if (![self hitProtectionAllowRequestForKey:cachedKey])
    {
        SAFE_IMAGE_COMPLETE(nil);
        return nil;
    }
    [self hitProtectionRequestBeganForKey:cachedKey];
    
    NSURLRequest *request = [ThumbManager ab_requestForUrl:urlStr useCache:YES];
    AFImageRequestOperation *imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *rawImage) {
        CGSize nSize = maxSize;
//        if (!allowClipping)
//        {
//            CGFloat aspectRatio = rawImage.size.height / rawImage.size.width;
//            CGSize aSize = CGSizeMake(maxSize.width, maxSize.width * aspectRatio);
//            CGFloat sizeDiff = aSize.width / rawImage.width;
//            nSize = CGSizeMake(aSize.width / sizeDiff, aSize.height / sizeDiff);
//        }
        return [rawImage resizeAndCropToSize:nSize];
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (image && !CGSizeEqualToSize(image.size, CGSizeZero))
        {
            // all good
            [UIImage ab_setDiskCachedImage:image forKey:cachedKey];
            SAFE_IMAGE_COMPLETE(image);
        }
    } failure:nil];
    [imageOperation start];
    return nil;
}

- (UIImage *)resizedImageForUrl:(NSString *)urlStr fallbackUrl:(NSString *)fallbackUrl size:(CGSize)size onComplete:(void (^)(UIImage *image))onComplete;
{
  return [self resizedImageForUrl:urlStr fallbackUrl:fallbackUrl size:size onComplete:onComplete onFailure:nil];
}

- (UIImage *)resizedImageForUrl:(NSString *)urlStr fallbackUrl:(NSString *)fallbackUrl size:(CGSize)size onComplete:(void (^)(UIImage *image))onComplete onFailure:(JMAction)onFailure;
{    
    NSString *cachedKey = [NSString stringWithFormat:@"%@-%0.f",urlStr,floorf(size.width)];
    
    UIImage *cachedImage = [UIImage ab_diskCachedImageForKey:cachedKey];
    if (cachedImage)
    {
        SAFE_IMAGE_COMPLETE(cachedImage);
        return cachedImage;
    }
    
    if (![self hitProtectionAllowRequestForKey:cachedKey])
    {
        if (onFailure) onFailure();
        return nil;
    }
    [self hitProtectionRequestBeganForKey:cachedKey];
    
    NSURLRequest *request = [ThumbManager ab_requestForUrl:urlStr useCache:YES];
    AFImageRequestOperation *imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image) {
        if (CGSizeEqualToSize(image.size, CGSizeZero))
        {
            return nil;
        }
        else
        {
            UIImage *resized = nil;
            if ([urlStr jm_contains:@"youtube"])
            {
              // remove video letterboxing from thumbnails
              CGFloat insetAmount = image.size.width / 4.;
              resized = [[image jm_insetImageFromEdges:insetAmount] resizeAndCropToSize:size];
            }
            else
            {
              resized = [image resizeAndCropToSize:size];
            }
            return resized;
        }
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (image && !CGSizeEqualToSize(image.size, CGSizeZero))
        {
            // all good
            [UIImage ab_setDiskCachedImage:image forKey:cachedKey];
            SAFE_IMAGE_COMPLETE(image);
        }
        else
        {
            // try the resize server:
            if (JMIsRetina() && [Resources isPro])
            {
                [self resizeServerThumbnailForUrl:urlStr fallbackUrl:fallbackUrl onComplete:^(UIImage *serverResizedImage) {
                    [UIImage ab_setDiskCachedImage:serverResizedImage forKey:cachedKey];
                    SAFE_IMAGE_COMPLETE(serverResizedImage);
                }];
            }
        }
            
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
      if (onFailure) onFailure();
    }];
    
    __block __ab_weak AFImageRequestOperation *weakOperation = imageOperation;
    [imageOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (totalBytesExpectedToRead > kThumbnailDownloadSizeThresholdBytes)
        {
            [weakOperation cancel];
            weakOperation = nil;
            [self resizeServerThumbnailForUrl:urlStr fallbackUrl:fallbackUrl onComplete:^(UIImage *serverResizedImage) {
                [UIImage ab_setDiskCachedImage:serverResizedImage forKey:cachedKey];
                SAFE_IMAGE_COMPLETE(serverResizedImage);
            }];

//            if (![urlStr equalsString:fallbackUrl])
//            {
//                // try again with fallback
//                DLog(@"trying again with fallback : %@", fallbackUrl);
//                [self resizedImageForUrl:fallbackUrl fallbackUrl:fallbackUrl size:size onComplete:^(UIImage *image) {
//                    [UIImage setCachedImage:image forKey:cachedKey];
//                    SAFE_IMAGE_COMPLETE(image);
//                }];
//            }
        }
    }];
    
    [imageOperation start];
    return nil;
}

#pragma mark - For Debugging

- (void)forceCreateResizeServerThumbnailForUrl:(NSString *)urlStr onComplete:(void (^)(UIImage *image))onComplete;
{    
    if ([urlStr contains:@"reddit.com/"])
    {
        return;
    }
    
    NSString *size = @"thumb";
    if ([Resources isIPAD] && JMIsRetina())
    {
        size = [size stringByAppendingString:@"120"];
    }
    else
    {
        size = [size stringByAppendingString:@"2x"];
    }
    
    NSString *s3urlLink = [ThumbManager ab_s3LinkForUrl:urlStr withSize:size];
    [UIImage ab_removeDiskCachedImageForKey:s3urlLink];
        
    NSString *processUrlLink = [ThumbManager ab_forcedThumbProcessLinkForUrl:urlStr withSize:size];
    NSMutableURLRequest *resizeRequest = [ThumbManager ab_requestForUrl:processUrlLink useCache:NO];
    AFImageRequestOperation *resizeRequestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:resizeRequest imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *thumbImg) {
        if (thumbImg && !CGSizeEqualToSize(thumbImg.size, CGSizeZero))
        {
            // all good
            [UIImage ab_setDiskCachedImage:thumbImg forKey:s3urlLink];

            // give it a chance to upload to s3
            [NSTimer bk_scheduledTimerWithTimeInterval:1. block:^(NSTimer *timer) {
                SAFE_IMAGE_COMPLETE(thumbImg);
            } repeats:NO];
        }
        else
        {
//            DLog(@"forced thumbnail request failed (although request did respond)");
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        DLog(@"forced thumbnail request failed");
    }];
    [resizeRequestOperation start];
}

- (UIImage *)subredditIconForSubreddit:(NSString *)subreddit ident:(NSString *)ident onComplete:(void (^)(UIImage *image))onComplete;
{
    NSMutableString *imageUrl = [NSMutableString stringWithString:kSubredditIconThumbBase];
    [imageUrl appendString:[subreddit lowercaseString]];
    if (JMIsRetina())
    {
      [imageUrl appendFormat:@"@%.fx", [UIScreen mainScreen].scale];
    }
    [imageUrl appendString:@".png"];
    
    NSString *cachedKey = [NSString stringWithFormat:@"%@",imageUrl];
    UIImage *cachedImage = [UIImage ab_diskCachedImageForKey:cachedKey permanentStorage:YES];
    if (cachedImage)
    {        
        SAFE_IMAGE_COMPLETE(cachedImage);
        return cachedImage;
    }
    
    if (![self hitProtectionAllowRequestForKey:imageUrl])
    {
        SAFE_IMAGE_COMPLETE(nil);
        return nil;
    }
    [self hitProtectionRequestBeganForKey:imageUrl];
    
    NSMutableURLRequest *request = [ThumbManager ab_requestForUrl:imageUrl useCache:YES];
    AFImageRequestOperation *imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *rawImage) {
        return rawImage;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (image && !CGSizeEqualToSize(image.size, CGSizeZero))
        {
            // all good
            [UIImage ab_setDiskCachedImage:image forKey:cachedKey permanentStorage:YES];
            SAFE_IMAGE_COMPLETE(image);
        }
        else
        {
            UIImage *placeholderImage = [UIImage skinImageNamed:@"section/reddits-list/subreddit-icon-placeholder"];
            [UIImage ab_setDiskCachedImage:placeholderImage forKey:cachedKey permanentStorage:YES];
            SAFE_IMAGE_COMPLETE(placeholderImage);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        UIImage *placeholderImage = [UIImage skinImageNamed:@"section/reddits-list/subreddit-icon-placeholder"];
        [UIImage ab_setDiskCachedImage:placeholderImage forKey:cachedKey permanentStorage:YES];
        SAFE_IMAGE_COMPLETE(placeholderImage);
    }];
    [imageOperation start];
    return nil;
}

@end
