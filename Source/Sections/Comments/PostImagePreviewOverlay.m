//
//  PostImagePreviewOverlay.m
//  AlienBlue
//
//  Created by J M on 20/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostImagePreviewOverlay.h"
#import "ThumbManager.h"

@interface PostImagePreviewOverlay()
@property (strong) CommentPostHeaderNode *node;
- (void)grabInlineImage;
- (UIImage *)fetchInlineImageOnComplete:(void (^)(UIImage *image))onComplete;
@end


@implementation PostImagePreviewOverlay

+ (CGFloat)heightForInlinePreviewForNode:(CommentPostHeaderNode *)node constrainedToWidth:(CGFloat)width;
{
    return width * [node.inlineImageAspectRatio floatValue];
};

- (void)updateForNode:(CommentPostHeaderNode *)node;
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
  
    BSELF(PostImagePreviewOverlay);
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
    NSString *imageUrl = [self.node.post.url deeplink];
    
    UIImage *inlineImage = [[ThumbManager manager] imageForUrl:imageUrl scaleToFitWidth:self.bounds.size.width onComplete:^(UIImage *image) {
        onComplete(image);
    }];
    return inlineImage;
}

- (void)drawRect:(CGRect)rect;
{
    BSELF(PostImagePreviewOverlay);
    UIImage *inlineImage = [self fetchInlineImageOnComplete:^(UIImage *image) {
        [blockSelf setNeedsDisplay];
    }];
    [inlineImage drawAtPoint:CGPointZero];
}


@end
