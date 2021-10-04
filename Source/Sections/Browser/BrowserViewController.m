#import "BrowserViewController.h"
#import "AlienBlueAppDelegate.h"
#import "Resources.h"
#import "TransparentToolbar.h"
#import "UIViewController+Additions.h"
#import "BrowserViewController+Legacy.h"
#import "ABOptimalBrowserConfiguration.h"
#import <AVFoundation/AVFoundation.h>
#import "JMArticleContentOptimizer.h"
#import "JMOptimalToolbarCoordinator.h"
#import "JMOptimalContentCoordinator.h"
#import "JMOptimalSwitch.h"
#import "Post+Sponsored.h"

#define kJMWindowRotationNotificationName [NSString stringWithFormat:@"%@%@Notification", @"UIWindow", @"DidRotate"]
#define kJMWindowBecameVisibleNotificationName [NSString stringWithFormat:@"%@%@Notification", @"UIWindow", @"DidBecomeVisible"]

@interface JMOptimalBrowserController ()
@property (strong) JMOptimalToolbarCoordinator *toolbarCoordinator;
@property (strong) JMOptimalContentCoordinator<UIWebViewDelegate> *contentCoordinator;
- (void)setShowOptimal:(BOOL)optimal animated:(BOOL)animated;
- (void)contentCoordinatorStandardBrowserDidFinishLoading:(JMOptimalContentCoordinator *)contentCoordinator;
@end

@interface BrowserViewController()
@property (strong) Post *post;
@property BOOL shouldHideVoteIcons;
@property BOOL didUnmuteForVideo;
@property (copy) NSString *queuedHTMLToDisplay;
@end

@implementation BrowserViewController

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextSizeChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kJMWindowRotationNotificationName object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kJMWindowBecameVisibleNotificationName object:nil];
}

- (void)hookToStyleChangeNotifications;
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyThemeSettings) name:kNightModeSwitchNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyThemeSettings) name:kTextSizeChangeNotification object:nil];
}

- (id)initWithUrl:(NSString *)url;
{
  [JMOptimalBrowserConfiguration setConfiguration:[ABOptimalBrowserConfiguration new]];
  if ([url hasPrefix:@"html://"])
  {
    self = [super initWithURL:nil];
    self.queuedHTMLToDisplay = [url substringFromIndex:(@"html://".length)];
  }
  else
  {
    self = [super initWithURL:[url URL]];
  }
  [self hookToStyleChangeNotifications];
  self.shouldHideVoteIcons = YES;
  
  [self jm_usePreIOS7ScrollBehavior];
  self.title = @"Browser";
  
  // on iOS 9+ viewWillLayoutSubviews is no longer called automatically when exiting HTML5 videos
  // instead firing off a WindowRotationNotification - which also doesn't invoke layout hierarchy update
  // as playback is exiting
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStatusBarDisplayOrHidingIfNecessary) name:kJMWindowRotationNotificationName object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStatusBarDisplayOrHidingIfNecessary) name:kJMWindowBecameVisibleNotificationName object:nil];
  
  return self;
}

- (id)initWithPost:(Post *)post;
{
  self = [self initWithUrl:post.url];
  self.post = post;
  self.shouldHideVoteIcons = NO;
  return self;
}

- (NSString *)currentURL;
{
  return self.URL.absoluteString;
}

- (void)updateWithStaticHTML:(NSString *)html;
{
  [self.toolbarCoordinator setOptimalSwitchHidden:YES];
  [self.toolbarCoordinator setOptimalSwitchDisabled:YES];

  UIWebView *webView = self.contentCoordinator.standardView;
  if ([html hasPrefix:@"<table"])
  {
    [self setNavbarTitle:@"Table"];
  }
  NSString *formattedHTML = JMOptimalFormattedHTMLWithContent(html, @"", self.view.bounds.size.width);
  formattedHTML = [formattedHTML jm_replace:@"overflow: hidden" withString:@"overflow: scroll"];
  [webView loadHTMLString:formattedHTML baseURL:@"http://reddit.com".URL];
  [self contentCoordinatorStandardBrowserDidFinishLoading:self.contentCoordinator];
}

+ (BOOL)isRequestFromReportedAggressiveAdNetwork:(NSURLRequest *)request;
{
  NSString *u = request.URL.absoluteString;
  return [u jm_containsAnyOfStrings:
  @[
     @"da-ads.com",
     @"doubleclick",
   ]];
}

