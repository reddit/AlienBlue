#import "SponsoredPostCell.h"
#import "Post+Style.h"
#import <mopub-ios-sdk/MPNativeAdConstants.h>
#import "Post+API.h"
#import "Post+Sponsored.h"
#import "PostsViewController.h"
#import "ABAnalyticsManager.h"

@interface SponsoredPostCell()
@property (strong) Post *i_sponsoredPost;
@property (strong) JMViewOverlay *touchInterceptOverlay;
@end

@implementation SponsoredPostCell

- (Post *)post;
{
  if (!self.i_sponsoredPost)
  {
    self.i_sponsoredPost = [Post new];
  }
  return self.i_sponsoredPost;
}

- (void)createSubviews;
{
  [super createSubviews];
  BSELF(SponsoredPostCell);
  
  self.touchInterceptOverlay = [JMViewOverlay overlayWithFrame:self.containerView.bounds drawBlock:nil onTap:^(CGPoint touchPoint) {
    [blockSelf didTapPostBody];
  }];
  self.touchInterceptOverlay.autoresizingMask = JMFlexibleSizeMask;
  [self.containerView addOverlay:self.touchInterceptOverlay];
  
  self.commentButtonOverlay.onTap = ^(CGPoint tapPoint){
    [blockSelf didTapCommentsButton];
  };

  [self.commentButtonOverlay bringToFront];
  [self.voteOverlay bringToFront];
}

- (void)didTapPostBody;
{
  if (self.post.sponsoredPostRequiresConversionTracking)
  {
    [self.post.nativeAd displayContentWithCompletion:nil];
    [self.post trackSponsoredLinkVisitIfNecessary];
    return;
  }
  
  UITableView *parentTableView = (UITableView *)[self jm_firstParentOfClass:[UITableView class]];
  PostsViewController *controller = (PostsViewController *)parentTableView.delegate;
  [controller showLinkForPost:self.post];
}

- (void)didTapCommentsButton;
{
  UITableView *parentTableView = (UITableView *)[self jm_firstParentOfClass:[UITableView class]];
  PostsViewController *controller = (PostsViewController *)parentTableView.delegate;
  [controller showCommentsForPost:self.post];
}

- (void)updateSubviews;
{
  [super updateSubviews];
  [self.thumbOverlay updateWithUrl:self.post.rawThumbnail fallbackUrl:nil showRetinaVersion:NO];
  self.commentButtonOverlay.hidden = JMIsEmpty(self.post.ident);
  self.sectionDivider.hidden = self.commentButtonOverlay.hidden;
}

- (void)updateWithNativeAdData:(MPNativeAd *)adObject;
{
  [self.post updateWithNativeAdData:adObject];
  [self updateSubviews];
}

- (void)layoutAdAssets:(MPNativeAd *)adObject
{
  self.i_sponsoredPost = nil;
  [self updateWithNativeAdData:adObject];
  [self fetchAdditionalPostDetailsFromIfAvailableWithAdData:adObject];
}

- (void)fetchAdditionalPostDetailsFromIfAvailableWithAdData:(MPNativeAd *)adObject;
{
  NSString *postIdentifer = self.post.sponsoredPostThreadName;
  
  if (JMIsEmpty(postIdentifer))
    return;
  
  BSELF(SponsoredPostCell);
  [Post fetchPostInformationWithName:postIdentifer onComplete:^(Post *postOrNil) {
    if (postOrNil)
    {
      blockSelf.i_sponsoredPost = postOrNil;
      [blockSelf updateWithNativeAdData:adObject];
    }
  }];
}

- (void)handleStyleChange;
{
  [self.post flushCachedStyles];
  [self updateSubviews];
}

+ (CGSize)sizeWithMaximumWidth:(CGFloat)maximumWidth forNativeAd:(MPNativeAd *)adObject;
{
  Post *tPost = [Post new];

  tPost.title = adObject.properties[kAdTextKey];
  tPost.rawThumbnail = adObject.properties[kAdIconImageKey];

  UITableView *tTableView = [UITableView new];
  tTableView.width = maximumWidth;
  JMOutlineNode *tNode = [PostNode nodeForPost:tPost];
  
  CGFloat recommendedHeight = [[self class] heightForNode:tNode tableView:tTableView];

  return CGSizeMake(maximumWidth, recommendedHeight);
}

@end
