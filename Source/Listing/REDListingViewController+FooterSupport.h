//  REDListingViewController+FooterSupport.h
//  RedditApp

#import "RedditApp/Listing/REDListingViewController.h"
#import "Sections/Posts/NPostCell.h"

@interface REDListingViewController (FooterSupport)

- (void)loadMore;
- (void)hideRead;
- (void)hideAll;

@end
