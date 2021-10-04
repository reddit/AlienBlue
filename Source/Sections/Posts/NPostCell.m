#import "NPostCell.h"

#import <QuartzCore/QuartzCore.h>

#import "ABButton.h"
#import "ABEventLogger.h"
#import "ABHoverPreviewView.h"
#import "PostOptionsDrawerView.h"
#import "PostsViewController.h"
#import "Post+Style.h"
#import "Resources.h"
#import "ThumbManager.h"
#import "ThumbOverlay.h"
#import "UIColor+Hex.h"
#import "UIImage+Skin.h"
#import "UIView+JMOverlays.h"
#import "VoteOverlay.h"

#define kPostCellTitleMarginWithThumbnail 110.
#define kPostCellTitleMarginWithoutThumbnail 60.
#define kPostCellSubdetailsHeight 19.
#define kPostCellVoteOverlayWidth 34.
#define kPostCellMinimumHeightWithThumbnail 71.
#define kPostCellMinimumHeightWithoutThumbnail 53.
#define kPostCellMinimiumHeightWithVoteIcons 68.

@implementation PostNode

+ (PostNode *)nodeForPost:(Post *)post;
{
    PostNode *node = [[PostNode alloc] init];
    node.post = post;
    return node;
}

+ (Class)cellClass;
{
  return UNIVERSAL(NPostCell);
}

- (void)prefetchThumbnailToCache;
{
    if (!self.post.thumbnail)
        return;
    
    NSString *urlForThumb = [Resources showRetinaThumbnails] ? self.post.url : self.post.rawThumbnail;
    NSString *fallbackUrl = [Resources showRetinaThumbnails] ? self.post.rawThumbnail : nil;

    BSELF(PostNode);
    
    if ([Resources showRetinaThumbnails])
    {
      [[ThumbManager manager] thumbnailForUrl:urlForThumb fallbackUrl:fallbackUrl useFaviconWhenAvailable:NO onComplete:^(UIImage *image){
            [blockSelf refresh];
        }];
    }
    else
    {
        [[ThumbManager manager] resizedImageForUrl:urlForThumb fallbackUrl:fallbackUrl size:[Resources thumbSize] onComplete:^(UIImage *image){
            [blockSelf refresh];
        }];
    }
}

@end

@interface NPostCell()
@end

@implementation NPostCell

+ (CGFloat)titleMarginForPost:(Post *)post;
{
  CGFloat titleMargin = post.thumbnail ? 130 : 70.;

  if ([Resources showPostVotingIcons])
    titleMargin += kPostCellVoteOverlayWidth;
  
  return titleMargin;
}

+ (CGFloat)footerPadding;
{
    return 2.;
}

+ (CGFloat)minimumHeightForPost:(Post *)post;
{
  CGFloat minimumHeight;
  
  if (post.thumbnail)
  {
    minimumHeight = kPostCellMinimumHeightWithThumbnail;
  }
  else if ([Resources showPostVotingIcons])
  {
    minimumHeight = kPostCellMinimiumHeightWithVoteIcons;
  }
  else
  {
    minimumHeight = kPostCellMinimumHeightWithoutThumbnail;
  }
  
  return minimumHeight;
}

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    CGFloat height = 0.;
    height += 36.; // padding
    height += [[self class] footerPadding];
    
    Post *post = [(PostNode *)node post];
    
    CGFloat titleMargin = [[self class] titleMarginForPost:post];
    CGFloat titleHeight = [post titleHeightConstrainedToWidth:tableView.bounds.size.width - titleMargin];
    
    height += titleHeight;

    CGFloat minimumHeight = [[self class] minimumHeightForPost:post];
    
    height = MAX(height, minimumHeight);
    
    if (node.selected)
    {
        height += kABTableCellDrawerHeight;
    }
    
    return height;
}

- (Post *)post
{
    PostNode *postNode = (PostNode *)self.node;
    return postNode.post;
}

- (void)applyGestureRecognizers;
{
    BSELF(NPostCell);
    GestureActionBlock selectAction = ^(UIGestureRecognizer *gesture) {
        if (([gesture isKindOfClass:[UISwipeGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateEnded) ||
            ([gesture isKindOfClass:[UILongPressGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateBegan))
            [blockSelf.node.delegate selectNode:blockSelf.node];
    };
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithActionBlock:selectAction];
    longPressGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *downvoteGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *gesture) {
        [[ABEventLogger shared] logDownvoteChangeForPost:blockSelf.post
                                               container:@"listing"
                                                 gesture:@"tap_3_fingers"];
        [blockSelf.node.delegate performSelector:@selector(voteDownPostNode:) withObject:blockSelf.node];
    }];
    downvoteGesture.numberOfTapsRequired = 1;
    downvoteGesture.numberOfTouchesRequired = 3;
    downvoteGesture.delaysTouchesEnded = NO;
    downvoteGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:downvoteGesture];
  
    UITapGestureRecognizer *upvoteGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *gesture) {
        [[ABEventLogger shared] logUpvoteChangeForPost:blockSelf.post
                                             container:@"listing"
                                               gesture:@"tap_2_fingers"];
        [blockSelf.node.delegate performSelector:@selector(voteUpPostNode:) withObject:blockSelf.node];
    }];
    upvoteGesture.numberOfTapsRequired = 1;
    upvoteGesture.numberOfTouchesRequired = 2;
    upvoteGesture.delaysTouchesEnded = NO;
    upvoteGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:upvoteGesture];
}

