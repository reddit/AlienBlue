#import "RedditsViewController.h"
#import "RedditsViewController+Subscriptions.h"
#import "RedditsViewController+EditSupport.h"
#import "RedditsViewController+MyRedditInfo.h"
#import "RedditsViewController+Announcement.h"
#import "RedditsViewController+Discovery.h"

#import "RedditAPI+Announcements.h"

#import "NSubredditCell.h"
#import "NSectionTitleCell.h"
#import "NSectionSpacerCell.h"
#import "NSubredditFolderCell.h"
#import "AlienBlueAppDelegate.h"
#import "FoldersViewController.h"
#import "RedditAPI+Account.h"
#import "RedditAPI+Posts.h"
#import "Resources.h"
#import "JMOutlineViewController+Keyboard.h"
#import "UIAlertView+BlocksKit.h"
#import "MKStoreManager.h"

@interface RedditsViewController ()
@property(strong, nonatomic) NSString *currentUsername;
- (void)generateNodes;
- (void)didSwitchUserAccounts;
@end

@implementation RedditsViewController

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserSwitchNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRedditGroupsDidChangeNotification object:nil];
}

- (id)init;
{
    if ((self = [super init]))
    {
        self.currentUsername = [RedditAPI shared].authenticatedUser;

        [self enableKeyboardReaction];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwitchUserAccounts) name:kUserSwitchNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateNodeChanges) name:kRedditGroupsDidChangeNotification object:nil];
        
        self.loadSubredditsOperation = nil;

        [self setNavbarTitle:@"reddit"];
        
        [self disableEditMode];
    }
    return self;
}

- (void)didSwitchUserAccounts;
{
    // give the karma variables a chance to populate
    [self performSelector:@selector(syncSubscriptions) withObject:nil afterDelay:1.0];
}

- (void)prepareLoggedInUser;
{
    self.currentUsername = [RedditAPI shared].authenticatedUser;
    [self generateNodes];
    [self syncSubscriptions];    
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [self performSelector:@selector(prepareLoggedInUser) withObject:nil afterDelay:0.4];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self checkAnnouncements];
    if (self.tableView.isEditing)
    {
      [self enableEditMode];
    }
}

- (void)viewWillDisappear:(BOOL)animated;
{
  [super viewWillDisappear:animated];
  [[RedditAPI shared] clearAnnouncementCheckCallbacks];
}

- (void)respondToStyleChange;
{
    [super respondToStyleChange];
    [self generateNodes];
}

- (void)viewDidUnload;
{
    [super viewDidUnload];
    [self.loadSubredditsOperation cancel];
    self.loadSubredditsOperation = nil;
}

- (void)sortFoldersAlphabetically;
{
    BSELF(RedditsViewController);
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Sort Alphabetically" message:@"You will lose manual arrangements of subreddits if you proceed."];
    [alert bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [alert bk_addButtonWithTitle:@"Sort" handler:^{
        [blockSelf.subredditPrefs sortAllFolders];
        [blockSelf animateNodeChanges];
    }];
    [alert show];
}

- (void)dismissFolderManagementView;
{
    [[NavigationManager shared] dismissModalView];
}

- (void)showFolderManagementView;
{
//    REQUIRES_PRO;
    BSELF(RedditsViewController);
    UINavigationController *navController = [FoldersViewController navControllerWithSubredditPreferences:self.subredditPrefs onComplete:^{
        [blockSelf generateNodes];
        [blockSelf dismissFolderManagementView];
    }];

    [[NavigationManager mainViewController] presentModalViewController:navController animated:YES];
}

- (void)showPostsForSubreddit:(NSString *)sr withTitle:(NSString *)title
{
    [[RedditAPI shared] resetConnectionsForPosts];
  
    BOOL animatePop = [Resources isIPAD] ? YES : NO;
    [[NavigationManager shared].postsNavigation popToRootViewControllerAnimated:animatePop];
    [NavigationManager shared].postsNavigation.navigationItem.title = @"reddit";
    [[NavigationManager shared] showPostsForSubreddit:sr title:title animated:YES];
}

#pragma mark -
#pragma mark - Convenience Methods for Adding Common Nodes

- (OptionNode *)addOptionNodeWithTitle:(NSString *)title icon:(UIImage *)icon onTap:(ABAction)onTap onSecondary:(ABAction)onSecondary;
{
    OptionNode *optionNode = [[OptionNode alloc] init];
    optionNode.title = title;
    optionNode.icon = icon;    
    [self addNode:optionNode];
    return optionNode;
}

- (OptionNode *)addOptionNodeWithTitle:(NSString *)title icon:(UIImage *)icon;
{
    return [self addOptionNodeWithTitle:title icon:icon onTap:nil onSecondary:nil];
}

- (SubredditNode *)addCustomSubredditNodeWithTitle:(NSString *)title url:(NSString *)url;
{
    BSELF(RedditsViewController);
    Subreddit *sr = [[Subreddit alloc] init];
    sr.title = title;
    sr.url = url;
    SubredditNode *subredditNode = [SubredditNode nodeForSubreddit:sr];
    subredditNode.hiddenThumbnail = [url length] == 0 || [url equalsString:@"/r/all/"];
    [subredditNode setDisclosureStyle:OptionDisclosureStyleArrow];
    subredditNode.onSelect = ^{
        [blockSelf showPostsForSubreddit:url withTitle:title];
    };
    [self addNode:subredditNode];
    return subredditNode;
}

- (SectionTitleNode *)addSectionTitleNodeWithTitle:(NSString *)title;
{
    SectionTitleNode *titleNode = [SectionTitleNode nodeForTitle:title];
    [self addNode:titleNode];
    return titleNode;
}

- (SectionSpacerNode *)addSpacerNode;
{
    SectionSpacerNode *spacerNode = [SectionSpacerNode spacerNode];
    [self addNode:spacerNode];
    return spacerNode;
}

#pragma mark -
#pragma mark - Sections

- (void)addFrontPageSection;
{
    [self addSpacerNode];

    SubredditNode *fpNode = [self addCustomSubredditNodeWithTitle:@"Front Page" url:@""];
    fpNode.bold = YES;
    
    [self addCustomSubredditNodeWithTitle:@"All Subreddits" url:@"/r/all/"];
    [self addSpacerNode];
}

- (void)animateNodeChanges;
{
    BSELF(RedditsViewController);
    [UIView jm_transition:self.tableView animations:^{
        [blockSelf generateNodes];
    } completion:nil animated:YES];
}

- (void)toggleSubredditFolderCollapseForNode:(SubredditFolderNode *)folderNode;
{
    folderNode.subredditFolder.collapsed = !folderNode.subredditFolder.collapsed;
    [self toggleNode:folderNode];
    [self.subredditPrefs save];
}

- (void)generateNodes;
{
    [self removeAllNodes];

#if ALIEN_BLUE
    [self addFrontPageSection];

    [self addAnnouncementSection];
    
    [self addInfoSection];
#endif
    [self addRedditsSection];
    [self addDiscoverySection];

    [self reload];
}

@end
