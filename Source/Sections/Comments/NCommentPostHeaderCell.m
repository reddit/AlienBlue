//
//  NCommentPostHeaderCell.m
//  AlienBlue
//
//  Created by J M on 19/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "NCommentPostHeaderCell.h"
#import "Post.h"
#import "Post+Style.h"
#import "Comment.h"
#import "CommentPostHeaderNode.h"
#import "CommentSeparatorBar.h"
#import "PostImagePreviewOverlay.h"
#import "Resources.h"
#import "NavigationManager.h"
#import "CommentPostHeaderToolbar.h"

#define kCommentPostHeaderCellExpandTextOverlayHeight 30.

@interface NCommentPostHeaderCell ()
@property (strong) CommentPostHeaderThumbnailOverlay *thumbOverlay;
@property (strong) JMViewOverlay *titleTextOverlay;
@property (strong) JMViewOverlay *titleBackgroundOverlay;

@property (strong) JMViewOverlay *subdetailsBar;
@property (strong) FaviconOverlay *faviconOverlay;
@property (strong) JMViewOverlay *selfTextDivider;
@property (strong) JMViewOverlay *expandTextOverlay;
@property (strong) PostImagePreviewOverlay *imagePreviewOverlay;

@end

@implementation NCommentPostHeaderCell

+ (CGFloat)subdetailsBarHeight;
{
//  return kCommentPostHeaderToolbarHeight;
  return 0.;
}

+ (CGFloat)subdetailsBarBottomMargin;
{
    return 8.;
}

+ (CGFloat)titleMarginWithoutThumbnail;
{
    return 28.;
}

+ (CGFloat)titleMarginWithThumbnail;
{
    return 80.;
}

+ (CGFloat)minimumHeightWithThumbnail;
{
    return 62.;
}


+ (CGFloat)indentForCellTextForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    return 0.;
}

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)node;
    CGFloat height = [[self class] heightForCellHeaderForNode:headerNode bounds:tableView.bounds];

    if (![headerNode.comment.body isEmpty])
    {
        height = [[self class] heightForCellBody:node tableView:tableView];        
    }
    else if (headerNode.post.linkType == LinkTypePhoto)
    {
        height += [PostImagePreviewOverlay heightForInlinePreviewForNode:headerNode constrainedToWidth:tableView.width];
        height += [NBaseStyledTextCell heightForCellFooterForNode:headerNode bounds:tableView.bounds];
    }
    else
    {
        height += [NBaseStyledTextCell heightForCellFooterForNode:headerNode bounds:tableView.bounds];        
    }
    
    if ([Resources compact] && [headerNode.comment.body isEmpty])
    {
        height -= 5.;
    }
  
    if (node.collapsed)
    {
      height += kCommentPostHeaderCellExpandTextOverlayHeight;
    }

    return height;
}

+ (CGFloat)heightForCellHeaderForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    CGFloat height = 0.;
    CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)node;
    CGFloat titleMargin = headerNode.post.hasExternalLink ? [[self class] titleMarginWithThumbnail] : [[self class] titleMarginWithoutThumbnail];
    height += [[headerNode.post styledTitleWithDetails] heightConstrainedToWidth:(bounds.size.width - titleMargin)];
    height += 16.; // title padding;
    
    height = MAX(height, [[self class] minimumHeightWithThumbnail]);
    
    height += [[self class] subdetailsBarHeight] + [[self class] subdetailsBarBottomMargin];
    
    return height;
}

+ (CGFloat)heightForCellFooterForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
  CGFloat height = [NBaseStyledTextCell heightForCellFooterForNode:node bounds:bounds];
  height += 5.;
  return height;
}

- (Post *)post;
{
    return [(CommentPostHeaderNode *)self.node post];
}

- (CGFloat)recommendedTitleMargin;
{
  return self.post.hasExternalLink ? [[self class] titleMarginWithThumbnail] : [[self class] titleMarginWithoutThumbnail];
}

