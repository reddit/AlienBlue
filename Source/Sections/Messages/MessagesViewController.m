#import "MessagesViewController.h"
#import "MessagesViewController+API.h"
#import "MessagesViewController+LinkHandling.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "MessagesNavigationBar.h"
#import "PostsFooterCoordinator.h"
#import "NMessageCell.h"
#import "JMTabView.h"
#import "Resources.h"
#import "NavigationManager.h"
#import "RedditAPI+Account.h"
#import "RedditAPI+Messages.h"
#import "SessionManager+Authentication.h"
#import "PostsShowMoreButton.h"

#import "MessageBoxSelectionBackgroundLayer.h"
#import "MessageBoxTabItem.h"
#import "MessageBoxSelectionView.h"

#import "NMessageSectionHeaderCell.h"
#import "NCenteredTextCell.h"

@interface MessagesViewController() <PostsFooterDelegate, JMTabViewDelegate>
@property (copy) NSString *boxUrl;
@property BOOL shouldAutomaticallyExpandLoadedMessages;
@property (strong) MessagesNavigationBar *messagesNavigationBar;
@property (strong) PostsFooterCoordinator *footerCoordinator;
@property (strong) JMTabView *boxTabView;
@property (strong) MessageBoxTabItem *moderatorTabItem;
@end

@implementation MessagesViewController

- (id)initWithBoxUrl:(NSString *)boxUrl;
{
  JM_SUPER_INIT(init);
  self.boxUrl = boxUrl;
  self.footerCoordinator = [[PostsFooterCoordinator alloc] initWithDelegate:self];
  return self;
}

- (void)loadMessagesRelatedViews;
{
  self.messagesNavigationBar = [MessagesNavigationBar new];
  BSELF(MessagesViewController);
  
  self.messagesNavigationBar.onMarkAsReadTap = ^{
    [blockSelf didTapMarkAllAsRead];
  };
  
  [self attachCustomNavigationBarView:self.messagesNavigationBar];
  [self generateBoxTabView];
  [self.messagesNavigationBar attachBoxTabView:self.boxTabView];
  
  NSString *defaultTitle = [self.boxUrl jm_contains:@"moderator"] ? @"Moderator Mail" : @"Inbox";
  [self setNavbarTitle:defaultTitle];
}

- (void)loadView;
{
  [super loadView];

  if (!self.shouldDecorateAsUserComments)
  {
    [self loadMessagesRelatedViews];
  }

  self.tableView.tableFooterView = self.footerCoordinator.view;
  [self.footerCoordinator disallowHorizontalSliderDragging];
  
  BSELF(MessagesViewController);
  self.pullRefreshView = [JMRefreshHeaderView hookRefreshHeaderToController:self onTrigger:^{
    [blockSelf fetchMessagesRemoveExisting:YES];
  }];
  self.pullRefreshView.backgroundColor = [UIColor colorForBackground];
  [self.pullRefreshView setForegroundColor : [UIColor colorForPullToRefreshForeground]];
}

//- (void)createHeadersAndFooters
//{
//  CGFloat headerHeight = 0.;
//  CGFloat footerHeight = 0.;
//  
//  UIView *headerView = nil;
//  UIView *footerView = nil;
//  if ([Resources isIPAD])
//  {
//    headerView = [self generateBoxTabView];
//  }
//  else
//  {
//    footerView = [self generateBoxTabView];
//  }
//  
//  if (headerView)
//  {
//    [self.view addSubview:headerView];
//    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    headerView.width = self.view.bounds.size.width + 2.;
//    headerHeight = headerView.frame.size.height;
//  }
//  
//  if (footerView)
//  {
//    [self.view addSubview:footerView];
//    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    footerView.width = self.view.bounds.size.width;
//    footerHeight = footerView.frame.size.height;
//    footerView.bottom = self.view.bounds.size.height;
//  }
//  
//  CGFloat tableHeight = self.view.bounds.size.height - headerHeight - footerHeight;
//  CGRect tableFrame = CGRectMake(0, headerHeight, self.view.frame.size.width, tableHeight);
//  self.tableView.frame = tableFrame;
//}

