//  REDListingViewController+API.h
//  RedditApp

#import <AFNetworking/AFNetworking.h>

#import "RedditApp/Listing/REDListingViewController.h"

@interface REDListingViewController (API)
@property(strong) AFHTTPRequestOperation *loadPostOperation;
- (NSDictionary *)postRequestOptionsRemoveExisting:(BOOL)removeExisting;
- (void)fetchPostsRemoveExisting:(BOOL)removeExisting
                      onComplete:(void (^)(NSArray *posts))onComplete;
- (NSDictionary *)additionalURLParamsFromHeaderCoordinator;
@end
