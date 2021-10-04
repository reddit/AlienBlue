//
//  LinkThumbsLayouts.m
//  AlienBlue
//
//  Created by J M on 21/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "LinkThumbsLayouts.h"
#import "BaseStyledTextNode+LinkThumbs.h"
#import "Resources.h"

#pragma -
#pragma mark - Grid Layout

//#define kLinkThumbSize CGSizeMake(50., 50.)
//#define kLinkTileSize CGSizeMake(60., 64.)

NSUInteger singleToTileThreshold()
{
    // always display in single form
    if ([Resources thumbSize].width < 50)
        return 1000;
    else
        return 5;
}

CGSize tileSize()
{
    CGSize tileSize = [Resources thumbSize];
    return CGSizeMake(tileSize.width + 10., tileSize.height + 14.);
}

TileDrawerHeightCalculator Grid_tileDrawerHeight = ^(BaseStyledTextNode *commentNode, CGFloat boundWidth, CGFloat textWidth){
    CGSize tSize = tileSize();
    NSUInteger maxThumbIndex = [commentNode.thumbLinks count] - 1;
    CGFloat tilesPerRow = floorf(textWidth / tSize.width);
    NSUInteger row = maxThumbIndex / tilesPerRow;
    CGFloat xOffset = fmodf(maxThumbIndex * tSize.width, tilesPerRow * tSize.width);
    CGFloat yOffset = row * tSize.height;
    CGRect thumbRect = CGRectMake(xOffset, yOffset, tSize.width, tSize.height);
    CGFloat height = CGRectGetMaxY(thumbRect);
    return height;
};

TileRectForCommentLink Grid_tileRectForCommentLink = ^(CommentLink *commentLink, BaseStyledTextNode *commentNode, CGRect paneBounds)
{
    CGSize tSize = tileSize();
    CGFloat tilesPerRow = floorf(paneBounds.size.width / tSize.width);
    
    // adjust to center the thumbnails in the bounds
//    paneBounds.origin.x += (paneBounds.size.width - tilesPerRow * kLinkTileSize.width) / 2.;
    
    NSUInteger thumbIndex = [commentNode.thumbLinks indexOfObject:commentLink];
    NSUInteger row = thumbIndex / tilesPerRow;
    CGFloat xOffset = fmodf(thumbIndex * tSize.width, tilesPerRow * tSize.width);
    CGFloat yOffset = row * tSize.height;
    
    CGRect tileRect = CGRectMake(xOffset, yOffset, tSize.width, tSize.height);
    tileRect.origin.x += paneBounds.origin.x + 4.;
    return tileRect;
};

TileDrawForCommentLink Grid_tileDrawForCommentLink = ^(CommentLink *commentLink, LinkThumbsOverlay *thumbsOverlay, BaseStyledTextNode *commentNode, CGRect tileRect){
    CGRect thumbnailRect = CGRectCenterWithSize(tileRect, [Resources thumbSize]);
    [thumbsOverlay drawThumbnailForCommentLink:commentLink inFrame:thumbnailRect];
};

HandleTouchForCommentLink Grid_handleTouchForCommentLink = ^(CommentLink *commentLink, LinkThumbsOverlay *thumbsOverlay, BaseStyledTextNode *commentNode, CGPoint touchPoint) {
    [thumbsOverlay openCommentLink:commentLink forceBrowser:NO];
};

#pragma -
#pragma mark - Single Layout

TileDrawerHeightCalculator Single_tileDrawerHeight = ^(BaseStyledTextNode *commentNode, CGFloat boundWidth, CGFloat textWidth){
    CGFloat tileWidth = ([commentNode.thumbLinks count] == 1 || commentNode.level > 1) ? textWidth : textWidth / 2.;
    CGSize tileSize = CGSizeMake(tileWidth, [Resources thumbSize].height + 10.);
    NSUInteger maxThumbIndex = [commentNode.thumbLinks count] - 1;
    CGFloat tilesPerRow = floorf(textWidth / tileSize.width);
    NSUInteger row = maxThumbIndex / tilesPerRow;
    CGFloat xOffset = fmodf(maxThumbIndex * tileSize.width, tilesPerRow * tileSize.width);
    CGFloat yOffset = row * tileSize.height;
    CGRect thumbRect = CGRectMake(xOffset, yOffset, tileSize.width, tileSize.height);
    CGFloat height = CGRectGetMaxY(thumbRect);
    return height;
};

TileRectForCommentLink Single_tileRectForCommentLink = ^(CommentLink *commentLink, BaseStyledTextNode *commentNode, CGRect paneBounds)
{
    CGFloat tileWidth = ([commentNode.thumbLinks count] == 1 || commentNode.level > 1) ? paneBounds.size.width : paneBounds.size.width / 2.;
    CGSize tileSize = CGSizeMake(tileWidth, [Resources thumbSize].height + 10.);
    CGFloat tilesPerRow = floorf(paneBounds.size.width / tileSize.width);
        
    NSUInteger thumbIndex = [commentNode.thumbLinks indexOfObject:commentLink];
    NSUInteger row = thumbIndex / tilesPerRow;
    CGFloat xOffset = fmodf(thumbIndex * tileSize.width, tilesPerRow * tileSize.width);
    CGFloat yOffset = row * tileSize.height;
    
    CGRect tileRect = CGRectMake(xOffset, yOffset, tileSize.width, tileSize.height);
    
    tileRect.origin.x += paneBounds.origin.x;
    return tileRect;
};