- (UIView *)generateBoxTabView;
{
  if (self.parentViewController == [NavigationManager shared].postsNavigation)
    return nil;
  
  if (self.shouldDecorateAsUserComments)
    return nil;
  
  self.boxTabView = [[JMTabView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, ([Resources isIPAD] ? 60. : 48.))];
  [self.boxTabView setBackgroundLayer:[MessageBoxSelectionBackgroundLayer new]];
  [self.boxTabView setSelectionView:[MessageBoxSelectionView new]];
  self.boxTabView.delegate = self;
  
  #define ADD_MESSAGE_TABITEM(TITLE, ICONNAME) [self.boxTabView addTabItem:[[self class] tabItemWithTitle:(JMIsIpad() ? nil : nil) skinIconName:ICONNAME]];
  
  ADD_MESSAGE_TABITEM(@"Inbox", @"message-inbox-icon");
  ADD_MESSAGE_TABITEM(@"Sent", @"message-outbox-icon");
  ADD_MESSAGE_TABITEM(@"Comments", @"message-comments-icon");
  if ([RedditAPI shared].isMod)
  {
    MessageBoxTabItem *moderatorTabItem = [[self class] tabItemWithTitle:(JMIsIpad() ? nil : nil) skinIconName:@"message-modmail-icon"];
    moderatorTabItem.forceHighlightColor = [RedditAPI shared].hasModMail ? [UIColor colorForModeratorMailAlert] : nil;
    [self.boxTabView addTabItem:moderatorTabItem];
    self.moderatorTabItem = moderatorTabItem;
  }
  
  BOOL showingModMailByDefault = [self.boxUrl jm_contains:@"moderator"];
  NSUInteger defaultIndex = showingModMailByDefault ? 3 : 0;
  [self.boxTabView setSelectedIndex:defaultIndex];
  
  return self.boxTabView;
}

+ (MessageBoxTabItem *)tabItemWithTitle:(NSString *)title skinIconName:(NSString *)skinIconName;
{
  return [[MessageBoxTabItem alloc] initWithTitle:title skinIconName:skinIconName];
}

- (BOOL)shouldDecorateAsUserComments;
{
  return [self.boxUrl jm_contains:@"/user/"];
}

- (void)expandAllMessages;
{
  [self.nodes each:^(JMOutlineNode *node) {
    if (JMIsClass(node, MessageNode) || JMIsClass(node, MessageSectionHeaderNode))
    {
      [node expandNode];
    }
    
    if (JMIsClass(node, CenteredTextNode))
    {
      [node hideNode];
    }
  }];
  [self reloadRowsForNodes:self.nodes];
  self.shouldAutomaticallyExpandLoadedMessages = YES;
}

- (NSArray *)generateMessageNodesFromMessages:(NSArray *)messages;
{
  BSELF(MessagesViewController);
  NSMutableArray *uniqueTitles = [NSMutableArray new];
  [messages each:^(Message *message) {
    [uniqueTitles jm_addUniqueStringObject:message.titleForPresentation];
  }];
  
  NSArray *messageNodes = [messages map:^id(Message *message) {
    MessageNode *messageNode = [[MessageNode alloc] initWithMessage:message];
    __block __weak MessageNode *weakMessageNode = messageNode;
    weakMessageNode.onContentsTap = ^{
      [blockSelf didTapOnMessageNodeContents:weakMessageNode];
    };
    weakMessageNode.onHeaderBarTap = ^{
      [blockSelf didTapOnMessageHeaderBarForNode:weakMessageNode];
    };
    
    if (!message.isUnread && !self.shouldAutomaticallyExpandLoadedMessages)
    {
      [messageNode collapseNode];
    }
    
    return messageNode;
  }];
  
  NSArray *topLevelNodes = [uniqueTitles map:^id(NSString *uniqueTitle) {
    MessageNode *firstMatch = [messageNodes match:^BOOL(MessageNode *mNode) {
      return [mNode.message.titleForPresentation isEqualToString:uniqueTitle];
    }];
    return firstMatch;
  }];
  
  NSArray *sectionHeaderNodes = [topLevelNodes map:^id(MessageNode *topLevelNode) {
    MessageSectionHeaderNode *headerNode = [[MessageSectionHeaderNode alloc] initWithTopLevelMessage:topLevelNode.message];
    __block __weak MessageSectionHeaderNode *weakSectionHeaderNode = headerNode;
    headerNode.onSelect = ^{
      [blockSelf didTapOnMessageSectionHeaderNode:weakSectionHeaderNode];
    };
    return headerNode;
  }];
  
  [messageNodes each:^(MessageNode *messageNode) {
    MessageSectionHeaderNode *matchingParentNode = [sectionHeaderNodes match:^BOOL(MessageSectionHeaderNode *pNode) {
      return [pNode.message.titleForPresentation jm_matches:messageNode.message.titleForPresentation];
    }];
    
    [matchingParentNode addChildNode:messageNode];
    if (messageNode.message.isUnread)
    {
      matchingParentNode.numberOfUnreadChildren++;
    }
  }];
  
  NSMutableArray *combinedNodes = [NSMutableArray new];
  [sectionHeaderNodes each:^(MessageSectionHeaderNode *pNode) {
    [combinedNodes addObject:pNode];
    [pNode.childNodes each:^(MessageNode *messageNode) {
      [combinedNodes addObject:messageNode];
    }];
  }];
  
  return combinedNodes;
}

