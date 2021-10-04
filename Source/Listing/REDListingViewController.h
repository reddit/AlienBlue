//  REDListingViewController.h
//  RedditApp

#import "Common/Views/ABOutlineViewController.h"
#import "RedditApp/Listing/REDListingFooterCoordinator.h"
#import "RedditApp/Listing/REDListingHeaderCoordinator.h"
#import "Sections/Posts/Post.h"

#define kPostTableHeaderOffsetWithoutActionMenu 44.
#define kPostTableHeaderOffsetWithActionMenu 0.

@class PostNode;

@interface REDListingViewController
    : ABOutlineViewController<REDPostsHeaderDelegate, REDPostsFooterDelegate>
@property(strong, readonly) NSString *subreddit;
@property(strong, readonly) NSString *subredditTitle;

@property(readonly, strong) REDListingHeaderCoordinator *headerCoordinator;
@property(readonly, strong) REDListingFooterCoordinator *footerCoordinator;

- (id)initWithSubreddit:(NSString *)subreddit title:(NSString *)title;
- (void)fetchPostsRemoveExisting:(BOOL)removeExisting;
- (void)clearAndRefreshFromSettingsLogin;
- (void)hideTitle;

- (void)showLinkForPost:(Post *)post;
- (void)showCommentsForPost:(Post *)post;
- (void)respondToStyleChange;

- (void)triggeredWithForce:(BOOL)force;
- (void)postsDidFinishLoading;

- (void)mimicTapOnCellForPostNode:(PostNode *)postNode;

@end