+ (UIBezierPath *)bezierPathForBubbleIcon;
{
  CGRect boundaryRect = CGRectMake(0., 0., 36., 26.);
  CGRect bubbleRect = CGRectInset(boundaryRect, 1., 2.);
  bubbleRect = CGRectCropToTop(bubbleRect, 18.);
  UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:bubbleRect cornerRadius:4.];
  return bezierPath;
}

+ (UIImage *)imageForCommentBubble;
{
  NSString *cacheKey = [NSString stringWithFormat:@"decorated-bubble-%d", [Resources isNight]];
  
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    
    UIBezierPath *path = [NPostCell bezierPathForBubbleIcon];
    UIColor *strokeColor = JMIsNight() ? [UIColor colorWithWhite:0.5 alpha:0.6] : [UIColor lightGrayColor];
      [[UIColor colorForBackground] setFill];
      [path fill];
      
      [strokeColor setStroke];
      [path setLineWidth:0.25];
      [path stroke];
  } opaque:NO withSize:CGSizeMake(36., 26.) cacheKey:cacheKey];
}

- (void)createSubviews;
{    
    CGRect bounds = self.containerView.bounds;

    BSELF(NPostCell);
    self.cellBackgroundColor = [UIColor colorForBackground];
  
    self.sectionDivider = [JMViewOverlay overlayWithFrame:CGRectMake(0., 6., 2., 42.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
      UIColor *dividerColor = [UIColor colorForDottedDivider];
      [UIView jm_drawVerticalDottedLineInRect:bounds lineWidth:0.5 lineColor:dividerColor];
    }];
    [self.containerView addOverlay:self.sectionDivider];
  
    self.modButtonOverlay = [[ModButtonOverlay alloc] initAsIndicatorOnly];
    self.modButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.containerView addOverlay:self.modButtonOverlay];

  
    self.commentButtonOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(bounds.size.width - 52., 0., 50., bounds.size.height)
                                                                drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds)
    {
      
        if (highlighted)
        {
          CGFloat whiteLevel = JMIsNight() ? 1. : 0.;
          [[UIColor colorWithWhite:whiteLevel alpha:0.025] set];
          [[UIBezierPath bezierPathWithRect:bounds] fill];
        }

      
        UIImage *commentBubbleImage = [NPostCell imageForCommentBubble];
        CGRect bubbleRect = CGRectCenterWithSize(bounds, commentBubbleImage.size);
        bubbleRect.origin.y = 23;
        [commentBubbleImage drawAtPoint:bubbleRect.origin];
      
        CGRect commentCountRect = CGRectOffset(bubbleRect, 0., 4.);
        [blockSelf.post drawCommentCountInRect:commentCountRect context:UIGraphicsGetCurrentContext()];
      
        UIColor *subdetailsColor = nil;
        if (blockSelf.post.voteState == VoteStateUpvoted)
        {
          subdetailsColor = [UIColor colorForUpvote];
        }
        else if (blockSelf.post.voteState == VoteStateDownvoted)
        {
          subdetailsColor = [UIColor colorForDownvote];
        }
        else
        {
          subdetailsColor = JMHexColor(a8a8a8);
        }
      
        CGRect subdetailsRect = CGRectCenterWithSize(bounds, CGSizeMake(46., 12.));
        subdetailsRect.origin.y = 9;
        NSString *scoreStr = [NSString shortFormattedStringFromNumber:blockSelf.post.score];
        NSString *dateStr = blockSelf.post.tinyTimeAgo;
        NSString *subdetails = [NSString stringWithFormat:@"%@ • %@", scoreStr, dateStr];
        if (subdetails.length <= 7)
        {
          // we have room to include a decimal on the karma
          subdetails = [NSString stringWithFormat:@"%@ • %@", [NSString shortFormattedStringFromNumber:blockSelf.post.score shouldDecimilaze:YES], dateStr];
        }
      
        [subdetailsColor set];
        [UIView jm_drawShadowed:^{
          [subdetails drawInRect:subdetailsRect withFont:[UIFont skinFontWithName:kBundleFontPostTinySubdetails] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
        } shadowColor:[UIColor colorForInsetDropShadow]];
      
      
    } onTap:^(CGPoint touchPoint){
        [blockSelf.node.delegate performSelector:@selector(showCommentsForPost:) withObject:blockSelf.post];
    }];
    self.commentButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.commentButtonOverlay.allowTouchPassthrough = NO;
    [self.containerView addOverlay:self.commentButtonOverlay];
    
    self.voteOverlay = [[VoteOverlay alloc] init];
    [self.containerView addOverlay:self.voteOverlay];

    self.thumbOverlay = [[ThumbOverlay alloc] initWithFrame:CGRectZero];
    self.thumbOverlay.size = [Resources thumbSize];
    self.thumbOverlay.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.containerView addOverlay:self.thumbOverlay];
    
    self.thumbOverlay.onPress = ^(CGPoint touchPoint){
      [blockSelf didPressDownOnThumbOverlay];
    };
    self.thumbOverlay.onTap = ^(CGPoint touchPoint)
    {
      [blockSelf didTapOnThumbOverlay];
    };
    self.thumbOverlay.allowTouchPassthrough = NO;

    [self.containerView addOverlay:self.thumbOverlay];
    
    self.titleOverlay = [JMViewOverlay overlayWithFrame:CGRectZero drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [UIView startEtchedDraw];
        [blockSelf.post drawTitleCenteredVerticallyInRect:bounds context:UIGraphicsGetCurrentContext()];
        [UIView endEtchedDraw];
    }];
    [self.containerView addOverlay:self.titleOverlay];
  
    self.subdetailsOverlay = [JMViewOverlay overlayWithFrame:CGRectZero drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
      [UIView startEtchedDraw];
      [blockSelf.post drawSubdetailsInRect:bounds context:UIGraphicsGetCurrentContext()];
      [UIView endEtchedDraw];
    }];
    [self.containerView addOverlay:self.subdetailsOverlay];
  
    self.linkFlairOverlay = [[JMViewOverlay alloc] initWithFrame:CGRectMake(20., 20., 40., 17.)];
    self.linkFlairOverlay.drawBlock = ^(BOOL highlighted, BOOL selected, CGRect b) {
      UIImage *ribbonImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
        [UIView startEtchedDraw];
        [blockSelf.post.linkFlairBackgroundColorForPresentation set];
        [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 2., 2.) cornerRadius:6.] fill];
        [UIView endEtchedDraw];
        [[UIColor whiteColor] set];
        CGRect titleRect = CGRectOffset(bounds, 0., 3.);
        [blockSelf.post.linkFlairTextForPresentation drawInRect:titleRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:8.] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
      } opaque:NO withSize:CGSizeMake(b.size.width, b.size.height) cacheKey:nil];
      [ribbonImage drawAtPoint:CGPointZero];
    };
    [self.containerView addOverlay:self.linkFlairOverlay];
  
    [self applyGestureRecognizers];
}