- (void)fetchMessagesRemoveExisting:(BOOL)removeExisting;
{
  BSELF(MessagesViewController);
  
  if (!blockSelf.footerCoordinator.isShowingLoadingIndicator)
  {
    [blockSelf.footerCoordinator setShowLoadingIndicator:YES];
  }
  
  typedef void (^ProcessMessagesAction)(NSArray *messages);
  
  ProcessMessagesAction processAction = ^(NSArray *messages){
    [blockSelf deselectNodes];
    [blockSelf.footerCoordinator setShowLoadingIndicator:NO];
    [blockSelf.pullRefreshView finishedLoading];
    if (removeExisting)
    {
      [blockSelf removeAllNodes];
    }
  
    if (blockSelf.shouldDecorateAsUserComments && blockSelf.nodeCount == 0 && !blockSelf.shouldAutomaticallyExpandLoadedMessages)
    {
      CenteredTextNode *expandAllNode = [CenteredTextNode nodeWithTitle:@"Expand All"];
      expandAllNode.onSelect = ^{
        [blockSelf expandAllMessages];
      };
      [blockSelf addNode:expandAllNode];
    }
    
    NSArray *messageNodes = [blockSelf generateMessageNodesFromMessages:messages];
    [blockSelf addNodes:messageNodes];
    
    [blockSelf reload];
    
    if (removeExisting && blockSelf.tableView.contentOffset.y > 50.)
    {
      [blockSelf.tableView scrollRectToVisible:CGRectMake(0., 0., 1., 1.) animated:YES];
    }
    
    [blockSelf handleAutomarkAsReadOnServerIfNecessary];
  };
  
  [self fetchMessagesRemoveExisting:removeExisting onComplete:processAction];
}

- (void)handleAutomarkAsReadOnServerIfNecessary;
{
  if (![[UDefaults valueForKey:kABSettingKeyAutoMarkMessagesAsRead] boolValue])
    return;
  
  if ([RedditAPI shared].hasModMail && [self.boxUrl jm_contains:@"moderator"])
  {
    [[RedditAPI shared] markAllModMailAsRead];
  }
  
  if ([RedditAPI shared].hasMail && [self.boxUrl jm_contains:@"inbox"])
  {
    [[RedditAPI shared] markAllMessagesAsRead];
  }
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  if ([self.nodes count] <= 3)
  {
    [self.footerCoordinator setShowLoadingIndicator:YES];
    [self performSelector:@selector(loadMore) withObject:nil afterDelay:0.4];
  }
}

- (void)viewWillDisappear:(BOOL)animated;
{
  [self.loadMessagesOperation cancel];
  self.loadMessagesOperation = nil;
  [super viewWillDisappear:animated];
}

