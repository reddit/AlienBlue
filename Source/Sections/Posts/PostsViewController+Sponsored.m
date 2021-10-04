#import "PostsViewController+Sponsored.h"
#import "MoPubCompatibleOutlineView.h"
#import "SponsoredPostCell.h"
#import "Post+Sponsored.h"
#import "RedditAPI+Account.h"
#import "UserSubredditPreferences.h"
#import "ABRemotelyManagedFeatures.h"

#import "MoPub-Bridging-Header.h"
#import "MPNativeAdConstants.h"
#import "MPLogging.h"

#import "Resources.h"

@interface PostsViewController (Sponsored_)
@property (strong) MPTableViewAdPlacer *placer;
@property (readonly) BOOL allowsAdPlacement;
@end

@implementation PostsViewController (Sponsored)

SYNTHESIZE_ASSOCIATED_STRONG(MPTableViewAdPlacer, placer, Placer);

- (void)initializeForSponsoredPostsIfNecessary;
{
  if (!self.allowsAdPlacement)
    return;
  
  self.customTableClass = UNIVERSAL(MoPubCompatibleOutlineView);
}

- (BOOL)isSponsorshipCompatibleDeviceOwner;
{
  if ([RedditAPI shared].isGold)
  {
    return NO;
  }
  
  if ([Resources isPro] && ![ABRemotelyManagedFeatures allowsMoPubForPRO])
  {
    return NO;
  }
  
  return YES;
}

- (BOOL)allowsAdPlacement;
{
  BSELF(PostsViewController);
  BOOL isSponsorShipCompatibleSubreddit = [[ABRemotelyManagedFeatures mopubSubredditWhitelist] match:^BOOL(NSString *whitelistedSubreddit) {
    return [blockSelf.subredditTitle jm_matches:whitelistedSubreddit];
  }] != nil;
  
  BOOL isSponsorShipCompatibleDeviceOwner = [self isSponsorshipCompatibleDeviceOwner];
  BOOL isMopubFeatureEnabledRemotely = [ABRemotelyManagedFeatures isMoPubEnabled];
  
  #ifdef DEBUG
    isSponsorShipCompatibleDeviceOwner = YES;
  #endif

  #ifdef ADHOC
    isSponsorShipCompatibleDeviceOwner = YES;
  #endif
  
  return isSponsorShipCompatibleDeviceOwner && isSponsorShipCompatibleSubreddit && isMopubFeatureEnabledRemotely;
}

- (void)sponsored_viewDidLoad;
{
  if (!self.allowsAdPlacement)
    return;

  MPLogSetLevel(MPLogLevelError);
  
  MPServerAdPositioning *positioning = [MPServerAdPositioning new];
  
  self.placer = [MPTableViewAdPlacer placerWithTableView:self.tableView
                                          viewController:self
                                           adPositioning:positioning
                                 defaultAdRenderingClass:[UNIVERSAL(SponsoredPostCell) class]];
  
  MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
  targeting.desiredAssets = [NSSet setWithObjects:
                             kAdIconImageKey,
                             kAdTextKey,
                             kSponsoredAdCommentThreadFieldKey,
                             kSponsoredAdSubtitleFieldKey,
                             kSponsoredAdRedditIdentifierFieldKey,
                             kSponsoredAdAllowsOptimalViewFieldKey,
                             nil];
  
  NSString *mopubIdentifier = [ABRemotelyManagedFeatures mopubIdentifier];
  DLog(@"using mopub identifier : %@", mopubIdentifier);
  [self.placer loadAdsForAdUnitID:mopubIdentifier targeting:targeting];
}

- (void)sponsored_removeSponsoredAdsIfNecessary;
{
  BOOL currentlyShowingMoPubAds = JMIsClass(self.tableView, MoPubCompatibleOutlineView);
  BOOL needToRemoveAds = currentlyShowingMoPubAds && !self.allowsAdPlacement;
  if (needToRemoveAds)
  {
    [self.placer loadAdsForAdUnitID:nil];
  }
}

- (void)sponsored_respondToStyleChange;
{
  [[self.tableView visibleCells] each:^(JMOutlineCell *cell) {
    SponsoredPostCell *sponsoredCell = JMCastOrNil(cell, SponsoredPostCell);
    [sponsoredCell handleStyleChange];
  }];
}

@end
