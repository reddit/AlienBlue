#import "NavigationManager.h"
#import "NavigationManager+Deprecated.h"
#import "NavigationStateCoordinator.h"
#import "TiltManager.h"

#import "AlienBlueAppDelegate.h"
#import "Resources.h"
#import "MKStoreManager.h"
#import "SHK.h"
#import "JMDiskCache.h"
#import "ActionMenuManager.h"
#import "ABNotificationManager.h"
#import "RedditAPI+Account.h"
#import "SessionManager+Authentication.h"
#import "NSString+ABLegacyLinkTypes.h"
#import "NSString+HTML.h"
#import "ABHoverPreviewView.h"
#import "MarkupEngine.h"

#import "RedditsViewController.h"
#import "PostsViewController.h"
#import "BrowserViewController.h"
#import "CommentsViewController.h"
#import "CommentsViewController+ReplyInteraction.h"
#import "SettingsViewController.h"
#import "MessagesViewController.h"
#import "UserDetailsViewController.h"
#import "ScreenLockViewController.h"
#import "ScreenLockSettings.h"
#import "CreatePostViewController.h"
#import "SendMessageViewController.h"
#import "ModerationNotifyViewController.h"
#import "EULAViewController.h"
#import "Announcement.h"
#import "Post+Sponsored.h"
#import "RedditAPI+OAuth.h"

#if !ALIEN_BLUE
#import "RedditApp/REDDiscoverViewController.h"
#endif

@interface NavigationManager() <UINavigationControllerDelegate, UIPopoverControllerDelegate>
@property (strong) ActionMenuManager *actionMenuManager;
@property (nonatomic, strong) ABNavigationController *settingsNavigation;
@property (nonatomic, strong) PostsNavigation * postsNavigation;
@property (strong) NSString *lastVisitedSubreddit;
@property (strong) Post *lastVisitedPost;
@end

@implementation NavigationManager

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kABAuthenticationStatusDidSucceedNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kABAuthenticationStatusDidReceiveUpdatedUserInformation object:nil];
}

- (id)init;
{
  self = [super init];
  if (self)
  {
    if (![Resources isIPAD])
    {
      // todo: need to rip this out... its currently used for the legacy
      // upgrade to pro functionality
      SettingsViewController * settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
      self.settingsNavigation = [[ABNavigationController alloc] initWithRootViewController:settingsViewController];
      self.actionMenuManager = [ActionMenuManager new];
    }

    Class redditsClass = [Resources isIPAD] ? NSClassFromString(@"RedditsViewController_iPad") : NSClassFromString(@"RedditsViewController_iPhone");
    RedditsViewController * redditsViewController = [[redditsClass alloc] init];
    self.postsNavigation = [PostsNavigation postsNavigationWithRootControllerOrNil:redditsViewController];
    self.postsNavigation.delegate = self;
    [self deprecated_applyNightSwitchGestureRecognizer];

    [SHK setRootViewController:self.postsNavigation];
    [[TiltManager shared] startMonitoringAccelerometer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successfulAuthenticationNotificationReceived) name:kABAuthenticationStatusDidSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedUserInformationNotificationReceived) name:kABAuthenticationStatusDidReceiveUpdatedUserInformation object:nil];

    #ifdef DEBUG
    DO_AFTER_WAITING(2, ^{ [self postLaunchTesting]; });
    #endif

  }
  return self;
}

#pragma mark -
#pragma mark - Convenience Accessors

+ (NavigationManager *)shared
{
  return [(AlienBlueAppDelegate *) [[UIApplication sharedApplication] delegate] navigationManager];
}

+ (UIViewController *)mainViewController;
{
  return [NavigationManager shared].postsNavigation;
}

+ (UIView *)mainView;
{
  if ([self mainViewController].presentedViewController)
  {
    return [self mainViewController].presentedViewController.view;
  }

  return [NavigationManager mainViewController].view;
}

#pragma mark -
#pragma mark - Screen Launchers

