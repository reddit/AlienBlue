#import "Post+Sponsored.h"
#import "MPNativeAd+ABAdditionalImpressionTracking.h"
#import "MPNativeAdConstants.h"

@interface Post (Sponsored_)
@property (strong) MPNativeAd *nativeAd;
@end

@implementation Post (Sponsored)

SYNTHESIZE_ASSOCIATED_STRONG(MPNativeAd, nativeAd, NativeAd);

- (void)updateWithNativeAdData:(MPNativeAd *)nativeAd;
{
  self.nativeAd = nativeAd;
  self.promoted = YES;
  self.selfPost = NO;
  self.url = [nativeAd.defaultActionURL absoluteString];
  self.title = nativeAd.properties[kAdTextKey];
  self.subreddit = nativeAd.properties[kSponsoredAdSubtitleFieldKey];
  self.rawThumbnail = nativeAd.properties[kAdIconImageKey];
  self.author = nil;
  self.domain = nil;
  [nativeAd ab_attachAdditionalImpressionTrackerWithAction:^(NSString *adIdentifier) {
    [ABAnalyticsManager trackEventWithCategory:kABAnalyticsCategoryAdvertorial action:@"List Impression" label:adIdentifier];
  }];
}

- (void)trackSponsoredLinkVisitIfNecessary;
{
  if (!self.nativeAd)
    return;

  [self.nativeAd trackClick]; // ignores subsequent calls
  [ABAnalyticsManager trackEventWithCategory:kABAnalyticsCategoryAdvertorial action:@"Visit Link" label:self.nativeAd.properties[kSponsoredAdRedditIdentifierFieldKey]];
}

- (void)trackSponsoredCommentsVisitIfNecessary;
{
  if (!self.nativeAd)
    return;

  [ABAnalyticsManager trackEventWithCategory:kABAnalyticsCategoryAdvertorial action:@"Visit Comments" label:self.nativeAd.properties[kSponsoredAdRedditIdentifierFieldKey]];
}

- (NSString *)sponsoredPostThreadName;
{
  NSString *threadUrl = self.nativeAd.properties[kSponsoredAdCommentThreadFieldKey];

  if (JMIsEmpty(threadUrl))
  {
    return nil;
  }
  
  NSString *postIdent = [threadUrl extractRedditPostIdent];
  
  if (JMIsEmpty(postIdent))
  {
    return nil;
  }
  
  NSString *postName = [NSString stringWithFormat:@"t3_%@", postIdent];
  return postName;
}

- (BOOL)sponsoredPostHasCommentThread;
{
  return !JMIsEmpty(self.sponsoredPostThreadName);
}

- (BOOL)sponsoredPostAllowsOptimalBrowser
{
  NSString *optimalFieldValue = self.nativeAd.properties[kSponsoredAdAllowsOptimalViewFieldKey];

  if (JMIsEmpty(optimalFieldValue))
    return NO;
  
  return [optimalFieldValue jm_contains:@"yes"] || [optimalFieldValue jm_contains:@"true"] || [optimalFieldValue jm_contains:@"1"];
}

- (BOOL)sponsoredPostRequiresConversionTracking;
{
  return [self.url jm_contains:@"itunes.apple.com"] || [self.url jm_contains:@"phobos.apple.com"];
}

@end
