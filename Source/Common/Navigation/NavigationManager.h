#import "RedditAPI.h"
#import "PostsNavigation.h"

@class Post;

@interface NavigationManager : NSObject
@property (readonly, nonatomic, strong) PostsNavigation *postsNavigation;
@property (readonly, strong) NSString *lastVisitedSubreddit;
@property (readonly, strong) Post *lastVisitedPost;

- (void)showCommentsForPost:(Post *)npost contextId:(NSString *)contextId fromController:(UIViewController *)fromController;
- (void)showBrowserForPost:(Post *)npost fromController:(UIViewController *)fromController;
- (void)showBrowserForUrl:(NSString *)url fromController:(UIViewController *)fromController;
- (void)showProUpgradeScreen;
- (void)showScreenLockIfNecessary;
- (void)showUserDetails:(NSString *)username;
- (void)showCreatePostScreen;
- (void)showMessagesScreen;
- (void)showSendDirectMessageScreenForUser:(NSString *)username;
- (void)showSettingsScreen;
- (void)showPostsForSubreddit:(NSString *)subreddit title:(NSString *)title animated:(BOOL)animated;
- (void)showFullScreenViewerForGalleryItems:(NSArray *)galleryItems startingAtIndex:(NSUInteger)atIndex;
- (void)showModerationNotifyScreenForPost:(Post *)nPost onModerationMessageSentResponse:(void (^)(id response))onModerationMessageSentResponse;
- (void)showModerationTemplateManagement;
- (void)showEULA;
- (void)handleTapOnUrl:(NSString *)url fromController:(UIViewController *)fromController;

- (void)switchToArticle;
- (void)switchToCommentsWithPost:(Post *)post;
- (void)switchToComments;
- (void)goBackToPreviousScreen;
- (void)showNavigationStack;
- (void)dismissModalView;
- (void)dismissPopoverIfNecessary;

+ (NavigationManager *)shared;
+ (UIViewController *)mainViewController;
+ (UIView *)mainView;

- (void)refreshUserSubreddits;

- (void)votingIconsNeedUpdate;
- (void)interactionIconsNeedUpdate;
- (void)performNightTransitionAnimation;
- (void)purgeMemory;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)userDidTripleTapNavigationBar;

- (void)saveState;
- (void)restoreState;

@end
