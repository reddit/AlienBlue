//
//  LinkThumbsOverlay.m
//  AlienBlue
//
//  Created by J M on 18/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "LinkThumbsOverlay.h"
#import "CommentLink.h"
#import "UIImage+Resize.h"
#import "BaseStyledTextNode+LinkThumbs.h"
#import "ThumbManager.h"
#import "LinkThumbsLayouts.h"
#import "Resources.h"
#import "ABHoverPreviewView.h"

#define kLinkInlineImageTopMargin 10.

@interface LinkThumbsOverlay()
@property (strong) BaseStyledTextNode *commentNode;
@property (ab_weak) CommentLink *highlightedCommentLink;

- (CommentLink *)commentLinkAtTouchPoint:(CGPoint)touchPoint;
- (CGRect)rectForTileCommentLink:(CommentLink *)commentLink;
- (CGRect)rectForThumbDrawer;
- (UIImage *)fetchInlineImageOnComplete:(void (^)(UIImage *image))onComplete;
- (void)closeInlineImage;
@end

@implementation LinkThumbsOverlay

+ (CGFloat)heightForTileDrawer:(BaseStyledTextNode *)commentNode constrainedToWidth:(CGFloat)width textWidth:(CGFloat)textWidth;
{
    return [LinkThumbsLayouts heightForTileDrawer:commentNode constrainedToWidth:width textWidth:textWidth];
}

+ (CGFloat)heightForInlineImage:(BaseStyledTextNode *)commentNode constrainedToWidth:(CGFloat)width textWidth:(CGFloat)textWidth;
{
    CGFloat height = 0.;
    if (commentNode && commentNode.inlinePreviewLink)
    {
        CGFloat inlineImageHeight = [commentNode.inlineImageAspectRatio floatValue] * width;
        height += inlineImageHeight;
        height += kLinkInlineImageTopMargin;
    }
    return height;    
}

+ (CGFloat)heightForLinkThumbsOverlayForNode:(BaseStyledTextNode *)commentNode constrainedToWidth:(CGFloat)width textWidth:(CGFloat)textWidth;
{
    CGFloat height = 0.;
    height += [LinkThumbsOverlay heightForTileDrawer:commentNode constrainedToWidth:width textWidth:textWidth];
    height += [LinkThumbsOverlay heightForInlineImage:commentNode constrainedToWidth:width textWidth:textWidth];
    return height;
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        BSELF(LinkThumbsOverlay);
        self.allowTouchPassthrough = NO;
        self.onTap = ^(CGPoint touchPoint)
        {
            CommentLink *touchedLink = [blockSelf commentLinkAtTouchPoint:touchPoint];
            [blockSelf didTapOnCommentLink:touchedLink atTouchPoint:touchPoint];
        };
        self.onPress = ^(CGPoint touchPoint)
        {
            CommentLink *touchedLink = [blockSelf commentLinkAtTouchPoint:touchPoint];
            blockSelf.highlightedCommentLink = touchedLink;
            [blockSelf setNeedsDisplay];
            [blockSelf didPressOnCommentLink:touchedLink];
        };
    }
    return self;
}

- (void)didTapOnCommentLink:(CommentLink *)touchedLink atTouchPoint:(CGPoint)touchPoint;
{
  if ([ABHoverPreviewView hasRecentlyDismissedPreview])
    return;
  
  if (touchedLink)
  {
    CGRect tileRectForLink = [self rectForTileCommentLink:touchedLink];
    CGPoint tileTouchPoint = CGPointMake(touchPoint.x - tileRectForLink.origin.x, touchPoint.y - tileRectForLink.origin.y);
    [LinkThumbsLayouts handleTouchForCommentLink:touchedLink thumbsOverlay:self commentNode:self.commentNode touchPoint:tileTouchPoint];
  }
  else if (!touchedLink && self.commentNode.inlinePreviewLink)
  {
    [self openCommentLink:self.commentNode.inlinePreviewLink forceBrowser:YES];
    [self closeInlineImage];
  }
  else
  {
    [self closeInlineImage];
  }
}

- (void)didPressOnCommentLink:(CommentLink *)touchedLink;
{
  NSURL *URLToPreview = [touchedLink.url URL];

  if (![ABHoverPreviewView canShowPreviewForURL:URLToPreview])
    return;

  CGRect thumbRectForLink = [self rectForTileCommentLink:touchedLink];
  thumbRectForLink = CGRectCropToLeft(thumbRectForLink, 64.);
  thumbRectForLink = CGRectOffset(thumbRectForLink, self.frame.origin.x, self.frame.origin.y);
  if (JMIsIpad())
  {
    thumbRectForLink = CGRectOffset(thumbRectForLink, 6., -3.);
  }
  CGRect globalRect = [self.parentView convertRect:thumbRectForLink toView:[UIApplication sharedApplication].keyWindow];
  [ABHoverPreviewView showPreviewForURL:URLToPreview fromRect:globalRect onSuccessfulPresentation:nil];
}