- (BOOL)standardWebViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
  if ([BrowserViewController isRequestFromReportedAggressiveAdNetwork:request])
    return NO;

  if ([request.URL.absoluteString jm_contains:@"youtube"] && !self.didUnmuteForVideo)
  {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    self.didUnmuteForVideo = YES;
  }
  
	// protect the user from the one-way journey to desktop youtube
	if (
      [request.URL.absoluteString rangeOfString:@"youtube"].location != NSNotFound &&
      [request.URL.absoluteString rangeOfString:@"?nomobile=1"].location != NSNotFound
      )
	{
		NSLog(@"over-riding desktop youtube request");
		return NO;
	}
	
	if ([request.URL.host hasSuffix:@"itunes.apple.com"] ||
      [request.URL.host hasSuffix:@"phobos.apple.com"])
	{
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Do you want to launch this link outside of Alien Blue?"
                                                     message:@""
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
		[alert setTag:5];
		[alert show];
		return NO;
	}
  
  if (navigationType == UIWebViewNavigationTypeLinkClicked)
  {
    [self handleLinkClicksForRequest:request];
    return NO;
  }
  
	return [super standardWebViewShouldStartLoadWithRequest:request navigationType:navigationType];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [[NavigationManager shared] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self dismissLegacyExtraOptionsActionSheet];
  [super viewWillDisappear:animated];
}

- (void)handleYouTubeIOS7StatusBarGlitchIfNecessary;
{
  NSString *windowStr = NSStringFromClass([UIApplication sharedApplication].keyWindow.class);
  if ([windowStr jm_contains:@"MPFull"])
  {
    DO_AFTER_WAITING(0.4, ^{
      JMAnimateStatusBarHidden(YES);
    });
  }
}

- (void)viewDidDisappear:(BOOL)animated;
{
  [super viewDidDisappear:animated];
  [self handleYouTubeIOS7StatusBarGlitchIfNecessary];
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  if (self.queuedHTMLToDisplay)
  {
    [self updateWithStaticHTML:self.queuedHTMLToDisplay];
    self.queuedHTMLToDisplay = nil;
  }
}

- (void)handleStatusBarDisplayOrHidingIfNecessary
{
  JM_REQUIRES_SUBCLASS_IMPLEMENTATION;
}

- (void)viewWillLayoutSubviews;
{
  [super viewWillLayoutSubviews];
  [self handleStatusBarDisplayOrHidingIfNecessary];
}

- (void)popupExtraOptionsActionSheet:(id)sender;
{
  [self showLegacyExtraOptionsActionSheet:sender];
}

#pragma mark - Sliding Drag Release Protocol

- (BOOL)canDragRelease
{
  if (!self.post)
    return NO;
  
  if (self.post.promoted && !self.post.sponsoredPostHasCommentThread)
    return NO;
  
  return YES;
}

- (NSString *)titleForDragReleaseLabel
{
  return @"Comments";
}

- (void)didDragRelease
{
  [[NavigationManager shared] switchToComments];
}

- (NSString *)iconNameForDragReleaseDestination;
{
  return @"comments-icon";
}

#pragma mark - Link Handling

- (void)handleLinkClicksForRequest:(NSURLRequest *)request;
{
  NSString *u = request.URL.absoluteString;
  Post *p = [Post postSkeletonFromRedditUrl:u];
  if (p)
  {
    [self userDidTapOnLinkToPost:p];
    return;
  }

  u = [u jm_removeOccurrencesOfString:@"http://reddit.com"];
  u = [u jm_removeOccurrencesOfString:@"http://www.reddit.com"];

  NSString *extractedSubredditLink = [u extractSubredditLink];
  if (extractedSubredditLink)
  {
    [self userDidTapOnSubredditLink:extractedSubredditLink];
    return;
  }

  NSString *extractedUserLink = [u extractUserLink];
  if (extractedUserLink)
  {
    NSString *username = [extractedUserLink jm_removeOccurrencesOfString:@"/u/"];
    username = [username jm_removeOccurrencesOfString:@"/"];
    [self userDidTapOnUserLink:username];
    return;
  }

  [self userDidTapOnExternalLink:request.URL.absoluteString];
}

- (void)userDidTapOnLinkToPost:(Post *)p;
{
  [[NavigationManager shared] showCommentsForPost:p contextId:p.contextCommentIdent fromController:self];
}

- (void)userDidTapOnSubredditLink:(NSString *)subreddit;
{
  NSString *title = [subreddit convertToSubredditTitle];
  [[NavigationManager shared] showPostsForSubreddit:subreddit title:title animated:YES];
}

- (void)userDidTapOnUserLink:(NSString *)username;
{
  [[NavigationManager shared] showUserDetails:username];
}

- (void)userDidTapOnExternalLink:(NSString *)externalLink;
{
  BrowserViewController *controller = [[UNIVERSAL(BrowserViewController) alloc] initWithUrl:externalLink];
  [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)disallowsOptimal;
{
  if (self.post && self.post.promoted)
  {
    return !self.post.sponsoredPostAllowsOptimalBrowser;
  }
  
  return [super disallowsOptimal];
}

@end
