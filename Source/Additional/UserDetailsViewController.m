#import "UserDetailsViewController.h"
#import "AlienBlueAppDelegate.h"
#import "MessagesViewController.h"
#import "PostsViewController.h"
#import "Resources.h"
#import "RedditAPI+Account.h"

#import "NSectionSpacerCell.h"
#import "NSectionTitleCell.h"
#import "NBaseOptionCell.h"

#import "UIImage+JMActionMenuAssets.h"

@interface UserDetailsViewController()
@property (strong) NSString *username;
@property (strong) NSMutableDictionary *user;
@property BOOL notFound;
@end

@implementation UserDetailsViewController

- (id)initWithUsername:(NSString *)username;
{
  JM_SUPER_INIT(init);
  self.username = username;
  self.hidesBottomBarWhenPushed = YES;
  return self;
}

- (void)refreshNodes;
{
  NSMutableArray *nodes = [NSMutableArray new];
  
  SectionTitleNode *overviewSectionTitleNode = [SectionTitleNode nodeForTitle:@"Overview"];
  [nodes addObject:overviewSectionTitleNode];
  
  UIColor *valueColor = [UIColor colorForHighlightedOptions];
  UIColor *iconColor = [UIColor colorForAccessoryButtons];
  
  OptionNode *userNameNode = [OptionNode new];
  userNameNode.valueTitle = self.user ? self.user[@"name"] : @"Loading ...";
  userNameNode.title = @"Username";
  userNameNode.valueColor = valueColor;
  userNameNode.icon = [UIImage actionMenuIconWithName:@"am-icon-global-karma" fillColor:iconColor];
  [nodes addObject:userNameNode];
  
  OptionNode *accountAgeNode = [OptionNode new];
  accountAgeNode.title = @"Account Age";
  accountAgeNode.icon = [UIImage actionMenuIconWithName:@"am-icon-posts-message-mods" fillColor:iconColor];
  NSString *accountCreatedTimeString = [NSString formattedTimeToDaysFromReferenceTime:[[self.user valueForKey:@"created_utc"] floatValue]];
  accountAgeNode.valueTitle = accountCreatedTimeString;
  accountAgeNode.valueColor = valueColor;
  [nodes addObject:accountAgeNode];
  
  BSELF(UserDetailsViewController);
  
  OptionNode *sendMessageNode = [OptionNode new];
  sendMessageNode.title = @"Send Private Message";
  sendMessageNode.icon = [UIImage actionMenuIconWithName:@"am-icon-global-inbox" fillColor:iconColor];
  [sendMessageNode setDisclosureStyle:OptionDisclosureStyleArrow];
  sendMessageNode.onSelect = ^{
    [[NavigationManager shared] showSendDirectMessageScreenForUser:blockSelf.username];
  };
  
  if (![[RedditAPI shared].authenticatedUser jm_matches:self.username])
  {
    [nodes addObject:sendMessageNode];
  }
  
  SectionSpacerNode *spacerNode = [SectionSpacerNode spacerNode];
  [nodes addObject:spacerNode];
  
  SectionTitleNode *contributionsSectionTitleNode = [SectionTitleNode nodeForTitle:@"Contributions"];
  [nodes addObject:contributionsSectionTitleNode];
  
  OptionNode *submittedPostsNode = [OptionNode new];
  submittedPostsNode.title = @"Submitted Posts";
  [submittedPostsNode setDisclosureStyle:OptionDisclosureStyleArrow];
  submittedPostsNode.icon = [UIImage actionMenuIconWithName:@"am-icon-global-goto-last-submitted-post" fillColor:iconColor];
  submittedPostsNode.valueColor = valueColor;
  NSString *postKarma = [NSString formattedNumberPrefixedWithPlusOrMinus:[[self.user valueForKey:@"link_karma"] integerValue]];
  submittedPostsNode.valueTitle = postKarma;
  submittedPostsNode.onSelect = ^{
    [blockSelf showPostsForUser];
  };
  [nodes addObject:submittedPostsNode];
  
  OptionNode *submittedCommentsNode = [OptionNode new];
  submittedCommentsNode.title = @"Submitted Comments";
  submittedCommentsNode.icon = [UIImage actionMenuIconWithName:@"am-icon-global-goto-last-submitted-comment" fillColor:iconColor];
  [submittedCommentsNode setDisclosureStyle:OptionDisclosureStyleArrow];
  submittedCommentsNode.valueColor = valueColor;
  NSString *commentKarma = [NSString formattedNumberPrefixedWithPlusOrMinus:[[self.user valueForKey:@"comment_karma"] integerValue]];
  submittedCommentsNode.valueTitle = commentKarma;
  submittedCommentsNode.onSelect = ^{
    [blockSelf showCommentsForUser];
  };
  [nodes addObject:submittedCommentsNode];
  
  if (self.notFound)
  {
    userNameNode.valueTitle = @"Not Found";
    userNameNode.disabled = YES;
    accountAgeNode.disabled = YES;
    sendMessageNode.disabled = YES;
    submittedPostsNode.disabled = YES;
    submittedCommentsNode.disabled = YES;
  }
  
  [self removeAllNodes];
  [self addNodes:nodes];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setNavbarTitle:self.username];
  [self refreshNodes];
  if (!self.user)
  {
    [[RedditAPI shared] fetchUserInfo:self.username withCallback:self];
  }
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)userInfoResponse:(id)response
{
	if (response)
	{
		self.user = [NSMutableDictionary dictionaryWithDictionary:response];
	}
	else 
	{
		self.notFound = YES;
	}

	[self refreshNodes];
}

- (void)viewWillDisappear:(BOOL)animated;
{
  [super viewWillDisappear:animated];
  [[RedditAPI shared] resetConnectionsForUserDetails];
}

- (void)showCommentsForUser
{
  NSString *boxUrl = [NSString stringWithFormat:@"/user/%@/comments/", self.username];
  MessagesViewController *controller = [[UNIVERSAL(MessagesViewController) alloc] initWithBoxUrl:boxUrl];
  controller.title = [NSString stringWithFormat: @"%@", self.username];
	[[NavigationManager shared].postsNavigation pushViewController:controller animated:YES];
}

- (void)showPostsForUser
{
  NSString *sr = [NSString stringWithFormat: @"/user/%@/submitted/", self.username];
  NSString *postsTitle = [NSString stringWithFormat: @"%@", self.username];
  PostsViewController *postsView = [[UNIVERSAL(PostsViewController) alloc] initWithSubreddit:sr title:postsTitle];
	[postsView setNavbarTitle:[NSString stringWithFormat: @"%@", self.username]];
	[[NavigationManager shared].postsNavigation pushViewController:postsView animated:YES];
}

- (NSString *)customScreenNameForAnalytics;
{
  return @"User Details";
}

@end