- (void)showMessagesScreen;
{
  REQUIRES_REDDIT_AUTHENTICATION;
  [self.postsNavigation dismissModalViewControllerAnimated:NO];
  NSString *defaultBoxUrl = [RedditAPI shared].hasModMail && ![RedditAPI shared].hasMail ? @"/message/moderator/" : @"/message/inbox/";
  MessagesViewController *mvc = [[MessagesViewController alloc] initWithBoxUrl:defaultBoxUrl];
  ABNavigationController *messagesNavigation = [[ABNavigationController alloc] initWithRootViewController:mvc];
  messagesNavigation.toolbarHidden = YES;
  messagesNavigation.navigationBarHidden = YES;
  [self.postsNavigation presentModalViewController:messagesNavigation animated:YES];
}

- (void)showUserDetails:(NSString *)username
{
  UserDetailsViewController *controller = [[UserDetailsViewController alloc] initWithUsername:username];
  [self.postsNavigation pushViewController:controller animated:YES];
}

- (void)showSettingsScreen;
{
  SettingsViewController *controller = [[SettingsViewController alloc] initWithSettingsSection:SettingsSectionHome];
  ABNavigationController *nav = [[ABNavigationController alloc] initWithRootViewController:controller];
  [self.postsNavigation presentModalViewController:nav animated:YES];
}

- (void)showProUpgradeScreen;
{
  if([MKStoreManager isProUpgraded])
    return;

  UINavigationController *modalNavigationController = JMCastOrNil(self.postsNavigation.presentedViewController, UINavigationController);
  SettingsViewController *alreadyVisibleSettingsController = JMCastOrNil(modalNavigationController.viewControllers.first, SettingsViewController);
  if (alreadyVisibleSettingsController)
  {
    [modalNavigationController popToRootViewControllerAnimated:YES];
    DO_AFTER_WAITING(0.3, ^{
      [alreadyVisibleSettingsController.tableView setContentOffset:CGPointZero animated:YES];
    });
  }
  else
  {
    [self showSettingsScreen];
  }
}

- (void)showSendDirectMessageScreenForUser:(NSString *)username;
{
  REQUIRES_REDDIT_AUTHENTICATION;
  [self.postsNavigation dismissModalViewControllerAnimated:NO];
  SendMessageViewController *pmViewController = [[SendMessageViewController alloc] initWithUsername:username];
  ABNavigationController * navc = [[ABNavigationController alloc] initWithRootViewController:pmViewController];
  [self.postsNavigation presentModalViewController:navc animated:YES];
}

- (void)showCreatePostScreen;
{
//  REQUIRES_PRO;
  REQUIRES_REDDIT_AUTHENTICATION;
  [self.postsNavigation dismissModalViewControllerAnimated:NO];
  ABNavigationController * navc = [CreatePostViewController viewControllerWithNavigation];
  [self.postsNavigation presentModalViewController:navc animated:YES];
}

