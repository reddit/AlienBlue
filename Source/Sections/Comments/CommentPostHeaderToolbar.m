#import "CommentPostHeaderToolbar.h"

#import "NavigationManager.h"
#import "JMViewOverlay+NavigationButton.h"
#import "UIView+InnerShadow.h"
#import "Resources.h"
#import "ModButtonOverlay.h"
#import "PostModerationControlView.h"

#define kCommentPostHeaderToolbarItemSpacing ([Resources isIPAD] ? 30. : 20.)

@interface CommentPostHeaderToolbar()
@property (strong) OverlayViewContainer *containerView;
@property (strong) JMViewOverlay *subredditLinkOverlay;
@property (strong) JMViewOverlay *authorLinkOverlay;
@property (strong) JMViewOverlay *timeOverlay;
@property (strong) JMViewOverlay *scoreOverlay;
@property (strong) JMViewOverlay *canvasOverlay;

@property (strong) ModButtonOverlay *modButtonOverlay;
@property (strong) PostModerationControlView *modToolsView;

@property (strong) JMViewOverlay *backgroundOverlay;

@property (strong) Post *post;
@end

@implementation CommentPostHeaderToolbar

- (id)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    if (self)
    {
      
      self.containerView = [[OverlayViewContainer alloc] initWithFrame:self.bounds];
      self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      [self addSubview:self.containerView];
    }
    return self;
}

+ (CommentPostHeaderToolbar *)postHeaderToolbar;
{
  CommentPostHeaderToolbar *toolbar = [[UNIVERSAL(CommentPostHeaderToolbar) alloc] initWithFrame:CGRectMake(0., 0., 320., kCommentPostHeaderToolbarHeight)];
  return toolbar;
}

- (void)updateWithPost:(Post *)post;
{
  self.post = post;
  
  BSELF(CommentPostHeaderToolbar);
  [UIView jm_transition:self animations:^{
    [blockSelf updateOverlays];
  } completion:nil animated:YES];
}

- (void)setNeedsDisplay;
{
  [super setNeedsDisplay];
  [self updateOverlays];
}

- (void)updateOverlays;
{
  [self.subredditLinkOverlay removeFromParentView];
  [self.authorLinkOverlay removeFromParentView];
  [self.timeOverlay removeFromParentView];
  [self.scoreOverlay removeFromParentView];
  [self.modButtonOverlay removeFromParentView];
  [self.canvasOverlay removeFromParentView];
  
  Post *post = self.post;
  
  //  NSString *subredditTitle = [post.subreddit convertToSubredditTitle];
  NSString *subredditTitle = [post.subreddit jm_truncateToLength:14];
  NSString *authorTitle = [post.author jm_truncateToLength:12];
  NSString *timeAgoTitle = post.tinyTimeAgo;
  NSString *scoreTitle = post.formattedScoreTiny;
  
  UIFont *titleFont = [UIFont skinFontWithName:([Resources isIPAD] ? kBundleFontCommentHeaderToolbarFontRegular_iPad : kBundleFontCommentHeaderToolbarFontRegular)];
  UIColor *titleColor = JMThemeColor(999999, CCCCCC);
  UIColor *iconColor = [titleColor colorWithAlphaComponent:0.4];
  
  CGFloat authorTitleWidth = [authorTitle widthWithFont:titleFont];
  CGFloat subredditTitleWidth = [subredditTitle widthWithFont:titleFont];
  CGFloat scoreTitleWidth = [scoreTitle widthWithFont:titleFont];
  CGFloat timeAgoTitleWidth = [timeAgoTitle widthWithFont:titleFont];
  CGFloat overlayHeight = 30.;
  CGFloat iconWidth = 20.;
  
  BOOL restrictedWidth = self.bounds.size.width < 400 && (authorTitleWidth + subredditTitleWidth > 130);
  if (restrictedWidth)
  {
    authorTitle = [authorTitle jm_truncateToLength:9];
    subredditTitle = [subredditTitle jm_truncateToLength:9];
    authorTitleWidth = [authorTitle widthWithFont:titleFont];
    subredditTitleWidth = [subredditTitle widthWithFont:titleFont];
  }
  
  self.authorLinkOverlay = [JMViewOverlay overlayWithSize:CGSizeMake(authorTitleWidth, overlayHeight) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    UIColor *authorColor = highlighted ? [UIColor colorForHighlightedText] : titleColor;
    [authorTitle jm_drawVerticallyCenteredInRect:bounds withFont:titleFont color:authorColor horizontalAlignment:NSTextAlignmentLeft];
  }];
  
  self.authorLinkOverlay.onTap = ^(CGPoint touchPoint) {
    [[NavigationManager shared] showUserDetails:post.author];
  };
  [self.containerView addOverlay:self.authorLinkOverlay];
  
  self.subredditLinkOverlay = [JMViewOverlay overlayWithSize:CGSizeMake(subredditTitleWidth, overlayHeight) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    UIColor *subredditColor = highlighted ? [UIColor colorForHighlightedText] : titleColor;
    [subredditTitle jm_drawVerticallyCenteredInRect:bounds withFont:titleFont color:subredditColor horizontalAlignment:NSTextAlignmentLeft];
  }];
  
  self.subredditLinkOverlay.onTap = ^(CGPoint touchPoint) {
    [[NavigationManager shared] showPostsForSubreddit:post.subreddit title:nil animated:YES];
  };
  
  [self.containerView addOverlay:self.subredditLinkOverlay];
  
  
  self.timeOverlay = [JMViewOverlay overlayWithSize:CGSizeMake(timeAgoTitleWidth + iconWidth, overlayHeight) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    [timeAgoTitle jm_drawVerticallyCenteredInRect:bounds withFont:titleFont color:titleColor horizontalAlignment:NSTextAlignmentLeft];
    UIImage *icon = [UIImage skinIcon:@"tiny-time-icon" withColor:iconColor];
    [icon drawAtPoint:CGPointMake(timeAgoTitleWidth - 5., 0.)];
  }];
  [self.containerView addOverlay:self.timeOverlay];
  
  
  self.scoreOverlay = [JMViewOverlay overlayWithSize:CGSizeMake(scoreTitleWidth + iconWidth, overlayHeight) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    [scoreTitle jm_drawVerticallyCenteredInRect:bounds withFont:titleFont color:titleColor horizontalAlignment:NSTextAlignmentLeft];
    UIImage *icon = [UIImage skinIcon:@"tiny-upvote-icon" withColor:iconColor];
    [icon drawAtPoint:CGPointMake(scoreTitleWidth - 5., 0.)];
  }];

