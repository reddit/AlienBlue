#import "Post.h"
#import "MPNativeAd.h"

#define kSponsoredAdCommentThreadFieldKey @"comment-thread-url"
#define kSponsoredAdRedditIdentifierFieldKey @"reddit-ad-identifier"
#define kSponsoredAdSubtitleFieldKey @"subtitle"
#define kSponsoredAdAllowsOptimalViewFieldKey @"allows-optimal-view"

@interface Post (Sponsored)

@property (strong, readonly) MPNativeAd *nativeAd;

@property (readonly) NSString *sponsoredPostThreadName;
@property (readonly) BOOL sponsoredPostHasCommentThread;
@property (readonly) BOOL sponsoredPostAllowsOptimalBrowser;
@property (readonly) BOOL sponsoredPostRequiresConversionTracking;

- (void)updateWithNativeAdData:(MPNativeAd *)nativeAd;
- (void)trackSponsoredLinkVisitIfNecessary;
- (void)trackSponsoredCommentsVisitIfNecessary;

@end