- (void)showPostsForSubreddit:(NSString *)sr title:(NSString *)title animated:(BOOL)animated;
{
  self.lastVisitedSubreddit = sr;
  NSString *srPath = [sr generateSubredditPathFromSubredditTitle];
  Class postsControllerClass = [Resources isIPAD] ? NSClassFromString(@"PostsViewController_iPad") : NSClassFromString(@"PostsViewController");
  PostsViewController *postsController = [[postsControllerClass alloc] initWithSubreddit:srPath title:title];
#if ALIEN_BLUE
  [self.postsNavigation pushViewController:postsController animated:animated];
#else
  // gross. this is the worst.
  // TODO(sharkey): Rewrite this.
  UITabBarController *tbc =
      (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
  UINavigationController *navigationController =
      (UINavigationController *)tbc.selectedViewController;
  REDDiscoverViewController *discoverViewController =
      (REDDiscoverViewController *)[navigationController.viewControllers first];
  [discoverViewController.abNavigationController pushViewController:postsController animated:YES];
#endif
}

- (void)showModerationNotifyScreenForPost:(Post *)nPost onModerationMessageSentResponse:(void (^)(id response))onModerationMessageSentResponse;
{
  ModerationNotifyViewController *controller = [[UNIVERSAL(ModerationNotifyViewController) alloc] initWithPost:nPost];
  controller.onModerationNotifySendComplete = onModerationMessageSentResponse;
  ABNavigationController *nav = [[ABNavigationController alloc] initWithRootViewController:controller];
  nav.modalPresentationStyle = UIModalPresentationFormSheet;
  nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  [self.postsNavigation presentViewController:nav animated:YES completion:nil];
}

- (void)showModerationTemplateManagement;
{
  TemplatesViewController *controller = [[UNIVERSAL(TemplatesViewController) alloc] initWithDefaultGroupIdent:kTemplatePrefsGroupIdentRemoval];
  ABNavigationController *nav = [[ABNavigationController alloc] initWithRootViewController:controller];
  nav.modalPresentationStyle = UIModalPresentationFormSheet;
  nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  [self.postsNavigation presentViewController:nav animated:YES completion:nil];
}

- (void)showEULA;
{
  // todo: need to check if this is still necessary with Apple
  return;

  BSELF(NavigationManager);
  DO_WHILE_TRAINING(@"showing-eula-B", 1, ^{
    EULAViewController *controller = [EULAViewController new];
    ABNavigationController *nav = [[ABNavigationController alloc] initWithRootViewController:controller];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [blockSelf.postsNavigation presentModalViewController:nav animated:NO];
  });
}

- (void)handleTapOnUrl:(NSString *)url fromController:(UIViewController *)fromController;
{
  if (url && [url rangeOfString:@"Spoiler:"].location != NSNotFound)
  {
    NSString *spoilerBody = [[MarkupEngine flattenHTML:url] stringByDecodingHTMLEntities];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Spoiler" message:spoilerBody delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    return;
  }

  if (!url)
    return;

  NSString * parsedPostID = [url extractRedditPostIdent];

  NSString *extractedSubreddit = [url extractSubredditLink];
  NSString *extractedUsernameLink = [url extractUserLink];

  if (parsedPostID && [parsedPostID length] > 0)
  {
    NSMutableDictionary * npost = [[NSMutableDictionary alloc] init];
    [npost setValue:parsedPostID forKey:@"id"];
    [npost setValue:@"" forKey:@"type"];

    NSString *commentID = [url extractContextCommentID];
    NSString *contextId = nil;
    if (commentID && [commentID length] > 0)
    {
      contextId = [NSString stringWithFormat:@"t1_%@", commentID];
    }
    [[NavigationManager shared] showCommentsForPost:[Post postFromDictionary:npost] contextId:contextId fromController:fromController];
  }
  else if (extractedSubreddit)
  {
    [[NavigationManager shared] showPostsForSubreddit:extractedSubreddit title:[extractedSubreddit convertToSubredditTitle] animated:YES];
  }
  else if (extractedUsernameLink)
  {
    NSString *username = [extractedUsernameLink jm_removeOccurrencesOfString:@"/u/"];
    username = [username jm_removeOccurrencesOfString:@"/"];
    [[NavigationManager shared] showUserDetails:username];
  }
  else
  {
    [[NavigationManager shared] showBrowserForUrl:url fromController:fromController];
  }
}

- (void)showFullScreenViewerForGalleryItems:(NSArray *)galleryItems startingAtIndex:(NSUInteger)atIndex;
{
  // Not yet implemented for iPhone (implementation currently found in NavigationManager_iPad
}

- (void)showCommentsForPost:(Post *)npost contextId:(NSString *)contextId fromController:(UIViewController *)fromController;
{
  [npost trackSponsoredCommentsVisitIfNecessary];

  self.lastVisitedPost = npost;
  self.deprecated_legacyPostDictionary = npost.legacyDictionary;
  NSString *context = nil;
  if (contextId)
  {
    context = [contextId convertRedditNameToIdent];
  }
  CommentsViewController *commentsView = [[UNIVERSAL(CommentsViewController) alloc] initWithPost:npost contextId:context];
  [self.postsNavigation pushViewController:commentsView animated:YES];
}

- (void)showBrowserForUrl:(NSString *)url fromController:(UIViewController *)fromController;
{
  BrowserViewController *browserView = [[UNIVERSAL(BrowserViewController) alloc] initWithUrl:url];
  [[NavigationManager shared].postsNavigation pushViewController:browserView animated:YES];
}

- (void)showBrowserForPost:(Post *)npost fromController:(UIViewController *)fromController;
{
  [npost trackSponsoredLinkVisitIfNecessary];

  self.lastVisitedPost = npost;
  NSMutableDictionary *legacyDictionary = npost.legacyDictionary;
  [legacyDictionary setObject:npost.url forKey:@"url"];
  self.deprecated_legacyPostDictionary = legacyDictionary;

  BrowserViewController *browserController = [[UNIVERSAL(BrowserViewController) alloc] initWithPost:npost];
  [self.postsNavigation pushViewController:browserController animated:YES];
}

#pragma mark -
#pragma mark - Handling of Submitted Comments

- (void)apiReplyResponse:(id)sender
{
	NSDictionary * newComment = (NSDictionary *) sender;
	NSString * promptString = [NSString stringWithFormat:@"Your reply was submitted."];
	[PromptManager addPrompt:promptString];
  [[SessionManager manager] handleSwitchBackToMainAccountIfNecessary];

  BOOL isShowingIPADModal = [Resources isIPAD] && self.postsNavigation.presentedViewController != nil;
  BOOL isViewingComments = JMIsClass(self.postsNavigation.visibleViewController, CommentsViewController);

  if (!isShowingIPADModal && isViewingComments)
  {
    CommentsViewController *commentsController = (CommentsViewController *)self.postsNavigation.visibleViewController;
    [commentsController afterCommentReply:newComment];
  }
}

#pragma mark -
#pragma mark - Controller-Specific UI Changes

- (void)votingIconsNeedUpdate;
{
  if ([Resources useActionMenu])
  {
    [self.actionMenuManager updateForPostsNavigationController:self.postsNavigation];
  }
  else
  {
    [self deprecated_drawIphoneVotingItems];
  }
}

- (void)interactionIconsNeedUpdate;
{
  if ([Resources useActionMenu])
  {
    [self.actionMenuManager updateForPostsNavigationController:self.postsNavigation];
  }
  else
  {
    [self deprecated_drawIphoneBottomToolbarItems];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([Resources isIPAD])
		return YES;

	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return NO;

  if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) && ![UDefaults boolForKey:kABSettingKeyAllowRotation])
    return NO;

	return YES;
}

