//  REDListingViewController+PostInteraction.h
//  RedditApp

#import "RedditApp/Listing/REDListingViewController.h"
#import "Sections/Posts/NPostCell.h"

@interface REDListingViewController (PostInteraction)
- (void)toggleSavePostNode:(PostNode *)postNode;
- (void)toggleHidePostNode:(PostNode *)postNode;
- (void)voteUpPostNode:(PostNode *)postNode;
- (void)voteDownPostNode:(PostNode *)postNode;
- (void)reportPostNode:(PostNode *)postNode;
@end
