#import "ABActionMenuHost.h"
#import "ABActionMenuThemeConfiguration.h"
#import "ABActionMenuWatchedPostStatistics.h"
#import "ABActionMenuKarmaStatistics.h"
#import "ABActionMenuWatchedCommentStatistics.h"
#import "Resources.h"

#import "PostsViewController+PopoverOptions.h"
#import "CommentsViewController+PopoverOptions.h"
#import "RedditsViewController.h"
#import "BrowserViewController.h"
#import "NavigationManager.h"
#import "RedditAPI+Account.h"
#import "Post+API.h"
#import "Message+API.h"

#import "JMActionMenuBarItemView.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "ABCustomOutlineNavigationBar.h"

#import "PostsActionMenuHost.h"
#import "CommentsActionMenuHost.h"
#import "HomeActionMenuHost.h"
#import "BrowserActionMenuHost.h"

#import "ABActionMenuFavoriteLinkEditPanel.h"
#import "ABActionMenuKarmaEditPanel.h"
#import "ABActionMenuWatchedPostEditPanel.h"

#define kABActionMenuCommentUnicodeCircleComponent @"\U000025CF"
#define kABActionMenuCommentUnicodeCombiningAccentComponent @"\U000020DA"
#define kABActionMenuCommentUnicode ([kABActionMenuCommentUnicodeCircleComponent stringByAppendingString:kABActionMenuCommentUnicodeCombiningAccentComponent])

@interface ABActionMenuHost()
@property (strong) JMActionMenuView *actionMenuView;
@property (strong) ABActionMenuThemeConfiguration *themeConfiguration;
@property (weak) UIViewController *parentController;
@property (strong) NSArray *actionMenuNodes;
@end

@implementation ABActionMenuHost

+ (ABActionMenuHost *)actionMenuHostForViewController:(UIViewController *)viewController;
{
  Class hostClass = [ABActionMenuHost class];
  
  if (JMIsClass(viewController, PostsViewController))
    hostClass = [PostsActionMenuHost class];
  else if (JMIsClass(viewController, CommentsViewController))
    hostClass = [CommentsActionMenuHost class];
  else if (JMIsClass(viewController, RedditsViewController))
    hostClass = [HomeActionMenuHost class];
  else if (JMIsClass(viewController, BrowserViewController))
    hostClass = [BrowserActionMenuHost class];
  
  ABActionMenuHost *host = [[hostClass alloc] initForViewController:viewController];
  return host;
}

- (id)initForViewController:(UIViewController *)viewController;
{
  JM_SUPER_INIT(init);
  self.parentController = viewController;
  self.parentController.relatedActionMenuHost = self;
  self.themeConfiguration = [ABActionMenuThemeConfiguration new];
  self.actionMenuView = [[JMActionMenuView alloc] initWithDelegate:self];
  return self;
}