#pragma mark -
#pragma mark - Custom Navigation Behaviors

- (void)showNavigationStack;
{
  BSELF(NavigationManager);
  UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"Go back to..."];
  [self.postsNavigation.viewControllers eachWithIndex:^(UIViewController *viewController, NSUInteger viewIndex) {
    NSString *title = viewController.title;
    SET_IF_EMPTY(title, @"Unnamed");
    if (viewIndex == (blockSelf.postsNavigation.viewControllers.count - 1))
    {
      title = [title stringByAppendingString:@" (Here)"];
    }
    [sheet bk_addButtonWithTitle:title handler:^{
      [blockSelf.postsNavigation popToViewController:viewController animated:YES];
    }];
  }];
  [sheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [sheet jm_showInView:[NavigationManager mainView]];
}

- (void)goBackToPreviousScreen;
{
  if ([[self.postsNavigation viewControllers] count] > 1)
  {
    [self.postsNavigation popViewControllerAnimated:YES];
  }

  if ([self.postsNavigation respondsToSelector:@selector(userDidNavigateBackWithoutSwiping)])
  {
    [self.postsNavigation performSelector:@selector(userDidNavigateBackWithoutSwiping)];
  }
}

- (void)switchToCommentsWithPost:(Post *)post;
{
  self.lastVisitedPost = post;
  [self switchToComments];
}