- (CommentLink *)commentLinkAtTouchPoint:(CGPoint)touchPoint;
{
    __block CommentLink *touchedLink = nil;
    BSELF(LinkThumbsOverlay);
    [self.commentNode.thumbLinks each:^(CommentLink *link) {
        CGRect thumbRectForLink = [blockSelf rectForTileCommentLink:link];
        if (CGRectContainsPoint(thumbRectForLink, touchPoint))
            touchedLink = link;
    }];
    return touchedLink;
}

- (void)updateForNode:(BaseStyledTextNode *)commentNode;
{
    self.commentNode = commentNode;
    [self setNeedsDisplay];
}

- (void)closeInlineImage;
{
    self.commentNode.inlinePreviewLink = nil;
    [self.commentNode performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
}

- (void)openCommentLink:(CommentLink *)commentLink forceBrowser:(BOOL)forceBrowser;
{
    if (forceBrowser)
    {
        [self closeInlineImage];
        [self.commentNode.delegate performSelector:@selector(openLinkUrl:) withObject:commentLink.url];
        return;
    }
    
    // if the user taps on the same thumbnail, hide the inline preview
    if (self.commentNode.inlinePreviewLink == commentLink)
    {
        [self closeInlineImage];
        return;
    }
    
    if (commentLink.linkType != LinkTypePhoto)
    {
        [self closeInlineImage];
        [self.commentNode.delegate performSelector:@selector(openLinkUrl:) withObject:commentLink.url];
        return;
    }
    
    self.commentNode.inlinePreviewLink = commentLink;
    
    typedef void (^InlineImageAction)(UIImage *image);

    BSELF(LinkThumbsOverlay);
    InlineImageAction action = ^(UIImage *image)
    {
        if (image && image.size.width > 0 && image.size.height > 0)
        {
            blockSelf.commentNode.inlineImageAspectRatio = [NSNumber numberWithFloat:(image.size.height / image.size.width)];
            [blockSelf.commentNode performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
        }
    };
    
    UIImage *inlineImage = [self fetchInlineImageOnComplete:action];
    if (inlineImage)
    {
        action(inlineImage);
    }
}

- (CGRect)rectForTileCommentLink:(CommentLink *)commentLink;
{
    CGRect paneBounds = [self rectForThumbDrawer];
    return [LinkThumbsLayouts rectForTileCommentLink:commentLink commentNode:self.commentNode paneBounds:paneBounds];
}

- (void)drawThumbnailForCommentLink:(CommentLink *)commentLink inFrame:(CGRect)thumbnailRect
{
    BSELF(LinkThumbsOverlay);
    
    UIImage *thumbImage = nil;
    
    BOOL restricted = [self.commentNode containsNSFWContent];
    BOOL nsfw = NO;
    
    if (!restricted)
    {
        thumbImage = [[ThumbManager manager] thumbnailForUrl:commentLink.url fallbackUrl:nil useFaviconWhenAvailable:YES onComplete:^(UIImage *image) {
            [blockSelf setNeedsDisplay];
        }];
    }
    
    UIImage *placeholder = [UIImage placeholderThumbImageForUrl:commentLink.url];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGFloat radii = 4;
    [UIView addRoundedRectToPathForContext:context rect:thumbnailRect ovalWidth:radii ovalHeight:radii];
    CGContextClip(context);
    
    if (thumbImage)
    {
        [thumbImage drawAtPoint:thumbnailRect.origin];
    }
    else
    {
        [[UIColor colorForBackground] set];
        [[UIBezierPath bezierPathWithRect:thumbnailRect] fill];
        CGRect placeholderRect = CGRectCenterWithSize(thumbnailRect, placeholder.size);
        [placeholder drawAtPoint:placeholderRect.origin];
        
        if (restricted && [Resources showRetinaThumbnails] && [UDefaults boolForKey:kABSettingKeyShowNSFWRibbon])
        {
            nsfw = [self.commentNode containsNSFWContent];            
            if (nsfw)
            {
                UIImage *ribbon = [UIImage skinImageNamed:@"section/post-list/nsfw-ribbon"];
                CGPoint ribbonPoint = thumbnailRect.origin;
                ribbonPoint.x = ribbonPoint.x + 3.;
                ribbonPoint.y = ribbonPoint.y + 3.;
                
                if ([Resources isIPAD])
                {
                    ribbonPoint.x += 10.;
                    ribbonPoint.y += 10.;
                }

                [ribbon drawAtPoint:ribbonPoint];
            }
        }
    }
  
    if (thumbImage && commentLink.linkType == LinkTypePhoto)
    {
        CGRect linkTypeRect = CGRectMake(thumbnailRect.origin.x, CGRectGetMaxY(thumbnailRect) - 11., thumbnailRect.size.width, 11.);
        [[UIColor colorWithWhite:0. alpha:0.5] set];
        [[UIBezierPath bezierPathWithRect:linkTypeRect] fill];
        
        [[UIColor colorWithWhite:1. alpha:0.8] set];
        CGPoint triangeCenter = CGPointCenterOfRect(linkTypeRect);
        [[UIBezierPath bezierPathWithTriangleCenter:triangeCenter sideLength:6 angle:180.] fill];
    }

    CGContextRestoreGState(context);
    
    UIImage *shadowOverlay = [UIImage thumbnailShadowImageFittingSize:thumbnailRect.size];
    CGFloat shadowOpacity = thumbImage ? 1. : 0.3;
    CGPoint shadowOrigin = CGPointMake(thumbnailRect.origin.x, thumbnailRect.origin.y);
    [shadowOverlay drawAtPoint:shadowOrigin blendMode:kCGBlendModeNormal alpha:shadowOpacity];
    
    if (self.highlighted && commentLink == self.highlightedCommentLink)
    {
        // draw additional shadow to make the image look pushed in
        [shadowOverlay drawAtPoint:shadowOrigin blendMode:kCGBlendModeNormal alpha:shadowOpacity];
    } else if (commentLink == self.commentNode.inlinePreviewLink)
    {
        [shadowOverlay drawAtPoint:shadowOrigin blendMode:kCGBlendModeNormal alpha:shadowOpacity];
        [shadowOverlay drawAtPoint:shadowOrigin blendMode:kCGBlendModeNormal alpha:shadowOpacity];
    }
}

- (void)drawTileForCommentLink:(CommentLink *)commentLink;
{
    CGRect tileRect = [self rectForTileCommentLink:commentLink];
    return [LinkThumbsLayouts drawTileForCommentLink:commentLink thumbsOverlay:self commentNode:self.commentNode tileRect:tileRect];
}

- (UIImage *)fetchInlineImageOnComplete:(void (^)(UIImage *image))onComplete;
{
    NSString *imageUrl = [self.commentNode.inlinePreviewLink.url deeplink];

    UIImage *inlineImage = [[ThumbManager manager] imageForUrl:imageUrl scaleToFitWidth:self.bounds.size.width onComplete:^(UIImage *image) {
        onComplete(image);
    }];
    return inlineImage;
    
}

- (void)drawInlineImage;
{
    CGFloat textWidth = self.bounds.size.width - self.commentTextRect.origin.x;
    CGFloat inlineImageOffset = [LinkThumbsOverlay heightForTileDrawer:self.commentNode constrainedToWidth:self.bounds.size.width textWidth:textWidth];
    inlineImageOffset += kLinkInlineImageTopMargin;
    
    BSELF(LinkThumbsOverlay);
    UIImage *inlineImage = [self fetchInlineImageOnComplete:^(UIImage *image) {
        [blockSelf setNeedsDisplay];
    }];

    [inlineImage drawAtPoint:CGPointMake(0., inlineImageOffset)];
}

- (CGRect)rectForThumbDrawer;
{
    CGRect commentRect = self.commentTextRect;
    CGRect bounds = self.bounds;
    BaseStyledTextNode *commentNode = self.commentNode;
    
    CGFloat drawerHeight = [LinkThumbsOverlay heightForTileDrawer:commentNode constrainedToWidth:bounds.size.width textWidth:commentRect.size.width];
    CGRect drawerRect = CGRectMake(commentRect.origin.x, 0, commentRect.size.width, drawerHeight);
    return drawerRect;
}

- (void)drawRect:(CGRect)rect;
{
    if (![UIDevice jm_isSlowDevice])
    {
      CGRect thumbDrawerRect = [self rectForThumbDrawer];
      thumbDrawerRect = CGRectInset(thumbDrawerRect, 2., 0.);
      UIBezierPath *insetPath = [UIBezierPath bezierPathWithRoundedRect:thumbDrawerRect cornerRadius:7.];
      
      [[UIColor colorWithWhite:0. alpha:0.03] set];
      [insetPath fill];
      
      CGFloat borderWhite = [Resources isNight] ? 1. : 0.;
      [[UIColor colorWithWhite:borderWhite alpha:0.1] set];
      [insetPath stroke];
    }
    
    BSELF(LinkThumbsOverlay);
    [self.commentNode.thumbLinks each:^(CommentLink *linkItem) {
        [blockSelf drawTileForCommentLink:linkItem];
    }];
    
    if (self.commentNode.inlinePreviewLink)
    {
        [self drawInlineImage];
    }
}

@end
