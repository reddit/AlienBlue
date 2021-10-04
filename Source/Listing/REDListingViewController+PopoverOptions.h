//  REDListingViewController+PopoverOptions.h
//  RedditApp

#import "RedditApp/Listing/REDListingViewController.h"

@interface REDListingViewController (PopoverOptions)

@property(readonly) BOOL isSubscribedToSubreddit;
@property(readonly) BOOL isNativeSubreddit;

- (void)popupSubredditOptions;
- (void)showAddSubredditToGroup;
- (void)showSidebar;
- (void)showMessageModsScreen;
- (void)showGallery;
@end