- (void)createSubdetailBar;
{
  self.subdetailsBar = [JMViewOverlay new];
  [self.containerView addOverlay:self.subdetailsBar];
  
//  [self.subdetailsBar updateWithPost:self.post];
//  [self.containerView addSubview:self.subdetailsBar];
//  self.subdetailsBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//  self.subdetailsBar.backgroundColor = [UIColor colorForBackgroundAlt];
  
//    BSELF(NCommentPostHeaderCell);
//   UIFont *subdetailFont = [[SkinManager sharedSkinManager] fontForKey:kBundleFontPostSubtitleBold];
//   UIColor *subdetailColor = [UIColor whiteColor];;
//   UIColor *subdetailHighlightedColor = [UIColor lightGrayColor];
//    CGFloat subdetailsBarHeight = [[self class] subdetailsBarHeight];
//    
//    self.subdetailsBar = [[JMViewOverlay alloc] initWithFrame:CGRectMake(0, 0, self.width, subdetailsBarHeight)];
//    self.subdetailsBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.subdetailsBar.drawBlock = ^(BOOL highlighted, BOOL selected, CGRect bounds)
//    {
//        [[UIImage skinImageNamed:@"section/create-post/create-dark-cell-gradient-normal"] drawInRect:bounds];
//    };
//    [self.containerView addOverlay:self.subdetailsBar];
//    
//    self.usernameOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0, 0, 110., subdetailsBarHeight) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
//        UIColor *titleColor = highlighted ? subdetailHighlightedColor : subdetailColor;
//        [titleColor set];
//        [blockSelf.post.author drawInRect:CGRectMake(9., 8., bounds.size.width, 20.) withFont:subdetailFont lineBreakMode:UILineBreakModeTailTruncation];
//    } onTap:^(CGPoint touchPoint) {
//        [[NavigationManager shared] showUserDetails:blockSelf.post.author];
//    }];
//    self.usernameOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self.containerView addOverlay:self.usernameOverlay];
//    
//    CGRect scoreRect = CGRectCenterWithSize(self.subdetailsBar.bounds, CGSizeMake(100., subdetailsBarHeight));
//    self.scoreOverlay = [JMViewOverlay overlayWithFrame:scoreRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
//        [subdetailColor set];
//        CGRect textRect = bounds;
//        textRect.origin.y = 8.;
//        NSString *score = [NSString stringWithFormat:@"%@   •   %@", blockSelf.post.formattedScore, blockSelf.post.timeAgo];
//        [score drawInRect:textRect withFont:subdetailFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
//    } onTap:^(CGPoint touchPoint) {
//    }];
//    self.scoreOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    [self.containerView addOverlay:self.scoreOverlay];
//    
//    
//    CGRect subredditRect = CGRectMake(self.width - 110., 0., 110., subdetailsBarHeight);
//    self.subredditOverlay = [JMViewOverlay overlayWithFrame:subredditRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
//        UIColor *titleColor = highlighted ? subdetailHighlightedColor : subdetailColor;
//        [titleColor set];
//        CGRect textRect = bounds;
//        textRect.origin.y = 8.;
//        textRect.origin.x -= 10.;
//        textRect.size.height = 20.;
//        [blockSelf.post.subreddit drawInRect:textRect withFont:subdetailFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
//    } onTap:^(CGPoint touchPoint) {
//        [[NavigationManager shared] showPostsForSubreddit:blockSelf.post.subreddit title:nil animated:YES];
//    }];
//    self.subredditOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    [self.containerView addOverlay:self.subredditOverlay];

}

- (void)createSubviews;
{
    [super createSubviews];
  
    self.titleBackgroundOverlay = [[JMViewOverlay alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.titleBackgroundOverlay.drawBlock = ^(BOOL highlighted, BOOL selected, CGRect bounds)
    {
//      [[UIColor colorForBackground] set];
//      [[UIBezierPath bezierPathWithRect:bounds] fill]
//        [[UIImage gradientBackground] drawInRect:bounds];
    };
    self.titleBackgroundOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.containerView addOverlay:self.titleBackgroundOverlay];
    
    BSELF(NCommentPostHeaderCell);
    self.thumbOverlay = [[CommentPostHeaderThumbnailOverlay alloc] initWithFrame:CGRectMake(self.width - 50., 10., 50., 50.)];
    self.thumbOverlay.top = 10.;
    self.thumbOverlay.left = self.width - 57;
    self.thumbOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.thumbOverlay.allowTouchPassthrough = NO;
    self.thumbOverlay.allowLocalImageReplacement = YES;
    self.thumbOverlay.onTap = ^(CGPoint touchPoint) {
        NSString *url = [(CommentPostHeaderNode *)blockSelf.node post].url;
        [blockSelf.node.delegate performSelector:@selector(openLinkUrl:) withObject:url];
    };
    [self.containerView addOverlay:self.thumbOverlay];

    self.titleTextOverlay = [[JMViewOverlay alloc] initWithFrame:CGRectMake(13., 10., self.width - self.recommendedTitleMargin, self.height)];
    self.titleTextOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleTextOverlay.drawBlock = ^(BOOL highlighted, BOOL selected, CGRect bounds)
    {
        [UIView startEtchedDraw];
        [[blockSelf.post styledTitleWithDetails] drawInRect:bounds];
        [UIView endEtchedDraw];
    };
    [self.containerView addOverlay:self.titleTextOverlay];
  
    [self createSubdetailBar];
  
//    self.faviconOverlay = [FaviconOverlay new];
//    self.faviconOverlay.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    [self.containerView addOverlay:self.faviconOverlay];
  
    self.imagePreviewOverlay = [[PostImagePreviewOverlay alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.imagePreviewOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.containerView addOverlay:self.imagePreviewOverlay];
  
    self.selfTextDivider = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., self.containerView.width, 1.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
      CGRect dividerRect = CGRectInset(bounds, 8., 0.);
      [[UIColor colorWithWhite:0. alpha:0.05] set];
      [[UIBezierPath bezierPathWithRect:dividerRect] fill];
    }];
    self.selfTextDivider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.containerView addOverlay:self.selfTextDivider];
  
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:^(UISwipeGestureRecognizer *gesture) {
      CGPoint touchPoint = [gesture locationInView:blockSelf.containerView];
      if (!JMIsEmpty(blockSelf.post.selftext) && touchPoint.x > (blockSelf.containerView.width / 2.))
      {
        [blockSelf.node.delegate performSelector:@selector(collapseToRootCommentNode:) withObject:blockSelf.node];
      }
    }];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:leftSwipeGesture];
    self.containerView.alwaysAllowOverlayGestureRecognizers = YES;
  
    self.expandTextOverlay = [JMViewOverlay overlayWithSize:CGSizeMake(self.containerView.bounds.size.width, kCommentPostHeaderCellExpandTextOverlayHeight) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
      NSString *ellipsis = @"⋯";
      [ellipsis jm_drawVerticallyCenteredInRect:bounds withFont:[UIFont boldSystemFontOfSize:25.] color:[UIColor grayColor] horizontalAlignment:NSTextAlignmentCenter];
    }];
    self.expandTextOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.expandTextOverlay.onTap = ^(CGPoint location){
      [blockSelf.node.delegate toggleNode:blockSelf.node];
    };
    [self.containerView addOverlay:self.expandTextOverlay];
}