- (CGRect)rectForTitle
{
    CGRect bounds = self.containerView.bounds;
    
    if (self.node.selected)
        bounds.size.height -= kABTableCellDrawerHeight;
    
    CGFloat titleMargin = [[self class] titleMarginForPost:self.post];
    CGFloat titleVerticalMargin = 34.;
    CGRect titleRect;
    
    if (self.post.thumbnail)
        titleRect = CGRectMake(71., 10., bounds.size.width - titleMargin, bounds.size.height - titleVerticalMargin);
    else
        titleRect = CGRectMake(11., 10., bounds.size.width - titleMargin, bounds.size.height - titleVerticalMargin);
    
    if ([Resources showPostVotingIcons])
    {
        titleRect = CGRectOffset(titleRect, kPostCellVoteOverlayWidth - 6., 0); 
    }
    
    CGFloat titleHeight = [self.post titleHeightConstrainedToWidth:titleRect.size.width];
    titleRect.size.height = titleHeight;
    titleRect.origin.y = 8.;
  
    return titleRect;
}

- (void)didTapOnThumbOverlay;
{
  if ([ABHoverPreviewView hasRecentlyDismissedPreview])
    return;
  
  [ABHoverPreviewView cancelVisiblePreviewAnimated:NO];
  PostsViewController *postsController = (PostsViewController *)self.node.delegate;
  [postsController mimicTapOnCellForPostNode:(PostNode *)self.node];
}

- (void)didPressDownOnThumbOverlay;
{
  NSURL *URLToPreview = [self.post.url URL];
  
  if (![ABHoverPreviewView canShowPreviewForURL:URLToPreview])
    return;
  
  CGRect thumbFrame = self.thumbOverlay.frame;
  CGRect globalRect = [self.thumbOverlay.parentView convertRect:thumbFrame toView:[UIApplication sharedApplication].keyWindow];
  BSELF(NPostCell);
  [ABHoverPreviewView showPreviewForURL:URLToPreview fromRect:globalRect onSuccessfulPresentation:^{
    [blockSelf.post markVisited];
  }];
}