- (void)switchToComments;
{
  if (JMIsClass(self.postsNavigation.secondLastController, PostsViewController))
  {
    // if we initially went directly to the browser before loading comments, we need to load
    // them now.
    [self showCommentsForPost:self.lastVisitedPost contextId:nil fromController:self.postsNavigation.topViewController];
  }
  else
  {
    // if we're coming back to the comments from the browser view (eg. from an embedded comment
    // link, we just pop back so that we don't lose our place in the comments.
    [self.postsNavigation popViewControllerAnimated:YES];
  }
}

- (void)switchToArticle;
{
  if (JMIsClass(self.postsNavigation.secondLastController, BrowserViewController))
  {
    // Handle the case when user navigaties "View Article -> Comments -> View Article"
    [self.postsNavigation popViewControllerAnimated:YES];
  }
  else
  {
    [self showBrowserForPost:self.lastVisitedPost fromController:self.postsNavigation.topViewController];
  }
}

- (void)dismissPopoverIfNecessary;
{
}

- (void)dismissModalView;
{
  [self.postsNavigation dismissModalViewControllerAnimated:YES];
  BSELF(NavigationManager);
  DO_AFTER_WAITING(0.8, ^{
    [blockSelf interactionIconsNeedUpdate];
  });
}

#pragma mark -
#pragma mark - Screen Locking

- (void)presentScreenLock
{
  [self.postsNavigation dismissModalViewControllerAnimated:NO];
  ScreenLockViewController * sc = [[ScreenLockViewController alloc] initWithNibName:@"ScreenLockView" bundle:nil];
  [self.postsNavigation presentModalViewController:sc animated:NO];
}

- (void)showScreenLockIfNecessary;
{
	if (![UDefaults boolForKey:kABSettingKeyShouldPasswordProtect])
		return;

	if (![UDefaults objectForKey:kABSettingKeyPasswordCode])
		return;

	if ([[UDefaults valueForKey:kABSettingKeyPasswordCode] length] < 4)
		return;

  [self presentScreenLock];
}

#pragma mark -
#pragma mark - Memory Handling

- (void)purgeMemory;
{
  [UIImage jm_clearCachedImages];
  [[AFImageCache sharedImageCache] removeAllObjects];
  [[JMDiskCache shared] clearMemoryCache];
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)receivedMemoryWarning;
{
  [self purgeMemory];
}

#pragma mark -
#pragma mark - Night Switch Handling

- (void)performNightTransitionAnimation;
{
  __block UIView *existingScreenshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  [window addSubview:existingScreenshotView];

  BOOL shouldKeepStatusBarHiddenAfterAnimation = [UIApplication sharedApplication].statusBarHidden;
  [UIApplication sharedApplication].statusBarHidden = YES;

  [SettingsViewController toggleNightTheme];
  // need to give views that listen for the theme change enough time to
  // receive and respond to the notification
  CGFloat notificationPropagationDelayTime = 0.05;
  DO_AFTER_WAITING(notificationPropagationDelayTime, ^{
    [self.postsNavigation viewWillDisappear:NO];
    [self.postsNavigation viewDidDisappear:NO];
    [self.postsNavigation viewWillAppear:YES];
    [self.postsNavigation viewDidAppear:YES];
    [UIView animateWithDuration:1.2 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
      existingScreenshotView.alpha = 0.;
      [[UIApplication sharedApplication] setStatusBarHidden:shouldKeepStatusBarHiddenAfterAnimation withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
      [existingScreenshotView removeFromSuperview];
      existingScreenshotView = nil;
    }];
  });
}

- (void)userDidTripleTapNavigationBar;
{
  if (self.postsNavigation.presentedViewController != nil)
    return;

  UIViewController *frontController = self.postsNavigation.topViewController;
  if (JMIsClass(frontController, RedditsViewController))
  {
    RedditsViewController *redditsController = JMCastOrNil(frontController, RedditsViewController);
    if (redditsController.tableView.editing)
      return;
  }
  [self performNightTransitionAnimation];
}

