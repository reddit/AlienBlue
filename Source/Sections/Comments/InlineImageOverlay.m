//
//  InlineImageOverlay.m
//  AlienBlue
//
//  Created by J M on 1/01/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "InlineImageOverlay.h"
#import "NInlineImageCell.h"
#import "ThumbManager.h"

@interface InlineImageOverlay()
@property (strong) InlineImageNode *node;
- (void)grabInlineImage;
- (UIImage *)fetchInlineImageOnComplete:(void (^)(UIImage *image))onComplete;
@end

@interface InlineImageOverlay()
@end

@implementation InlineImageOverlay

+ (CGFloat)heightForInlinePreviewForNode:(InlineImageNode *)node constrainedToWidth:(CGFloat)width;
{
    return width * [node.inlineImageAspectRatio floatValue];
};

+ (void)precacheImageForNode:(InlineImageNode *)node constrainedToWidth:(CGFloat)width;
{
    NSString *imageUrl = [node.commentLink.url deeplink];
    [[ThumbManager manager] imageForUrl:imageUrl scaleToFitWidth:width onComplete:^(UIImage *image) {
    }];    
}

- (void)updateForNode:(InlineImageNode *)node;
{
    self.node = node;
    if (!node.inlineImageAspectRatio)
    {
        [self grabInlineImage];
    }
}

- (void)grabInlineImage;
{
    typedef void (^InlineImageAction)(UIImage *image);
    
    BSELF(InlineImageOverlay);
    InlineImageAction action = ^(UIImage *image)
    {
        if (image && image.size.width > 0 && image.size.height > 0)
        {
            blockSelf.node.inlineImageAspectRatio = [NSNumber numberWithFloat:(image.size.height / image.size.width)];
            [blockSelf.node performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
        }
    };
    
    UIImage *inlineImage = [self fetchInlineImageOnComplete:action];
    if (inlineImage)
    {
        action(inlineImage);
    }
}

- (UIImage *)fetchInlineImageOnComplete:(void (^)(UIImage *image))onComplete;
{
    NSString *imageUrl = [self.node.commentLink.url deeplink];
    
    UIImage *inlineImage = [[ThumbManager manager] imageForUrl:imageUrl scaleToFitWidth:self.bounds.size.width onComplete:^(UIImage *image) {
        onComplete(image);
    }];
    return inlineImage;
}

- (void)drawRect:(CGRect)rect;
{
    BSELF(InlineImageOverlay);
    UIImage *inlineImage = [self fetchInlineImageOnComplete:^(UIImage *image) {
        [blockSelf setNeedsDisplay];
    }];
    [inlineImage drawAtPoint:CGPointZero];
}
@end