// subclass
- (void)updateSubviews;
{    
    self.linkFlairOverlay.hidden = JMIsEmpty(self.post.linkFlairTextForPresentation);

    [self.voteOverlay updateWithVotableElement:self.post];
  
    self.thumbOverlay.hidden = (self.post.thumbnail == nil);
    if (!self.thumbOverlay.hidden)
    {
        [self.thumbOverlay updateWithPost:self.post];
    }
  
    [self.modButtonOverlay updateWithVotableElement:self.post];

    BSELF(NPostCell);
    [UIView jm_excludeFromAnimation:^{
      [blockSelf attachPostDrawerIfNecessary];
    }];
}

- (void)attachPostDrawerIfNecessary;
{
  [self.drawerView removeFromSuperview];
  if (self.node.selected)
  {
    self.drawerView = [[PostOptionsDrawerView alloc] initWithNode:self.node];
    self.drawerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.drawerView.delegate = self.node.delegate;
    [self.containerView addSubview:self.drawerView];
  }
  else
  {
    self.drawerView = nil;
  }
  [self layoutCellOverlays];
}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];

    self.voteOverlay.hidden = ![Resources showPostVotingIcons];

    CGRect detailBounds = self.containerView.bounds;
    if (self.node.selected)
    {
        detailBounds.size.height -= kABTableCellDrawerHeight;
    }
    
    self.voteOverlay.left = -7.;
    self.voteOverlay.top = 4.;    

    CGRect titleRect = [self rectForTitle];
    self.titleOverlay.frame = titleRect;

    // On particular font-sizes titles can be cropped
    self.titleOverlay.height += 4.;

    self.thumbOverlay.left = [Resources showPostVotingIcons] ? kPostCellVoteOverlayWidth : 6.;
    self.thumbOverlay.left += 5.;
    self.thumbOverlay.top = 11.;
    
    CGRect subdetailsRect = CGRectMake(self.titleOverlay.left - 7., CGRectGetMaxY(self.titleOverlay.frame), self.titleOverlay.width, 20.);
    self.subdetailsOverlay.frame = subdetailsRect;

    self.drawerView.top = self.containerView.height - kABTableCellDrawerHeight;
    self.drawerView.width = self.containerView.width;
  
    self.sectionDivider.right = self.containerView.width - 52.;
  
    CGRect modOverlayRect = CGRectCenterWithSize(self.sectionDivider.frame, self.modButtonOverlay.size);
    self.modButtonOverlay.top = modOverlayRect.origin.y;
    self.modButtonOverlay.left = modOverlayRect.origin.x;
    self.modButtonOverlay.left -= 1.;
  
    self.linkFlairOverlay.width = [self.post.linkFlairTextForPresentation jm_sizeWithFont:[UIFont boldSystemFontOfSize:8.]].width + 15.;
  
  
  // center title and subdetails that show alongside big
  // thumbnails, otherwise it leaves an odd blank space
  // underneath
  if (self.subdetailsOverlay.bottom < self.thumbOverlay.bottom && !self.thumbOverlay.hidden)
  {
    CGFloat delta = self.thumbOverlay.bottom - self.subdetailsOverlay.bottom;
    CGFloat centerOffset = (delta / 2.) + 2.;
    self.subdetailsOverlay.top += centerOffset;
    self.titleOverlay.top += centerOffset;
  }
  
  if (!self.linkFlairOverlay.hidden)
  {
    self.linkFlairOverlay.left = self.subdetailsOverlay.left + 4.;
    self.linkFlairOverlay.top = self.subdetailsOverlay.top;
    self.subdetailsOverlay.left = self.linkFlairOverlay.right;
  }
  
}

- (NSString *)accessibilityLabel;
{
  return self.post.title;
}

- (void)decorateCellBackground;
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  [[UIColor colorForBackground] set];
  CGContextFillRect(context, self.bounds);
  
  if (!self.highlighted)
  {
    CGRect dottedLineRect = CGRectInset(CGRectCropToBottom(self.bounds, 1.), 10., 0.);
    [UIView jm_drawHorizontalDottedLineInRect:dottedLineRect lineWidth:0.5 lineColor:JMHexColorA(555555, 0.1)];
  }
  
  if (self.highlighted || self.node.selected)
  {
    UIColor *bgColor = [Resources isNight] ? [UIColor colorWithWhite:0. alpha:0.08] : [UIColor colorWithWhite:0. alpha:0.02];
    [bgColor set];
    CGContextFillRect(context, self.bounds);
  }
}

@end