- (void)navigationBarTripleTapped:(UITapGestureRecognizer *)gesture;
{
  if (gesture.state != UIGestureRecognizerStateEnded)
    return;

  [self userDidTripleTapNavigationBar];
}

#pragma mark -
#pragma mark - Internal Prompt Handling

- (void)handleShowPromptNotification:(NSString *)prompt;
{
  if ([NavigationManager shared].postsNavigation.navigationBarHidden)
  {
    [PromptManager showMomentaryHudWithMessage:prompt minShowTime:1.5];
    return;
  }

  [NavigationManager shared].postsNavigation.visibleViewController.navigationItem.prompt = prompt;
  [NavigationManager shared].settingsNavigation.visibleViewController.navigationItem.prompt = prompt;
}

- (void)handleHidePromptNotification;
{
  if ([NavigationManager shared].postsNavigation.navigationBarHidden)
  {
    [PromptManager hideHud];
    return;
  }

  [NavigationManager shared].postsNavigation.visibleViewController.navigationItem.prompt = nil;
  [NavigationManager shared].settingsNavigation.visibleViewController.navigationItem.prompt = nil;
}

#pragma mark -
#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
  self.postsNavigation.shouldSuppressPushingOrPopping = NO;
  if ([Resources useActionMenu])
  {
    [self.actionMenuManager postsNavigationController:self.postsNavigation didShowViewController:viewController];
  }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  self.postsNavigation.shouldSuppressPushingOrPopping = YES;

  [UIView setAnimationsEnabled:YES];
  [PromptManager hideHud];

  [self deprecated_handleFullscreenWillShowViewControllerAdjustments];

  if ([Resources useActionMenu])
  {
    [self.actionMenuManager postsNavigationController:self.postsNavigation willShowViewController:viewController];
  }

  [self interactionIconsNeedUpdate];
}

#pragma mark -
#pragma mark - Authentication Related Notifications

- (void)successfulAuthenticationNotificationReceived;
{
  [PromptManager addPrompt:[NSString stringWithFormat:@"Successfully authenticated %@", [RedditAPI shared].authenticatedUser]];
  [self clearAndRefreshPosts];
  [self refreshUserSubreddits];
  [self interactionIconsNeedUpdate];
  [[ABNotificationManager manager] askPermissionForLocalNotificationsIfNecessary];
}

- (void)clearAndRefreshPosts
{
  [self.postsNavigation.viewControllers each:^(UIViewController *viewController) {
    if ([viewController isKindOfClass:[PostsViewController class]])
    {
      PostsViewController *postsViewController = (PostsViewController *)viewController;
      [postsViewController clearAndRefreshFromSettingsLogin];
    }
  }];
}

- (void)updatedUserInformationNotificationReceived;
{
  [self interactionIconsNeedUpdate];
  [[ABNotificationManager manager] askPermissionForLocalNotificationsIfNecessary];

  // super hacky but ensures that screens like comments/posts are updated and rendered
  // if user's authentication status changes or an offline connection (airplane mode) is
  // enabled while the comment/posts screen is already visible
  [self.postsNavigation viewDidAppear:NO];
}

- (void)refreshUserSubreddits;
{
  [[NSNotificationCenter defaultCenter] postNotificationName:kUserSwitchNotification object:nil];
}

#pragma mark -
#pragma mark - Saving & Restoring State

- (void)saveState;
{
  NavigationStateCoordinator *stateCoordinator = [[NavigationStateCoordinator alloc] initWithParentNavigationManager:self];
  [stateCoordinator saveState];
}

- (void)restoreState;
{
  NavigationStateCoordinator *stateCoordinator = [[NavigationStateCoordinator alloc] initWithParentNavigationManager:self];
  [stateCoordinator restoreState];
}

#pragma mark -
#pragma mark - Testing

- (void)postLaunchTesting;
{}

@end
