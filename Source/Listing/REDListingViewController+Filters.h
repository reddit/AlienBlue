//  REDListingViewController+Filters.h
//  RedditApp

#import "RedditApp/Listing/REDListingViewController.h"
#import "Sections/Posts/Post.h"

@interface REDListingViewController (Filters)

- (BOOL)shouldFilterPost:(Post *)post removeExisting:(BOOL)removeExisting;

@end
