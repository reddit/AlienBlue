#import "MPNativeAd+ABAdditionalImpressionTracking.h"
#import "Post+Sponsored.h"

@interface MPNativeAd (Internal)
@property (nonatomic, assign) BOOL hasTrackedImpression;
@end

@interface MPNativeAd (ABAdditionalImpressionTracking_)
@property BOOL ab_hasAdditionalImpressionTrackerAttached;
- (void)ab_attachAdditionalImpressionTrackerWithAction:(void(^)(NSString *adIdentifier))impressionAction;
@end

@implementation MPNativeAd (ABAdditionalImpressionTracking)
SYNTHESIZE_ASSOCIATED_BOOL(ab_hasAdditionalImpressionTrackerAttached, Ab_hasAdditionalImpressionTrackerAttached);

- (void)ab_attachAdditionalImpressionTrackerWithAction:(void(^)(NSString *adIdentifier))impressionAction;
{
  if (self.ab_hasAdditionalImpressionTrackerAttached)
    return;
  
  NSString *adIdentifier = self.properties[kSponsoredAdRedditIdentifierFieldKey];

  BSELF(MPNativeAd);
  [self jm_observeSelector:@selector(trackImpression) doBefore:^{
    if (!blockSelf.hasTrackedImpression && impressionAction)
    {
      impressionAction(adIdentifier);
    }
  }];
  self.ab_hasAdditionalImpressionTrackerAttached = YES;
}

@end