- (NSArray *)generateSharedHighPriorityActionMenuNodes;
{
  UIColor *defaultColor = [ABActionMenuThemeConfiguration new].themeForegroundColor;
  
  JMActionMenuNode *inboxNode = [JMActionMenuNode nodeWithIdent:@"global-inbox" iconName:@"am-icon-global-inbox" title:@"Messages"];
  inboxNode.nodeDescription = @"Access to messages and moderator mail";
  inboxNode.color = defaultColor;
  inboxNode.badgeColor = [RedditAPI shared].hasMail ? [UIColor colorForInboxAlert] : [UIColor colorForModeratorMailAlert];
  inboxNode.onTap = ^{
    [[NavigationManager shared] showMessagesScreen];
  };
  inboxNode.onBadgeTap = inboxNode.onTap;
  inboxNode.showsBadge = [RedditAPI shared].hasMail || [RedditAPI shared].hasModMail;
  inboxNode.allowsBadgeDisplayInCompact = YES;
  
  JMActionMenuNode *settingsNode = [JMActionMenuNode nodeWithIdent:@"global-settings" iconName:@"am-icon-global-settings" title:@"Settings"];
  settingsNode.nodeDescription = @"Change application wide settings";
  settingsNode.color = JMHexColor(fa73d9);
  settingsNode.onTap = ^{
    [[NavigationManager shared] showSettingsScreen];
  };
  
  JMActionMenuNode *karmaNode = [JMActionMenuNode nodeWithIdent:@"global-karma" iconName:@"am-icon-global-karma" title:@"Karma"];
  karmaNode.nodeDescription = @"Your post and comment karma";
  karmaNode.hiddenByDefault = !JMIsClass(self, HomeActionMenuHost) && !(JMIsClass(self, PostsActionMenuHost) && JMIsIphone6Plus());
  karmaNode.color = JMHexColor(59b144);
  NSNumber *shouldTruncateByDefaultUserInfo = [NSNumber numberWithBool:YES];
  karmaNode.defaultUserInfo = shouldTruncateByDefaultUserInfo;
  karmaNode.customPanelEditViewClass = [ABActionMenuKarmaEditPanel class];
  karmaNode.customLabelTextGenerateAction = ^(NSString *nodeTitle, id userInfo, void(^callOnCompleteAction)(NSString *customTextOrNil, NSAttributedString *attributedStringOrNil)){
    if (![RedditAPI shared].authenticated)
    {
      callOnCompleteAction(nodeTitle, nil);
      return;
    }
    BOOL shouldTruncate = [(NSNumber *)userInfo boolValue];
    NSAttributedString *as = [[ABActionMenuKarmaStatistics karmaStatistics] attributedStringBasedOnLatestStatsShouldTruncate:shouldTruncate];
    callOnCompleteAction(nil, as);
  };
  karmaNode.onTap = ^{
    REQUIRES_REDDIT_AUTHENTICATION;
    [[NavigationManager shared].postsNavigation popToRootViewControllerAnimated:NO];
    [[NavigationManager shared] showUserDetails:[[RedditAPI shared] authenticatedUser]];
  };

  JMActionMenuNode *submitPostNode = [JMActionMenuNode nodeWithIdent:@"posts-submit" iconName:@"am-icon-posts-submit" title:@"New Post"];
  submitPostNode.nodeDescription = @"Submit a post for the reddit community";
  submitPostNode.color = JMHexColor(31a888);
  submitPostNode.onTap = ^{
    [[NavigationManager shared] showCreatePostScreen];
  };
  submitPostNode.hiddenByDefault = !JMIsClass(self, PostsActionMenuHost) && !JMIsClass(self, HomeActionMenuHost);
  
  return @[
           inboxNode,
           settingsNode,
           karmaNode,
           submitPostNode
           ];
}

- (void)handleTapOnLastSubmittedCommentNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;
  [Message fetchLastSubmittedMessageCommentForUser:[RedditAPI shared].authenticatedUser onComplete:^(Message *messageCommentOrNil) {
    if (!messageCommentOrNil)
      return;

    if (JMIsEmpty(messageCommentOrNil.linkIdent))
      return;
    
    if (JMIsEmpty(messageCommentOrNil.name))
      return;
    
    NSRange underscorePosition = [messageCommentOrNil.linkIdent rangeOfString:@"_"];
    NSString *postIdent = [messageCommentOrNil.linkIdent substringFromIndex:underscorePosition.location + 1];
    if (JMIsEmpty(postIdent))
      return;
    
    NSDictionary *postDictionary = @{
                                     @"id" : postIdent,
                                     @"type" : @""
                                     };
    Post *post = [Post postFromDictionary:postDictionary];
    
    [[NavigationManager shared] showCommentsForPost:post contextId:messageCommentOrNil.name fromController:nil];
    [[NavigationManager shared] dismissModalView];
  }];
}

- (void)handleTapOnLastSubmittedPostNode;
{
  REQUIRES_REDDIT_AUTHENTICATION;
  
  [Post fetchLastSubmittedPostForUser:[RedditAPI shared].authenticatedUser onComplete:^(Post *lastSubmittedPostOrNil) {
    if (!lastSubmittedPostOrNil)
      return;
    
    [[NavigationManager shared] showCommentsForPost:lastSubmittedPostOrNil contextId:nil fromController:nil];
  }];
}

