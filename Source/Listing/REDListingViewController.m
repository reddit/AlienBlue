//  REDListingViewController.m
//  RedditApp

#import "RedditApp/Listing/REDListingViewController.h"

#import <BlocksKit/UIAlertView+BlocksKit.h>

#import "Common/Additions/NSString+ABLegacyLinkTypes.h"
#import "Common/AppDelegate/AlienBlueAppDelegate.h"
#import "Common/Navigation/NavigationManager+Deprecated.h"
#import "Common/Views/TransparentToolbar.h"
#import "Helpers/RedditAPI+Account.h"
#import "Helpers/RedditAPI+Posts.h"
#import "Helpers/Resources.h"
#import "Helpers/SessionManager+Authentication.h"
#import "Helpers/ThumbManager.h"
#import "RedditApp/Detail/REDDetailViewController.h"
#import "RedditApp/Listing/REDListingViewController+API.h"
#import "RedditApp/Listing/REDListingViewController+CanvasSupport.h"
#import "RedditApp/Listing/REDListingViewController+Filters.h"
#import "RedditApp/Listing/REDListingViewController+FooterSupport.h"
#import "RedditApp/Listing/REDListingViewController+PopoverOptions.h"
#import "RedditApp/Listing/REDListingViewController+Sponsored.h"
#import "RedditApp/Listing/REDListingViewController+State.h"
#import "Sections/Comments/NCenteredTextCell.h"
#import "Sections/Posts/NPostCell.h"
#import "Sections/Posts/Post+API.h"
#import "Sections/Posts/Post+Style.h"
#import "Sections/Reddits/Subreddit+Moderation.h"
#import "useful-bits/UsefulBits/Source/NSArray+Blocks.h"

#define kREDListingViewControllerTrainingExposeModButtonPrefKey \
  @"kREDListingViewControllerTrainingExposeModButtonPrefKey-E"

@interface REDListingViewController ()
@property(strong) NSString *subreddit;
@property(strong) NSString *subredditTitle;
@property(strong) REDListingHeaderCoordinator *headerCoordinator;
@property(strong) REDListingFooterCoordinator *footerCoordinator;
@property BOOL didCheckPostsForModability;
- (void)fetchPostsRemoveExisting:(BOOL)removeExisting;
- (void)updateNavbarTitle;
@property BOOL isLoadingPosts;
@property(readonly) CGFloat recommendedPostTableHeaderOffset;
@property(assign) BOOL titleIsHidden;
@end

@implementation REDListingViewController

- (id)initWithSubreddit:(NSString *)subreddit title:(NSString *)title;
{
  if ((self = [super init])) {
    self.loadPostOperation = nil;

    BSELF(REDListingViewController);
    self.subreddit = subreddit;

    if (title)
      self.subredditTitle = title;
    else
      self.subredditTitle = [subreddit convertToSubredditTitle];

    self.headerCoordinator = [[REDListingHeaderCoordinator alloc]
        initWithDelegate:self
                onChange:^{ [blockSelf fetchPostsRemoveExisting:YES]; }];
    self.footerCoordinator = [[REDListingFooterCoordinator alloc] initWithDelegate:self];

    self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
    [self updateNavbarTitle];

    [self initializeForSponsoredPostsIfNecessary];
  }
  return self;
}

- (void)respondToStyleChange;
{
  [super respondToStyleChange];
  [self.nodes each:^(PostNode *node) {
      if ([node isKindOfClass:[PostNode class]]) {
        [node.post flushCachedStyles];
      }
  }];

  [self reload];

  self.tableView.backgroundColor = [UIColor colorForBackground];
  self.pullRefreshView.backgroundColor = [UIColor colorForBackground];
  [self.pullRefreshView setForegroundColor:[UIColor colorForPullToRefreshForeground]];
  [self updateNavbarIcons];

  [self sponsored_respondToStyleChange];
}

- (CGFloat)recommendedPostTableHeaderOffset;
{
  return [Resources useActionMenu] ? kPostTableHeaderOffsetWithActionMenu
                                   : kPostTableHeaderOffsetWithoutActionMenu;
}

- (void)loadView;
{
  [super loadView];

  self.tableView.tableHeaderView = nil;
  self.tableView.tableHeaderView = self.headerCoordinator.view;
  self.tableView.tableFooterView = nil;
  self.tableView.tableFooterView = self.footerCoordinator.view;

  BSELF(REDListingViewController);
  self.pullRefreshView = [JMRefreshHeaderView
      hookRefreshHeaderToController:self
                          onTrigger:^{ [blockSelf fetchPostsRemoveExisting:YES]; }];

  self.pullRefreshView.defaultScrollOffset = self.recommendedPostTableHeaderOffset;

  if (self.savedScrollPosition.y <= 0) {
    // hide the sort options out of the way when the user first lands on this screen
    self.savedScrollPosition = CGPointMake(0, self.recommendedPostTableHeaderOffset);
  }

  [self respondToStyleChange];
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
  [self updateNavbarIcons];
  [self sponsored_viewDidLoad];
}

