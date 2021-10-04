//
//  BaseStyledTextNode.m
//  AlienBlue
//
//  Created by J M on 19/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "BaseStyledTextNode.h"
#import "Resources.h"
#import "ThumbManager.h"
#import "CommentLink.h"

@interface BaseStyledTextNode()
@property NSUInteger numThumbnailsPrefetched;
@end

@implementation BaseStyledTextNode

- (NSString *)elementId;
{
    NSLog(@"ELEMENT ID REQUESTED");
    return nil;
}

- (BOOL)containsNSFWContent;
{
    NSLog(@"isNSFW REQUESTED");
    return NO;
}

- (BOOL)containsRestrictedContent;
{
    NSLog(@"isRestricted REQUESTED");
    return NO;
}

- (NSAttributedString *)styledText;
{
    NSLog(@"STYLED TEXT REQUESTED");
    return nil;
}

- (NSArray *)thumbLinks;
{
    NSLog(@"LINKS REQUESTED");
    return nil;
}

- (CGFloat)heightForBodyConstrainedToWidth:(CGFloat)width;
{
    NSLog(@"HEIGHT FOR BODY REQUESTED");
    return 0.;
}

- (void)prefetchThumbnailsToCacheOnComplete:(ABAction)onComplete;
{
    self.numThumbnailsPrefetched = 0;
    if (![Resources showRetinaThumbnails])
        return;

    BSELF(BaseStyledTextNode);
    [self.thumbLinks each:^(CommentLink *link) {
        
        UIImage *thumb = [[ThumbManager manager] thumbnailForUrl:link.url fallbackUrl:nil useFaviconWhenAvailable:YES onComplete:^(UIImage *image){
            blockSelf.numThumbnailsPrefetched++;
            if (blockSelf.numThumbnailsPrefetched == blockSelf.thumbLinks.count)
            {
                onComplete();
            }
        }];

        if (thumb)
        {
            blockSelf.numThumbnailsPrefetched++;
            if (blockSelf.numThumbnailsPrefetched == blockSelf.thumbLinks.count)
            {
                onComplete();
            }
        }
    }];
}

@end