- (void)generateLastSubmittedCommentCustomLabelWithDefaultTitle:(NSString *)nodeTitle callOnCompleteAction:(void (^)(NSString *, NSAttributedString *))callOnCompleteAction;
{
  if (![RedditAPI shared].authenticated)
  {
    callOnCompleteAction(nodeTitle, nil);
    return;
  }

  ABActionMenuWatchedCommentStatistics *stats = [ABActionMenuWatchedCommentStatistics lastSubmittedCommentStats];
  if (stats.shouldRestrictNetworkUpdateBasedOnRateLimiting)
  {
    callOnCompleteAction(nil, stats.attributedStringBasedOnLatestStats);
    return;
  }
  
  [Message fetchLastSubmittedMessageCommentForUser:[RedditAPI shared].authenticatedUser onComplete:^(Message *messageCommentOrNil) {
    if (!messageCommentOrNil)
    {
      callOnCompleteAction(nodeTitle, nil);
      return;
    }
    
    [stats updateBasedOnReceivedMessageComment:messageCommentOrNil];
    callOnCompleteAction(nil, stats.attributedStringBasedOnLatestStats);
  }];
}

- (void)generateCustomLastSubmittedPostTitleWithDefaultTitle:(NSString *)nodeTitle callOnCompleteAction:(void (^)(NSString *, NSAttributedString *))callOnCompleteAction
{
  if (![RedditAPI shared].authenticated)
  {
    callOnCompleteAction(nodeTitle, nil);
    return;
  }
  
  ABActionMenuWatchedPostStatistics *stats = [ABActionMenuWatchedPostStatistics lastSubmittedPostStats];
  
  if (stats.shouldRestrictNetworkUpdateBasedOnRateLimiting)
  {
    callOnCompleteAction(nil, stats.attributedStringBasedOnLatestStats);
    return;
  }
  
  [Post fetchLastSubmittedPostForUser:[RedditAPI shared].authenticatedUser onComplete:^(Post *lastSubmittedPostOrNil) {
    if (!lastSubmittedPostOrNil)
    {
      callOnCompleteAction(nodeTitle, nil);
      return;
    }
    
    [stats updateBasedOnReceivedPost:lastSubmittedPostOrNil];
    callOnCompleteAction(nil, stats.attributedStringBasedOnLatestStats);
  }];
}