TileDrawForCommentLink Single_tileDrawForCommentLink = ^(CommentLink *commentLink, LinkThumbsOverlay *thumbsOverlay, BaseStyledTextNode *commentNode, CGRect tileRect){
    CGRect thumbnailRect = CGRectCenterWithSize(tileRect, [Resources thumbSize]);
    thumbnailRect.origin.x = tileRect.origin.x + 8.;
    [thumbsOverlay drawThumbnailForCommentLink:commentLink inFrame:thumbnailRect];
    
    CGRect titleRect = CGRectCenterWithSize(tileRect, CGSizeMake(tileRect.size.width - [Resources thumbSize].width - 24., 20.));
    titleRect.origin.y -= 4.;
    titleRect.origin.x = CGRectGetMaxX(thumbnailRect) + 8.;

    NSMutableString *caption = [NSMutableString stringWithString:[commentLink.caption standardCharacterSetOnly]];
  
    NSString *captionSuffix = [commentLink.url jm_contains:@"gif"] ? @"GIF" : [CommentLink friendlyNameFromLinkType:commentLink.linkType];

    [caption appendFormat:@" (%@)", captionSuffix];
    if (commentLink.linkType == LinkTypePhoto && commentLink == commentNode.inlinePreviewLink && !commentNode.inlineImageAspectRatio)
    {
        caption = [NSMutableString stringWithString:@"Loading..."];
    }
    
    UIFont *captionFont = [UIFont skinFontWithName:kBundleFontPostSubtitleBold];
    [[UIColor lightGrayColor] set];
    [caption drawInRect:titleRect withFont:captionFont lineBreakMode:UILineBreakModeTailTruncation];

    UIFont *subtitleFont = [UIFont skinFontWithName:kBundleFontPostSubtitle];
    titleRect.origin.y += 16.;
    [[commentLink.url formattedUrl] drawInRect:titleRect withFont:subtitleFont lineBreakMode:UILineBreakModeTailTruncation];
};

HandleTouchForCommentLink Single_handleTouchForCommentLink = ^(CommentLink *commentLink, LinkThumbsOverlay *thumbsOverlay, BaseStyledTextNode *commentNode, CGPoint touchPoint) {
    BOOL forceBrowser = touchPoint.x > ([Resources thumbSize].width + 14.);
    [thumbsOverlay openCommentLink:commentLink forceBrowser:forceBrowser];
};


@implementation LinkThumbsLayouts

+ (CGFloat)heightForTileDrawer:(BaseStyledTextNode *)commentNode constrainedToWidth:(CGFloat)width textWidth:(CGFloat)textWidth;
{
    CGFloat height;
    if ([commentNode.thumbLinks count] < singleToTileThreshold())
        height = Single_tileDrawerHeight(commentNode,width,textWidth);
    else
        height = Grid_tileDrawerHeight(commentNode,width,textWidth);
    return height;
}

+ (CGRect)rectForTileCommentLink:(CommentLink *)commentLink commentNode:(BaseStyledTextNode *)commentNode paneBounds:(CGRect)paneBounds;
{    
    CGRect tileRect;
    if ([commentNode.thumbLinks count] < singleToTileThreshold())
        tileRect = Single_tileRectForCommentLink(commentLink, commentNode, paneBounds);
    else
        tileRect = Grid_tileRectForCommentLink(commentLink, commentNode, paneBounds);
    return tileRect;
}

+ (void)drawTileForCommentLink:(CommentLink *)commentLink thumbsOverlay:(LinkThumbsOverlay *)thumbsOverlay commentNode:(BaseStyledTextNode *)commentNode tileRect:(CGRect)tileRect;
{
    if ([commentNode.thumbLinks count] < singleToTileThreshold())
        Single_tileDrawForCommentLink(commentLink, thumbsOverlay, commentNode, tileRect);
    else
        Grid_tileDrawForCommentLink(commentLink, thumbsOverlay, commentNode, tileRect);
}

+ (void)handleTouchForCommentLink:(CommentLink *)commentLink thumbsOverlay:(LinkThumbsOverlay *)thumbsOverlay commentNode:(BaseStyledTextNode *)commentNode touchPoint:(CGPoint)touchPoint;
{
    if ([commentNode.thumbLinks count] < singleToTileThreshold())
        Single_handleTouchForCommentLink(commentLink, thumbsOverlay, commentNode, touchPoint);
    else
        Grid_handleTouchForCommentLink(commentLink, thumbsOverlay, commentNode, touchPoint);
}

@end