- (void)updateSubviews;
{
    [super updateSubviews];
    
    CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)self.node;
    
    if (!self.post.needsNSFWWarning)
    {
        [self.thumbOverlay updateWithPost:self.post];
    }
    self.thumbOverlay.showRightArrow = ![self.post.url contains:self.post.permalink];
    
    if (!headerNode.isPlaceholderPost && headerNode.post.linkType == LinkTypePhoto && 
        ([UDefaults boolForKey:kABSettingKeyAutoLoadInlineImageLink] || headerNode.forceImageLoad)
        )
    {
        [self.imagePreviewOverlay updateForNode:(CommentPostHeaderNode *)self.node];
    }
  
    [self.faviconOverlay updateWithUrl:self.post.url];
  
//    [self.subdetailsBar updateWithPost:self.post];
  
//    CommentPostHeaderNode *headerNode = (CommentPostHeaderNode *)self.node;
//    CGFloat titleMargin = headerNode.post.thumbnail ? kTitleMarginWithThumbnail : kTitleMarginNoThumbnail;
    self.selfTextDivider.hidden = [self.post.selftext isEmpty];
    self.expandTextOverlay.hidden = JMIsEmpty(self.post.selftext) || !self.node.collapsed;
    self.thumbOverlay.hidden = !self.post.hasExternalLink;

}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];

    self.subdetailsBar.top = CGRectGetMinY(self.bodyOverlay.frame) - [[self class] subdetailsBarHeight] - [[self class] subdetailsBarBottomMargin] + 1.;
//    self.usernameOverlay.top = self.subdetailsBar.top;
//    self.scoreOverlay.top = self.subdetailsBar.top;
//    self.subredditOverlay.top = self.subdetailsBar.top;
  
    self.titleBackgroundOverlay.height = self.subdetailsBar.top;
    self.titleTextOverlay.width = self.width - self.recommendedTitleMargin;
    self.titleTextOverlay.height = self.titleBackgroundOverlay.height;

    self.faviconOverlay.left = self.titleTextOverlay.left + 1.;
    CGFloat favIconTop = [[self.post styledTitleWithDetails] heightConstrainedToWidth:(self.containerView.size.width - self.recommendedTitleMargin)] - 1.;
    self.faviconOverlay.top = favIconTop;

//    self.faviconOverlay.bottom =   [[self class] heightForCellHeaderForNode:(BaseStyledTextNode *)self.node bounds:self.bounds];
//    self.faviconOverlay.bottom = [[self.post styledTitleWithDetails] heightConstrainedToWidth:self.titleTextOverlay.width];
//    self.faviconOverlay.bottom = self.titleTextOverlay.bottom - 25.;
//    if (self.titleTextOverlay.height <= 70.)
//    {
////      self.faviconOverlay.bottom -= 10;
//    }
  
    self.imagePreviewOverlay.top = CGRectGetMaxY(self.subdetailsBar.frame);
  
    self.selfTextDivider.top = self.subdetailsBar.top - 2.;
  
    self.thumbOverlay.height = self.titleBackgroundOverlay.height - 20.;
  
    self.expandTextOverlay.top = self.selfTextDivider.bottom;
}

@end