- (NSArray *)generateSharedLowPriorityActionMenuNodes;
{
  BSELF(ABActionMenuHost);
  
  JMActionMenuNode *nightSwitchNode = [JMActionMenuNode nodeWithIdent:@"global-nightmode" iconName:@"am-icon-global-nightmode" title:@"Night"];
  nightSwitchNode.nodeDescription = @"Switch between day & night themes";
  nightSwitchNode.color = JMHexColor(41a1a5);
  nightSwitchNode.customLabelText = [Resources isNight] ? @"Day" : @"Night";
  nightSwitchNode.onTap = ^{
    DO_AFTER_WAITING(0.25, ^{
      [[NavigationManager shared] performNightTransitionAnimation];
    });
  };
  nightSwitchNode.hiddenByDefault = !JMIsClass(self, PostsActionMenuHost) && !JMIsClass(self, HomeActionMenuHost);

  JMActionMenuNode *lastSubmittedPostNode = [JMActionMenuNode nodeWithIdent:@"global-goto-last-submitted-post" iconName:@"am-icon-global-goto-last-submitted-post" title:@"Last Submission"];
  lastSubmittedPostNode.nodeDescription = @"Shortcut to your last submitted post";
  lastSubmittedPostNode.color = JMHexColor(e792ff);
  lastSubmittedPostNode.hiddenByDefault = YES;
  lastSubmittedPostNode.customLabelTextGenerateAction = ^(NSString *nodeTitle, id userInfo, void(^callOnCompleteAction)(NSString *customTextOrNil, NSAttributedString *attributedStringOrNil)){
    [blockSelf generateCustomLastSubmittedPostTitleWithDefaultTitle:nodeTitle callOnCompleteAction:callOnCompleteAction];
  };
  lastSubmittedPostNode.onTap = ^{
    [blockSelf handleTapOnLastSubmittedPostNode];
  };
  
  JMActionMenuNode *lastSubmittedCommentNode = [JMActionMenuNode nodeWithIdent:@"global-goto-last-submitted-comment" iconName:@"am-icon-global-goto-last-submitted-comment" title:@"Last Comment"];
  lastSubmittedCommentNode.nodeDescription = @"Shortcut to your last comment";
  lastSubmittedCommentNode.color = JMHexColor(ff5a62);
  lastSubmittedCommentNode.hiddenByDefault = YES;
  lastSubmittedCommentNode.customLabelTextGenerateAction = ^(NSString *nodeTitle, id userInfo, void(^callOnCompleteAction)(NSString *customTextOrNil, NSAttributedString *attributedStringOrNil)){
    [blockSelf generateLastSubmittedCommentCustomLabelWithDefaultTitle:nodeTitle callOnCompleteAction:callOnCompleteAction];
  };
  lastSubmittedCommentNode.onTap = ^{
    [blockSelf handleTapOnLastSubmittedCommentNode];
  };
  
  JMActionMenuNode *subredditShortcutNode1 = [JMActionMenuNode nodeWithIdent:@"global-goto-subreddit-1" iconName:@"am-icon-global-goto-subreddit" title:@"Shortcut"];
  subredditShortcutNode1.nodeDescription = @"Shortcut to a favorite subreddit";
  subredditShortcutNode1.color = JMHexColor(e792ff);
  subredditShortcutNode1.defaultUserInfo = @"/r/AskReddit";
  subredditShortcutNode1.hiddenByDefault = YES;
  subredditShortcutNode1.customPanelEditViewClass = [ABActionMenuFavoriteLinkEditPanel class];
  subredditShortcutNode1.customEditLabelTextGenerateAction = ^NSString *(NSString *nodeTitle, id<NSCoding> userInfo) {
    NSString *subredditLink = (NSString *)userInfo;
    NSString *friendlyTitle = [subredditLink convertToSubredditTitle];
    return [NSString stringWithFormat:@"%@ : %@", nodeTitle, friendlyTitle];
  };
  subredditShortcutNode1.customLabelTextGenerateAction = ^(NSString *nodeTitle, id userInfo, void(^callOnCompleteAction)(NSString *customTextOrNil, NSAttributedString *attributedStringOrNil)){
    NSString *subredditLink = (NSString *)userInfo;
    NSString *friendlyTitle = [subredditLink convertToSubredditTitle];
    callOnCompleteAction(friendlyTitle, nil);
  };
  
  void(^OnSubredditShortcutTapAction)(NSObject<NSCoding> *userInfo) = ^(NSObject<NSCoding> *userInfo){
    NSString *subredditLink = (NSString *)userInfo;
    NSString *friendlyTitle = [subredditLink convertToSubredditTitle];
    [[NavigationManager shared] showPostsForSubreddit:subredditLink title:friendlyTitle animated:YES];
  };

  [subredditShortcutNode1 setOnTapWithUserInfo:OnSubredditShortcutTapAction];
  
  JMActionMenuNode *subredditShortcutNode2 = [JMActionMenuNode nodeWithIdent:@"global-goto-subreddit-2" iconName:@"am-icon-global-goto-subreddit" title:@"Shortcut"];
  subredditShortcutNode2.nodeDescription = subredditShortcutNode1.nodeDescription;
  subredditShortcutNode2.color = JMHexColor(546dac);
  subredditShortcutNode2.customPanelEditViewClass = subredditShortcutNode1.customPanelEditViewClass;
  subredditShortcutNode2.customEditLabelTextGenerateAction = subredditShortcutNode1.customEditLabelTextGenerateAction;
  subredditShortcutNode2.defaultUserInfo = @"/r/AlienBlue";
  subredditShortcutNode2.customLabelTextGenerateAction = subredditShortcutNode1.customLabelTextGenerateAction;
  subredditShortcutNode2.hiddenByDefault = !JMIsClass(self, HomeActionMenuHost);
  [subredditShortcutNode2 setOnTapWithUserInfo:OnSubredditShortcutTapAction];
  
  JMActionMenuNode *watchedPostNode1 = [JMActionMenuNode nodeWithIdent:@"global-goto-watched-post-1" iconName:@"am-icon-global-goto-last-submitted-post" title:@"Watched Post"];
  watchedPostNode1.nodeDescription = @"Stats and link to a watched post";
  watchedPostNode1.color = JMHexColor(41a1a5);
  watchedPostNode1.hiddenByDefault = YES;
  watchedPostNode1.customPanelEditViewClass = [ABActionMenuWatchedPostEditPanel class];
  watchedPostNode1.customLabelTextGenerateAction = ^(NSString *nodeTitle, id userInfo, void(^callOnCompleteAction)(NSString *customTextOrNil, NSAttributedString *attributedStringOrNil)){
    [blockSelf generateWatchedPostCustomLabelWithStats:[ABActionMenuWatchedPostStatistics watchedPostOneStats] defaultTitle:nodeTitle userInfo:userInfo callOnCompleteAction:callOnCompleteAction];
  };
  [watchedPostNode1 setOnTapWithUserInfo:^(NSObject<NSCoding> *userInfo) {
    [blockSelf handleTapOnWatchedPostWithUserInfo:userInfo];
  }];

  JMActionMenuNode *watchedPostNode2 = [JMActionMenuNode nodeWithIdent:@"global-goto-watched-post-2" iconName:@"am-icon-global-goto-last-submitted-post" title:@"Watched Post"];
  watchedPostNode2.nodeDescription = @"Stats and link to a watched post";
  watchedPostNode2.color = JMHexColor(5abbff);
  watchedPostNode2.hiddenByDefault = YES;
  watchedPostNode2.customPanelEditViewClass = [ABActionMenuWatchedPostEditPanel class];
  watchedPostNode2.customLabelTextGenerateAction = ^(NSString *nodeTitle, id userInfo, void(^callOnCompleteAction)(NSString *customTextOrNil, NSAttributedString *attributedStringOrNil)){
    [blockSelf generateWatchedPostCustomLabelWithStats:[ABActionMenuWatchedPostStatistics watchedPostTwoStats] defaultTitle:nodeTitle userInfo:userInfo callOnCompleteAction:callOnCompleteAction];
  };
  [watchedPostNode2 setOnTapWithUserInfo:^(NSObject<NSCoding> *userInfo) {
    [blockSelf handleTapOnWatchedPostWithUserInfo:userInfo];
  }];

 return @[
          nightSwitchNode,
          lastSubmittedPostNode,
          lastSubmittedCommentNode,
          subredditShortcutNode1,
          subredditShortcutNode2,
          watchedPostNode1,
          watchedPostNode2,
          ];
}

