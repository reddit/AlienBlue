//
//  ThumbOverlay.m
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "ThumbOverlay.h"
#import "ThumbManager.h"
#import "Resources.h"
#import "Post.h"

@interface ThumbOverlay()
@property (strong) NSString *url;
@property (strong) NSString *fallbackUrl;
@property BOOL showRetinaVersion;
@property (strong) UIImage *lastImage;
@end

@implementation ThumbOverlay

- (void)updateWithUrl:(NSString *)url fallbackUrl:(NSString *)fallbackUrl showRetinaVersion:(BOOL)showRetinaVersion;
{
    self.url = url;
    self.fallbackUrl = fallbackUrl;
    self.showRetinaVersion = showRetinaVersion;
    self.lastImage = nil;
    [self setNeedsDisplay];
}

- (void)updateWithPost:(Post *)post;
{
    BOOL showRetinaVersion = [Resources showRetinaThumbnails];
  
    NSString *urlForThumb = (showRetinaVersion) ? post.url : post.rawThumbnail;
    NSString *fallbackUrl = (showRetinaVersion) ? post.rawThumbnail : nil;
    [self updateWithUrl:urlForThumb fallbackUrl:fallbackUrl showRetinaVersion:showRetinaVersion];
}

- (void)drawWithRetrievedThumbnailImage:(UIImage *)thumbnailImage;
{
  CGRect thumbnailRect = self.bounds;
  
  if (self.showRightArrow)
  {
    CGRect shiftedthumbRect = CGRectOffset(thumbnailRect, 10., 0.);
    CGRect linkTypeRect = CGRectMake(shiftedthumbRect.origin.x + shiftedthumbRect.size.width - 10., shiftedthumbRect.origin.y, 10., shiftedthumbRect.size.height);
    UIColor *triangleColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    [triangleColor set];
    CGPoint triangleCenter = CGPointCenterOfRect(linkTypeRect);
    triangleCenter.x += 1.;
    [UIView startEtchedDraw];
    [[UIBezierPath bezierPathWithTriangleCenter:triangleCenter sideLength:5. angle:90.] fill];
    [UIView endEtchedDraw];
  }
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  
  CGFloat radii = 3.;
  [UIView addRoundedRectToPathForContext:context rect:thumbnailRect ovalWidth:radii ovalHeight:radii];
  CGContextClip(context);

  if (thumbnailImage)
  {
    self.lastImage = thumbnailImage;
    if ([UIScreen mainScreen].scale >= 3)
    {
      [thumbnailImage drawInRect:thumbnailRect];
    }
    else
    {
      [thumbnailImage drawAtPoint:thumbnailRect.origin];
    }
  }
  else
  {
    UIImage *placeholderIcon = [UIImage placeholderThumbImageForUrl:self.url];
    [[UIColor colorForBackground] set];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    CGRect placeholderRect = CGRectCenterWithSize(self.bounds, placeholderIcon.size);
    [placeholderIcon drawAtPoint:placeholderRect.origin];
  }

  CGContextRestoreGState(context);
  UIImage *shadow = [UIImage thumbnailShadowImageFittingSize:self.bounds.size];
  CGFloat yOffset = 0;
  CGPoint shadowOrigin = CGPointMake(thumbnailRect.origin.x, thumbnailRect.origin.y + yOffset);
  CGFloat shadowOpacity = thumbnailImage ? 1. : 0.3;
  [shadow drawAtPoint:shadowOrigin blendMode:kCGBlendModeNormal alpha:shadowOpacity];
  
  if (self.highlighted)
  {
    // draw additional shadow to make the image look pushed in
    [shadow drawAtPoint:shadowOrigin];
  }
}

- (void)drawRect:(CGRect)rect;
{
    UIImage *thumbnailImage;
  
    BSELF(ThumbOverlay);
    if (self.showRetinaVersion)
    {
        thumbnailImage = [[ThumbManager manager] thumbnailForUrl:self.url fallbackUrl:self.fallbackUrl useFaviconWhenAvailable:NO onComplete:^(UIImage *image) {
            [blockSelf setNeedsDisplay];
        }];
    }
    else
    {
        thumbnailImage = [[ThumbManager manager] resizedImageForUrl:self.url fallbackUrl:self.fallbackUrl size:self.bounds.size onComplete:^(UIImage *image) {
            [blockSelf setNeedsDisplay];
        }];
    }
    
    if (self.allowLocalImageReplacement && !thumbnailImage)
    {
        // try a local thumbnail for common domains
        thumbnailImage = [ThumbManager localImageForUrl:self.url];
    }
    
    // to avoid blinking if the image needs to reload from disk-cache
    if (!thumbnailImage && self.lastImage)
    {
        thumbnailImage = self.lastImage;
    }
  
    [self drawWithRetrievedThumbnailImage:thumbnailImage];
}

@end