- (void)triggeredWithForce:(BOOL)force;
{ DLog(@"triggered"); }

//- (void)forceUnloadTest;
//{
//    SEL theSelector = NSSelectorFromString(@"unloadViewForced:");
////    SEL theSelector = NSSelectorFromString(@"triggeredWithForce:");
//    NSInvocation *anInvocation = [NSInvocation
//                                  invocationWithMethodSignature:
//                                  [REDListingViewController
//                                  instanceMethodSignatureForSelector:theSelector]];
//
//    [anInvocation setSelector:theSelector];
//    [anInvocation setTarget:self];
//    BOOL forced = YES;
//    [anInvocation setArgument:&forced atIndex:2];
//    [anInvocation performSelector:@selector(invoke) withObject:nil afterDelay:8];
//}

//#ifdef DEBUG
//
//- (void)unloadViewForced:(BOOL)forced;
//{
//    DLog(@"unload view forced in: %d", forced);
//}
//
//#endif

- (void)fetchPostsKeepingExisting;
{ [self fetchPostsRemoveExisting:NO]; }

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  if ([self.nodes count] <= 3) {
    [self.footerCoordinator setShowLoadingIndicator:YES];
    BSELF(REDListingViewController);
    [[SessionManager manager]
        doAfterAuthenticationProcessIsComplete:^{ [blockSelf fetchPostsKeepingExisting]; }];
  }
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
  [self notifyCanvasViewWillAppearAnimated:animated];
  if ([self nodeCount] > 5) {
    [self reloadVisibleRows];
  }
  if (![Resources isIPAD] && ![Resources useActionMenu]) {
    // pushing from a screen like Discovery could have hidden the toolbar
    [self.navigationController setToolbarHidden:[NavigationManager shared].deprecated_isFullscreen
                                       animated:animated];
  }
}

- (void)viewWillDisappear:(BOOL)animated;
{
  [self notifyCanvasViewWillDisappearAnimated:animated];
  [super viewWillDisappear:animated];
}

- (void)dealloc;
{
  self.headerCoordinator.delegate = nil;
  self.footerCoordinator.delegate = nil;
}