//  self.scoreOverlay = [JMViewOverlay tinyButtonWithIcon:@"generated/tiny-upvote-icon" title:scoreTitle];
//  self.scoreOverlay.right = self.timeOverlay.left + 8.;
//  self.scoreOverlay.top = yOffset;
//  self.scoreOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  [self.containerView addOverlay:self.scoreOverlay];
  
  BSELF(CommentPostHeaderToolbar);

  NSString *canvasTitleSuffix = self.post.numberOfImagesInCommentThread > 30 && self.post.numComments > 500 ? @"+" : @"";
  NSString *canvasIconTitle = self.post.numberOfImagesInCommentThread == 0 ? @"-" : [NSString stringWithFormat:@"%d%@", self.post.numberOfImagesInCommentThread, canvasTitleSuffix];
  CGFloat canvasTitleWidth = [canvasIconTitle widthWithFont:titleFont];
  UIColor *canvasOverlayColor = self.shouldHighlightCanvasButton ? [UIColor colorForHighlightedOptions] : iconColor;
  self.canvasOverlay = [JMViewOverlay overlayWithSize:CGSizeMake(canvasTitleWidth + iconWidth, overlayHeight) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    [canvasIconTitle jm_drawVerticallyCenteredInRect:bounds withFont:titleFont color:canvasOverlayColor horizontalAlignment:NSTextAlignmentLeft];
    UIImage *icon = [UIImage skinIcon:@"tiny-canvas-icon" withColor:iconColor];
    [icon drawAtPoint:CGPointMake(canvasTitleWidth - 5., 0.)];
  }];
  self.canvasOverlay.onTap = ^(CGPoint point){
    if (blockSelf.onCanvasButtonTap) blockSelf.onCanvasButtonTap();
  };
  [self.containerView addOverlay:self.canvasOverlay];
  
  self.modButtonOverlay = [[ModButtonOverlay alloc] initAsButton];
  [self.modButtonOverlay updateWithVotableElement:self.post];
  [self.containerView addOverlay:self.modButtonOverlay];
  self.modButtonOverlay.onTap = ^(CGPoint touchPoint){
    [blockSelf didTapModButton];
  };
  self.modButtonOverlay.hidden = !self.post.isModdable;

  // todo: add support for canvas from inside comment threads on iPhone
  self.canvasOverlay.hidden = JMIsIphone() || !self.modButtonOverlay.hidden;
  
  if (restrictedWidth && self.post.isModdable)
  {
    self.timeOverlay.hidden = YES;
    self.scoreOverlay.hidden = YES;
  }
  
  [self horizontallyCenterOverlays];
}

