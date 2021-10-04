//  REDListingViewController+Sponsored.h
//  RedditApp

#import "RedditApp/Listing/REDListingViewController.h"

@interface REDListingViewController (Sponsored)

- (void)initializeForSponsoredPostsIfNecessary;
- (void)sponsored_viewDidLoad;
- (void)sponsored_respondToStyleChange;
- (void)sponsored_removeSponsoredAdsIfNecessary;

@end
