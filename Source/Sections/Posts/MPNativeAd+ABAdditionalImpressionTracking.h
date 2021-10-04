#import "MPNativeAd.h"

@interface MPNativeAd (ABAdditionalImpressionTracking)

- (void)ab_attachAdditionalImpressionTrackerWithAction:(void(^)(NSString *adIdentifier))impressionAction;

@end