- (void)handleTapOnWatchedPostWithUserInfo:(id)userInfo;
{
  ABActionMenuPostRecord *watchedPostRecord = (ABActionMenuPostRecord *)userInfo;
  if (!watchedPostRecord)
    return;
  
  [Post fetchPostInformationWithName:watchedPostRecord.votableElementName onComplete:^(Post *postOrNil) {
    if (postOrNil)
    {
      [[NavigationManager shared] showCommentsForPost:postOrNil contextId:nil fromController:nil];
    }
  }];
}

- (void)generateWatchedPostCustomLabelWithStats:(ABActionMenuWatchedPostStatistics *)stats defaultTitle:(NSString *)nodeTitle userInfo:(id)userInfo callOnCompleteAction:(void (^)(NSString *, NSAttributedString *))callOnCompleteAction;
{
  ABActionMenuPostRecord *watchedPostRecord = (ABActionMenuPostRecord *)userInfo;
  if (!watchedPostRecord)
    return;
  
  if (JMIsEmpty(watchedPostRecord.votableElementName))
    return;
  
  if (stats.shouldRestrictNetworkUpdateBasedOnRateLimiting)
  {
    callOnCompleteAction(nil, stats.attributedStringBasedOnLatestStats);
    return;
  }
  
  [Post fetchPostInformationWithName:watchedPostRecord.votableElementName onComplete:^(Post *postOrNil) {
    if (!postOrNil)
    {
      callOnCompleteAction(nodeTitle, nil);
      return;
    }
    
    [stats updateBasedOnReceivedPost:postOrNil];
    callOnCompleteAction(nil, stats.attributedStringBasedOnLatestStats);
  }];
}

