//  REDListingViewController+State.h
//  RedditApp

#import "RedditApp/Listing/REDListingViewController.h"

@interface REDListingViewController (State)<StatefulControllerProtocol>
- (void)handleRestoringStateAutoscroll;
@end