- (void)viewDidUnload;
{
  [self.loadMessagesOperation cancel];
  self.loadMessagesOperation = nil;
  [super viewDidUnload];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
  [super scrollViewDidScroll:scrollView];
  [self.footerCoordinator handleScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
  [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
  [self.footerCoordinator handleDragRelease];
}

- (void)loadMore;
{
  [self fetchMessagesRemoveExisting:NO];
}

- (void)collapseToRootCommentNode:(CommentNode *)commentNode;
{
  CommentNode *parentNode = (commentNode.parentNode == nil) ? commentNode : (CommentNode *)commentNode.parentNode;
  [parentNode collapseNode];
  
  NSMutableArray *affectedNodes = [NSMutableArray array];
  [affectedNodes addObject:parentNode];
  [affectedNodes addObjectsFromArray:[parentNode allChildren]];
  [self reloadRowsForNodes:affectedNodes];
  [self scrollToNode:parentNode];
}

#pragma mark -
#pragma mark JMTabViewDelegate

- (void)tabView:(JMTabView *)tabView didSelectTabAtIndex:(NSUInteger)itemIndex;
{
  NSString *title = nil;
  if (itemIndex == 0)
  {
    self.boxUrl = @"/message/inbox/";
    title = @"Inbox";
  }
  else if (itemIndex == 1)
  {
    self.boxUrl = @"/message/sent/";
    title = @"Sent Messages";
  }
  else if (itemIndex == 2)
  {
    self.boxUrl = [NSString stringWithFormat:@"/user/%@/comments/", [RedditAPI shared].authenticatedUser];
    title = @"My Comments";
  }
  else if (itemIndex == 3)
  {
    self.boxUrl = [NSString stringWithFormat:@"/message/moderator/"];
    title = @"Moderator Mail";
  }
  else
  {
    self.boxUrl = @"/message/inbox/";
    title = @"Inbox";
  }
  [self setNavbarTitle:title];
  [self fetchMessagesRemoveExisting:YES];
}

- (void)markIndividualMessageAsReadForNode:(MessageNode *)messageNode;
{
  if (!messageNode.message.isUnread)
    return;
  
  [messageNode.message markAsRead];
  MessageSectionHeaderNode *parentSectionHeader = (MessageSectionHeaderNode *)messageNode.parentNode;
  parentSectionHeader.numberOfUnreadChildren--;
  [self reloadRowsForNodes:@[parentSectionHeader, messageNode]];
  
  [self updateMarkedAsReadStatusIfNecessary];
}

- (void)updateMarkedAsReadStatusIfNecessary;
{
  NSNumber *numberOfUnreadItemsOnScreen = [self.nodes reduce:^id(NSNumber *current, MessageSectionHeaderNode *sectionHeaderNode) {
    MessageSectionHeaderNode *headerNode = JMCastOrNil(sectionHeaderNode, MessageSectionHeaderNode);
    return headerNode != nil ? @(current.unsignedIntegerValue + headerNode.numberOfUnreadChildren) : current;
  } initial:@(0)];
  
  if (numberOfUnreadItemsOnScreen.unsignedIntegerValue > 0)
    return;
  
  if ([RedditAPI shared].hasMail && [self.boxUrl jm_contains:@"inbox"])
  {
    [RedditAPI shared].hasMail = NO;
    [[RedditAPI shared] markAllMessagesAsRead];
  }
  
  if ([RedditAPI shared].hasModMail && [self.boxUrl jm_contains:@"moderator"])
  {
    [RedditAPI shared].hasModMail = NO;
    [[RedditAPI shared] markAllModMailAsRead];
    self.moderatorTabItem.forceHighlightColor = nil;
    [self.moderatorTabItem setNeedsDisplay];
  }
}

- (void)markMessageThreadAsReadForSectionHeaderNode:(MessageSectionHeaderNode *)sectionHeaderNode;
{
  if (sectionHeaderNode.numberOfUnreadChildren == 0)
    return;

  [[sectionHeaderNode childNodes] each:^(MessageNode *messageNode) {
    if (messageNode.message.isUnread)
    {
      [messageNode.message markAsRead];
      [messageNode refresh];
    }
  }];
  
  sectionHeaderNode.numberOfUnreadChildren = 0.;
  [sectionHeaderNode refresh];
  [self updateMarkedAsReadStatusIfNecessary];
}

- (void)didTapOnMessageSectionHeaderNode:(MessageSectionHeaderNode *)sectionHeaderNode;
{
  if (!self.shouldDecorateAsUserComments && !sectionHeaderNode.collapsed)
  {
    [self markMessageThreadAsReadForSectionHeaderNode:sectionHeaderNode];
  }
  [self toggleNode:sectionHeaderNode];
}

- (void)didTapOnMessageHeaderBarForNode:(MessageNode *)messageNode;
{
  if (!self.shouldDecorateAsUserComments && !messageNode.collapsed)
  {
    [self markIndividualMessageAsReadForNode:messageNode];
  }
  [self toggleNode:messageNode];
}

- (void)didTapOnMessageNodeContents:(MessageNode *)messageNode;
{
  if (!self.shouldDecorateAsUserComments && !messageNode.collapsed)
  {
    [self markIndividualMessageAsReadForNode:messageNode];
  }
  [self selectNode:messageNode];
}

- (void)didTapMarkAllAsRead;
{
  [self.nodes each:^(id item) {
    MessageNode *messageNode = JMCastOrNil(item, MessageNode);
    messageNode.message.isUnread = NO;
    [messageNode collapseNode];

    MessageSectionHeaderNode *messageSectionHeaderNode = JMCastOrNil(item, MessageSectionHeaderNode);
    messageSectionHeaderNode.message.isUnread = NO;
    messageSectionHeaderNode.numberOfUnreadChildren = 0;
  }];
  
  [self reloadRowsForNodes:self.nodes];

  [RedditAPI shared].hasMail = NO;
  [[RedditAPI shared] markAllMessagesAsRead];
  
  [RedditAPI shared].hasModMail = NO;
  if ([RedditAPI shared].isMod)
  {
    DO_AFTER_WAITING(1.5, ^{
      [[RedditAPI shared] markAllModMailAsRead];
    });

    self.moderatorTabItem.forceHighlightColor = nil;
    [self.moderatorTabItem setNeedsDisplay];
  }
  
  [[SessionManager manager] didManuallyUpdateUserInformation];
}

- (void)respondToStyleChange
{
  [super respondToStyleChange];
  self.pullRefreshView.backgroundColor = [UIColor colorForBackground];
  [self.pullRefreshView setForegroundColor : [UIColor colorForPullToRefreshForeground]];  
}

- (NSString *)customScreenNameForAnalytics;
{
  return (self.shouldDecorateAsUserComments) ? @"User Submitted Comments" : self.title;
}

@end