- (NSArray *)generateScreenSpecificActionMenuNodes;
{
  return [NSArray new];
}

- (NSString *)friendlyName;
{
  return @"base";
}

#pragma mark - JMActionMenuViewDelegate

- (NSArray *)nodesForActionMenuView:(JMActionMenuView *)actionMenuView;
{
  if (!self.actionMenuNodes)
  {
    NSMutableArray *actionMenuNodes = [NSMutableArray new];
    [actionMenuNodes addObjectsFromArray:[self generateSharedHighPriorityActionMenuNodes]];
    [actionMenuNodes addObjectsFromArray:[self generateScreenSpecificActionMenuNodes]];
    [actionMenuNodes addObjectsFromArray:[self generateSharedLowPriorityActionMenuNodes]];
    self.actionMenuNodes = actionMenuNodes;
  }
  return self.actionMenuNodes;
}

- (NSString *)hostIdentifierForActionMenuView:(JMActionMenuView *)actionMenuView;
{
  return NSStringFromClass(self.class);
}

- (NSString *)friendlyHostNameForActionMenuView:(JMActionMenuView *)actionMenuView;
{
  return self.friendlyName;
}

- (NSArray *)relatedHostClassesWhenEditingForActionMenuView:(JMActionMenuView *)actionMenuView;
{
  return @[
     [HomeActionMenuHost class],
     [PostsActionMenuHost class],
     [CommentsActionMenuHost class],
     [PostsActionMenuHost class],
     [ABActionMenuHost class],
   ];
}

- (JMActionMenuThemeConfiguration *)themeConfigurationForActionMenuView:(JMActionMenuView *)actionMenuView;
{
  return self.themeConfiguration;
}

- (void)updateCustomNavigationBar;
{
  [self attachCustomNavigationBarIfNecessary];
  
  [self.customNavigationBar setTitleLabelText:self.parentController.title];
  [self.customNavigationBar updateWithActionMenuBarItemView:self.actionMenuView.barItemView];
}

- (Class)classForCustomNavigationBar;
{
  return [ABCustomOutlineNavigationBar class];
}

- (void)attachCustomNavigationBarIfNecessary;
{
  if (self.customNavigationBar != nil)
    return;
  
  JMOutlineViewController *controller = JMCastOrNil(self.parentController, JMOutlineViewController);
  ABCustomOutlineNavigationBar *customNavigationBar = [[self classForCustomNavigationBar] new];
  
  customNavigationBar.onBackButtonHold = ^{
    [[NavigationManager shared] showNavigationStack];
  };
  
  customNavigationBar.customOnBackButtonTap = ^{
    [[NavigationManager shared].postsNavigation customBackTapped];
  };
  
  [self willAttachCustomNavigationBar:customNavigationBar];
  [controller attachCustomNavigationBarView:customNavigationBar];
  [customNavigationBar parentControllerWillBecomeVisible];
}

- (void)willAttachCustomNavigationBar:(ABCustomOutlineNavigationBar *)customNavigationBar;
{
}

- (ABCustomOutlineNavigationBar *)customNavigationBar;
{
  JMOutlineViewController *controller = JMCastOrNil(self.parentController, JMOutlineViewController);
  return (ABCustomOutlineNavigationBar *)controller.attachedCustomNavigationBar;
}

- (void)updateActionMenuBadges;
{
  self.actionMenuNodes = nil;
  [self.actionMenuView setBadgesNeedUpdate];
}

@end
