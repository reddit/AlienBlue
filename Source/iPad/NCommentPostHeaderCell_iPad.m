//
//  NCommentPostHeaderCell_iPad.m
//  AlienBlue
//
//  Created by J M on 20/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NCommentPostHeaderCell_iPad.h"
#import "Post+Style_iPad.h"
#import "NavigationManager_iPad.h"

@interface NCommentPostHeaderCell_iPad()
@end

@implementation NCommentPostHeaderCell_iPad

- (void)createSubviews;
{
    BSELF(NCommentPostHeaderCell_iPad);
    [super createSubviews];
    
    self.titleTextOverlay.drawBlock = ^(BOOL highlighted, BOOL selected, CGRect bounds)
    {
        [[blockSelf.post styledTitleWithDetails_iPad] drawInRect:bounds];
    };
    
    self.thumbOverlay.onTap = ^(CGPoint touchPoint)
    {
      // give a bit of buffer near the top of the overlay
      // so that it doesn't interfere with the Upvote button above it
      if (touchPoint.y > 10)
      {
        NSString *url = [(CommentPostHeaderNode *)blockSelf.node post].url;
        [blockSelf.node.delegate performSelector:@selector(openLinkUrl:) withObject:url];
      }
    };
    
    self.titleBackgroundOverlay.hidden = YES;    
    self.subdetailsBar.hidden = YES;
  
//    self.subredditOverlay.hidden = YES;
//    self.usernameOverlay.hidden = YES;
//    self.scoreOverlay.hidden = YES;

//    self.commentsTitle = [JMViewOverlay overlayWithFrame:CGRectMake(24., 0., 200., 20.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
//        [[UIColor colorForText] set];
//        [@"Comments" drawAtPoint:CGPointZero withFont:[UIFont boldSystemFontOfSize:18.]];
//    }];
//    [self.containerView addOverlay:self.commentsTitle];
}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];

    self.titleTextOverlay.top = 10.;
  
    self.titleTextOverlay.left = 24.;

    self.thumbOverlay.right = self.width - 16.;
    self.thumbOverlay.top = 12.;

    self.faviconOverlay.hidden = YES;
  
    CGFloat textHeight = [[self.post styledTitleWithDetails_iPad] heightConstrainedToWidth:self.titleTextOverlay.width];
    if (textHeight < self.thumbOverlay.height)
    {
      CGFloat adjustment = (self.thumbOverlay.height - textHeight) / 2.;
      self.titleTextOverlay.top = self.thumbOverlay.top + adjustment;
    }
  
//    CGFloat titleMargin = [[self class] titleMarginWithThumbnail];
//    CGFloat favIconTop = [[self.post styledTitleWithDetails_iPad] heightConstrainedToWidth:(self.containerView.size.width - titleMargin)] - 1.;
//    self.faviconOverlay.top = favIconTop;
}

// overrides for customisation

+ (CGFloat)titleMarginWithThumbnail;
{
    return 120.;
}

+ (CGFloat)minimumHeightWithThumbnail;
{
    return 74.;
}

+ (CGFloat)subdetailsBarHeight;
{
    return 0.;
}

+ (CGFloat)heightForCellHeaderForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    CGFloat height = 0.;
    CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)node;
    CGFloat titleMargin = [[self class] titleMarginWithThumbnail];
    height += [[headerNode.post styledTitleWithDetails_iPad] heightConstrainedToWidth:(bounds.size.width - titleMargin)];
    height += 18.; // title padding;
    height = MAX(height, [[self class] minimumHeightWithThumbnail]);
    
    height += [[self class] subdetailsBarHeight] + [[self class] subdetailsBarBottomMargin];
    return height;
}

+ (CGSize)commentTextPadding;
{
    return CGSizeMake(23. ,  10.);
}

//+ (CGRect)rectForCommentBodyInNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
//{
//    CGRect normalRect = [NCommentPostHeaderCell rectForCommentBodyInNode:node bounds:bounds];
//    CGRect paddedRect = CGRectInset(normalRect, 15., 0.);
//    paddedRect = CGRectOffset(paddedRect, 0., 15.);
//    return paddedRect;
//}

@end