- (void)viewDidUnload;
{
  [self.loadPostOperation cancel];
  self.loadPostOperation = nil;

  [self notifyCanvasViewDidUnload];

  [super viewDidUnload];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  [self notifyCanvasViewDidRotate:fromInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
  return [[NavigationManager shared] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)fetchPostsRemoveExisting:(BOOL)removeExisting;
{
  BSELF(REDListingViewController);
  if (self.isLoadingPosts) return;

  NSString *analyticsAction = (self.nodeCount < 3) ? @"Loading First Page" : @"Loading More";
  [ABAnalyticsManager trackEventWithCategory:@"Posts"
                                      action:analyticsAction
                                       label:self.subredditTitle];

  self.isLoadingPosts = YES;

  __block __ab_weak REDListingViewController *weakSelf = self;

  if (!blockSelf.footerCoordinator.isShowingLoadingIndicator) {
    [blockSelf.footerCoordinator setShowLoadingIndicator:YES];
  }

  typedef void (^ProcessPostsAction)(NSArray * posts);

  ProcessPostsAction processAction = ^(NSArray *posts) {
      [blockSelf deselectNodes];
      [blockSelf.footerCoordinator setShowLoadingIndicator:NO];
      [blockSelf.pullRefreshView finishedLoading];
      if (removeExisting) {
        [blockSelf removeAllNodes];
      }

      NSUInteger prerenderThreshold = (blockSelf.nodeCount == 0) ? 3 : 1;

      [posts eachWithIndex:^(id post, NSUInteger postIndex) {
          PostNode *node = [PostNode nodeForPost:post];
          [blockSelf addNode:node];
          if (postIndex > prerenderThreshold) {
            // we dont do this for the first four, because they might be onscreen
            // and prefetching while drawing at the same time can cause the
            // thumbnail not to appear at all
            [node prefetchThumbnailToCache];
          }
      }];

      if (blockSelf.nodeCount == 0) {
        // remind users that they may need to enable 18+ in their
        // user prefs
        if ([blockSelf.subreddit contains:@"nsfw"] || [blockSelf.subreddit contains:@"gonewild"] ||
            [blockSelf.subreddit contains:@"wtf"]) {
          CenteredTextNode *textNode =
              [CenteredTextNode nodeWithTitle:@"Why is there nothing here?"];
          textNode.onSelect = ^{
              UIAlertView *alert =
                  [UIAlertView bk_alertViewWithTitle:@""
                                             message:@"If this is an 18+ subreddit, you will need "
                                             @"to enable the 'i am over eighteen years "
                                             @"old' setting in your reddit preferences"];
              [alert bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
              [alert bk_addButtonWithTitle:@"Open Prefs"
                                   handler:^{
                                       NSString *url = @"https://ssl.reddit.com/prefs/";
                                       [[UIApplication sharedApplication]
                                           openURL:[NSURL URLWithString:url]];
                                   }];
              [alert show];
          };
          [blockSelf addNode:textNode];
        }
        // if posts are nil (subreddit is banned or non-existent),
        // show a "not found" message
        else {
          CenteredTextNode *textNode =
              [CenteredTextNode nodeWithTitle:@"Looks like there's nothing to see here"];
          [blockSelf addNode:textNode];
        }
      }

      //        TODO: This was interfering with auto-scroll
      //        nothing here response (last_post_id was too stale)
      if (blockSelf.nodeCount > 20 && posts.count == 0 &&
          [blockSelf.headerCoordinator.sortOrder isEmpty]) {
        NSString *sr = blockSelf.subreddit;
        if ([sr contains:@"/r/"] || [sr isEmpty]) {
          BOOL alreadyExists = [blockSelf.nodes
              any:^BOOL(id node) { return [node isKindOfClass:[CenteredTextNode class]]; }];
          if (!alreadyExists) {
            CenteredTextNode *refreshNode =
                [CenteredTextNode nodeWithTitle:@"Nothing more here. Want fresh posts?"];
            refreshNode.onSelect = ^{
                [PromptManager showMomentaryHudWithMessage:@"Loading fresh posts"];
                [weakSelf fetchPostsRemoveExisting:YES];
            };
            [blockSelf addNode:refreshNode];
          }
        }
      }

      [blockSelf reload];

      if (removeExisting && blockSelf.tableView.contentOffset.y > 50.) {
        [blockSelf.tableView
            scrollRectToVisible:CGRectMake(0., blockSelf.recommendedPostTableHeaderOffset, 1., 1.)
                       animated:YES];
      } else {
        [blockSelf handleRestoringStateAutoscroll];
      }

      [blockSelf postsDidFinishLoading];
  };

  [self fetchPostsRemoveExisting:removeExisting onComplete:processAction];
}

- (void)showCommentsForPost:(Post *)post;
{
  if (post.deleted) return;

  [post markVisited];
  [[NavigationManager shared] showCommentsForPost:post contextId:nil fromController:self];
}

- (void)showLinkForPost:(Post *)post;
{
  if (post.deleted) return;

  if (JMIsEmpty(post.url)) return;

#if !ALIEN_BLUE
  REDDetailViewController *detailViewController =
      [[REDDetailViewController alloc] initWithPost:post];
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:detailViewController];
  navigationController.navigationBarHidden = YES;
  [self presentViewController:navigationController animated:YES completion:nil];
  return;
#endif

  NSString *extractedSubreddit = [post.url extractSubredditLink];

  NSString *parsedPostID = [post.url extractRedditPostIdent];
  [post markVisited];

  if (!JMIsEmpty(post.domain) && [NSString ab_isSelfLink:post.domain]) {
    [[NavigationManager shared] showCommentsForPost:post contextId:nil fromController:self];
  } else if (!JMIsEmpty(parsedPostID)) {
    NSMutableDictionary *npost = [[NSMutableDictionary alloc] init];
    [npost setValue:parsedPostID forKey:@"id"];
    [npost setValue:@"" forKey:@"type"];
    [npost setValue:@"self.reddit" forKey:@"url"];
    NSString *commentID = [post.url extractContextCommentID];
    NSString *contextId = nil;
    if (commentID && [commentID length] > 0) {
      contextId = [NSString stringWithFormat:@"t1_%@", commentID];
    }
    [[NavigationManager shared] showCommentsForPost:[Post postFromDictionary:npost]
                                          contextId:contextId
                                     fromController:self];
  } else if (extractedSubreddit) {
    [[NavigationManager shared] showPostsForSubreddit:extractedSubreddit
                                                title:[extractedSubreddit convertToSubredditTitle]
                                             animated:YES];
  } else {
    [[NavigationManager shared] showBrowserForPost:post fromController:self];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  // override default JMOutlineViewController implementation
  PostNode *selectedNode = [self.nodes objectAtIndex:indexPath.row];

  if ([selectedNode isKindOfClass:[PostNode class]]) {
    [self showLinkForPost:selectedNode.post];
  } else {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  }
}

- (void)mimicTapOnCellForPostNode:(PostNode *)postNode;
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self rowForNode:postNode] inSection:0];
  [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
  [super scrollViewDidScroll:scrollView];
  [self.footerCoordinator handleScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
  [self.footerCoordinator handleDragRelease];

  if ([UDefaults boolForKey:kABSettingKeyAutoLoadPosts] && ![RedditAPI shared].loadingPosts) {
    float remaining = self.tableView.contentSize.height - self.tableView.contentOffset.y;
    if (remaining < 2000) [self loadMore];
  }
}

- (void)clearAndRefreshFromSettingsLogin {
  [self sponsored_removeSponsoredAdsIfNecessary];
  self.savedScrollPosition = CGPointMake(0, self.recommendedPostTableHeaderOffset);
  [self fetchPostsRemoveExisting:YES];
}

- (void)hideTitle;
{
  self.titleIsHidden = YES;
  [self updateNavbarTitle];
}

- (void)updateNavbarIcons {
  TransparentToolbar *tb = [[TransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];

  UIBarButtonItem *canvasButtonImage =
      [UIBarButtonItem skinBarItemWithIcon:@"canvas-icon" target:self action:@selector(showCanvas)];
  UIBarButtonItem *edgeMarginItem =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                    target:nil
                                                    action:nil];
  edgeMarginItem.width = -19.;

  if ([Resources isIPAD]) {
    tb.items = [NSArray arrayWithObjects:edgeMarginItem, canvasButtonImage, edgeMarginItem, nil];
  }

  UIBarButtonItem *tbItem = [[UIBarButtonItem alloc] initWithCustomView:tb];
  self.navigationItem.rightBarButtonItem = tbItem;
}

- (void)updateNavbarTitle;
{
  NSString *title;
  if (self.titleIsHidden) {
    title = nil;
  } else if (self.headerCoordinator.modFolderSelection != SubredditModFolderDefault) {
    NSString *mUrl =
        [Subreddit moderationUrlForSubredditUrl:self.subreddit
                                      modFolder:self.headerCoordinator.modFolderSelection];
    NSString *baseTitle = [mUrl contains:@"/r/mod/"] ? @"My Subreddits" : self.subredditTitle;
    title = [baseTitle
        stringByAppendingFormat:
            @" (%@)",
            [Subreddit friendlyNameForModerationFolder:self.headerCoordinator.modFolderSelection]];
  } else {
    title = self.subredditTitle;
  }

  [self setNavbarTitle:title];
}

- (void)i_enableModFeatures;
{
  [self.headerCoordinator enableModFeatures];

  BSELF(REDListingViewController);

  // the front page is a good place to do some mod training, because we can guarantee that
  // all mods will start at this page. here we pull the header bar into view so that the
  // mod can see a "highlighted" mod indicator
  if ([self.subreddit isEmpty] &&
      self.tableView.contentOffset.y == self.recommendedPostTableHeaderOffset) {
    DO_WHILE_TRAINING(kREDListingViewControllerTrainingExposeModButtonPrefKey, 2,
                      ^{ [blockSelf.tableView setContentOffset:CGPointZero animated:YES]; });
  }
}

- (void)enableModFeaturesIfNecessary;
{
  // to determine whether or not to show the "Mod" icon in the header bar
  // we could make a call to /reddits/mine/moderator... however this
  // avoids the additional call to the API

  // Instead, the idea here is to enable mod features if
  // 1. url is not a single (native) subreddit (includes r/all, front page, /r/mod or groups)
  // 2. if it is a native subreddit, check to see if any of the returned posts are moddable

  if (![RedditAPI shared].isMod) return;

  if ([self.headerCoordinator modFeaturesEnabled]) return;

  if (self.didCheckPostsForModability) return;

  self.didCheckPostsForModability = YES;

  if ([self.subreddit contains:@"/user/"] || [self.subreddit contains:@"saved/"]) return;

  Subreddit *s = [Subreddit subredditWithUrl:self.subreddit name:@""];
  if (!s.isNativeSubreddit) {
    [self i_enableModFeatures];
    return;
  }

  PostNode *modableNodeMatch = [self.nodes match:^BOOL(PostNode *pNode) {
      return [pNode isKindOfClass:[PostNode class]] && pNode.post.isModdable;
  }];

  if (modableNodeMatch != nil) {
    [self i_enableModFeatures];
  }
}

- (void)postsDidFinishLoading;
{
  self.isLoadingPosts = NO;
  [self enableModFeaturesIfNecessary];
}

- (NSString *)customScreenNameForAnalytics;
{ return @"Posts"; }

@end