- (void)horizontallyCenterOverlays;
{
  BSELF(CommentPostHeaderToolbar);
  
  __block CGFloat totalContentsWidth = 0.;
  NSArray *allOverlays = @[self.authorLinkOverlay, self.subredditLinkOverlay, self.timeOverlay, self.scoreOverlay, self.modButtonOverlay, self.canvasOverlay];
  [allOverlays each:^(JMViewOverlay *overlay) {
    if (!overlay.hidden)
    {
      totalContentsWidth += overlay.size.width;
      totalContentsWidth += kCommentPostHeaderToolbarItemSpacing;
    }
  }];
  totalContentsWidth -= kCommentPostHeaderToolbarItemSpacing;
  
  CGFloat xAdjustment = (self.bounds.size.width - totalContentsWidth) / 2.;
  __block CGFloat xOffset = xAdjustment;
  [allOverlays each:^(JMViewOverlay *overlay) {
    if (!overlay.hidden)
    {
      overlay.left = xOffset;
      xOffset += overlay.size.width;
      xOffset += kCommentPostHeaderToolbarItemSpacing;
      overlay.top = CGRectCenterWithSize(blockSelf.bounds, overlay.size).origin.y;
    }
  }];
  
  [self.backgroundOverlay removeFromParentView];
  self.backgroundOverlay = [JMViewOverlay overlayWithFrame:self.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    UIColor *bgColor = [UIColor colorForBackground];
    [bgColor set];
    [[UIBezierPath bezierPathWithRect:bounds] fill];
    
    JMViewOverlay *lastVisibleOverlay = [[[allOverlays reverseObjectEnumerator] allObjects] match:^BOOL(JMViewOverlay *obj) {
      return !obj.hidden;
    }];
    [allOverlays each:^(JMViewOverlay *overlay) {
      if (!overlay.hidden && overlay != lastVisibleOverlay)
      {
        CGRect verticalDividerRect = CGRectCenterWithSize(blockSelf.bounds, CGSizeMake(2., 20.));
        verticalDividerRect.origin.x = overlay.right + kCommentPostHeaderToolbarItemSpacing / 2.;
//        CGRect verticalDividerRect = CGRectMake(overlay.right + kCommentPostHeaderToolbarItemSpacing / 2., 0., 2., overlay.height);
//        verticalDividerRect = CGRectInset(verticalDividerRect, 0., 8.);
        [UIView jm_drawVerticalDottedLineInRect:verticalDividerRect lineWidth:0.5 lineColor:[UIColor colorForDottedDivider]];
      }
    }];

  }];
  
  self.backgroundOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.containerView addOverlay:self.backgroundOverlay atIndex:0];
  
}

- (void)layoutSubviews;
{
  [super layoutSubviews];
  [self updateOverlays];
}

- (void)presentModToolsView:(PostModerationControlView *)modToolsView;
{
  BSELF(CommentPostHeaderToolbar);
  modToolsView.alpha = 1.;
  [self addSubview:self.modToolsView];
  [UIView jm_transition:self options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
    blockSelf.containerView.hidden = YES;
  } completion:nil animated:YES];  
}

- (void)dismissModToolsView:(PostModerationControlView *)modToolsView;
{
  BSELF(CommentPostHeaderToolbar);
  self.containerView.hidden = NO;
  [UIView jm_transition:self options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
    [blockSelf.modToolsView removeFromSuperview];
  } completion:^{
    blockSelf.modToolsView = nil;
  } animated:YES];
}

- (void)didTapModButton;
{
  BSELF(CommentPostHeaderToolbar);
  self.modToolsView = [[PostModerationControlView alloc] initWithFrame:self.bounds];
  [self.modToolsView updateWithPost:self.post];
  self.modToolsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.modToolsView.onCancelTap = ^{
    [blockSelf hideModTools];
  };
  self.modToolsView.onModerationStateChange = ^{
    [blockSelf setNeedsDisplay];
  };
  self.modToolsView.onModerationMessageSentResponse = self.onModerationSendMessage;
  [self presentModToolsView:self.modToolsView];
}

- (void)hideModTools;
{
  [self dismissModToolsView:self.modToolsView];
}

@end
