#import "NPostCell.h"
#import <mopub-ios-sdk/MPNativeAdRendering.h>

@interface SponsoredPostCell : NPostCell  <MPNativeAdRendering>

- (void)handleStyleChange;

@end
