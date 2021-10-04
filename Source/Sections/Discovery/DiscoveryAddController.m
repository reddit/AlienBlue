//
//  DiscoveryAddController.m
//  AlienBlue
//
//  Created by J M on 17/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "DiscoveryAddController.h"
#import "ABNavigationController.h"

#import "NavigationManager.h"
#import "NavigationManager+Deprecated.h"
#import "SubredditFolder.h"
#import "NBaseOptionCell.h"
#import "NDiscoveryOptionCell.h"
#import "NSectionSpacerCell.h"
#import "Subreddit+API.h"
#import "RedditsViewController.h"
#import "SessionManager.h"
#import "FoldersViewController.h"
#import "SessionManager.h"
#import "Resources.h"

@interface DiscoveryAddController()
@property (strong) Subreddit *subreddit;
@property (strong) NSMutableArray *selectedFolderIdents;

@property (copy) ABAction onComplete;
@property (strong) UIBarButtonItem *addButton;

@property BOOL optionShowInFrontPage;
@property BOOL optionRememberSettings;
@property BOOL excludeDontShowOption;
@property BOOL excludeRemoveOption;

@property (readonly) BOOL isCasualFolderSelected;
@property (readonly) BOOL isSubscribedFolderSelected;

- (id)initWithSubreddit:(Subreddit *)subreddit onComplete:(ABAction)onComplete;
- (void)generateNodes;
- (void)animateNodeChanges;

- (void)loadDefaults;
- (void)saveDefaults;

- (void)saveSubredditFolderAssociations;
- (void)trimOutdatedFolders;
@end

@implementation DiscoveryAddController

+ (UINavigationController *)navControllerForAddingSubreddit:(Subreddit *)subreddit onComplete:(ABAction)onComplete excludeDontShowOption:(BOOL)excludeDontShow excludeRemoveOption:(BOOL)excludeRemoveOption;
{
    DiscoveryAddController *controller = [[[self class] alloc] initWithSubreddit:subreddit onComplete:onComplete];
    controller.excludeDontShowOption = excludeDontShow;
    controller.excludeRemoveOption = excludeRemoveOption;
    UINavigationController *navController = [[ABNavigationController alloc] initWithRootViewController:controller];
    return navController;    
}

+ (UINavigationController *)navControllerForAddingSubreddit:(Subreddit *)subreddit onComplete:(ABAction)onComplete;
{
    return [[self class] navControllerForAddingSubreddit:subreddit onComplete:onComplete excludeDontShowOption:NO excludeRemoveOption:NO];
}

- (id)initWithSubreddit:(Subreddit *)subreddit onComplete:(ABAction)onComplete;
{
    self = [super init];
    if (self)
    {
        self.subreddit = subreddit;
        self.onComplete = onComplete;
        self.selectedFolderIdents = [NSMutableArray array];

        UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
        BSELF(DiscoveryAddController);
        [[subredditPrefs foldersContainingSubreddit:subreddit] each:^(SubredditFolder *folder) {
            [blockSelf.selectedFolderIdents addObject:folder.ident];
        }];
        
        self.title = @"Choose Group(s)";
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
        [self setNavbarTitle:self.title];
        
//        UIBarButtonItem *manageGroupsItem = [[UIBarButtonItem alloc] initWithTitle:@"Groups" style:UIBarButtonItemStyleBordered target:self action:@selector(manageGroupsPressed)];
        UIBarButtonItem *manageGroupsItem = [UIBarButtonItem skinBarItemWithTitle:@"Groups" target:self action:@selector(manageGroupsPressed)];
      
//        self.addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add to Group" style:UIBarButtonItemStyleDone target:self action:@selector(addPressed)];
//        self.addButton.tintColor = [UIColor colorWithHex:0x6d9f60];
//        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        self.toolbarItems = [NSArray arrayWithObjects:manageGroupsItem, nil];
    }
    return self;
}

- (void)dismissGroupManagement;
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void)manageGroupsPressed;
{
    BSELF(DiscoveryAddController);
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
    FoldersViewController *controller = [[FoldersViewController alloc] initWithSubredditPreferences:subredditPrefs onComplete:^{
        [blockSelf trimOutdatedFolders];
        [blockSelf dismissGroupManagement];
        [blockSelf animateNodeChanges];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)dismissAddController;
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addPressed;
{
    [self saveSubredditFolderAssociations];
    if (self.onComplete)
    {
        self.onComplete();
    }
    [self dismissAddController];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [self saveSubredditFolderAssociations];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [self generateNodes];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [[NavigationManager shared] deprecated_exitFullscreenMode];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (BOOL)isFolderSelected:(SubredditFolder *)folder;
{
    return [self.selectedFolderIdents containsObject:folder.ident];
}

- (void)selectFolder:(SubredditFolder *)folder;
{
    [self.selectedFolderIdents addObject:folder.ident];
}

- (void)deselectFolder:(SubredditFolder *)folder;
{
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
    if (folder == subredditPrefs.folderForSubscribedReddits && self.isSubscribedFolderSelected)
    {
        [Subreddit unsubscribeToSubredditWithUrl:self.subreddit.url];
    }
    [folder removeSubreddit:self.subreddit];
    
    [self.selectedFolderIdents removeObject:folder.ident];
}

- (void)toggleSelectionForFolder:(SubredditFolder *)folder;
{
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
    if (![self.selectedFolderIdents containsObject:folder.ident])
    {
        if (self.isSubscribedFolderSelected && folder == subredditPrefs.folderForCasualReddits)
            [self deselectFolder:subredditPrefs.folderForSubscribedReddits];
        else if (self.isCasualFolderSelected && folder == subredditPrefs.folderForSubscribedReddits)
            [self deselectFolder:subredditPrefs.folderForCasualReddits];
        
        [self selectFolder:folder];
    }
    else
    {
        [self deselectFolder:folder];
    }

    [self saveDefaults];
    [self animateNodeChanges];
}

- (NSUInteger)numFoldersSelected;
{
    return self.selectedFolderIdents.count;
}

- (BOOL)shouldShowFrontPageOption;
{
    if ([self numFoldersSelected] == 0)
        return NO;
    
    return (!self.isCasualFolderSelected && !self.isSubscribedFolderSelected);
}

- (void)toggleShowInFrontPageOption;
{
    self.optionShowInFrontPage = !self.optionShowInFrontPage;
    [self saveDefaults];
}

- (void)toggleRememberSettingsOption;
{
    self.optionRememberSettings = !self.optionRememberSettings;
    [self saveDefaults];
}

- (void)saveDefaults;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:self.optionShowInFrontPage forKey:@"discovery_optionShowInFrontPage"];
    [prefs setBool:self.optionRememberSettings forKey:@"discovery_optionRememberSettings"];
    [prefs setObject:self.selectedFolderIdents forKey:@"discovery_selectedFolders"];

    [prefs synchronize];
}

- (void)trimOutdatedFolders;
{
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
    self.selectedFolderIdents = [NSMutableArray arrayWithArray:[self.selectedFolderIdents reject:^BOOL(NSString *folderIdent) {
        return [subredditPrefs folderMatchingIdent:folderIdent] == nil;
    }]];
}

- (void)loadDefaults;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.optionShowInFrontPage = [prefs boolForKey:@"discovery_optionShowInFrontPage"];
    self.optionRememberSettings = [prefs boolForKey:@"discovery_optionRememberSettings"];
    
    NSArray *lastFolderSet = [prefs objectForKey:@"discovery_selectedFolders"];
    if (lastFolderSet)
    {
        [self.selectedFolderIdents addObjectsFromArray:lastFolderSet];
    }
    [self trimOutdatedFolders];
      
    // persist the selectedFolders if they haven't been stored previously
    [self saveDefaults];
}

+ (BOOL)shouldAddWithoutView;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"discovery_optionRememberSettings"];
}

+ (void)resetDontAskOption;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"discovery_optionRememberSettings"];
    [prefs synchronize];
}

+ (void)processAutomaticAddingOfSubreddit:(Subreddit *)subreddit onComplete:(ABAction)onComplete;
{
    if (![DiscoveryAddController shouldAddWithoutView])
    {
        return;        
    }
    
    DiscoveryAddController *controller = [[DiscoveryAddController alloc] initWithSubreddit:subreddit onComplete:nil];
    [controller loadDefaults];
    [controller saveSubredditFolderAssociations];
    if (onComplete)
    {
        onComplete();
    }
}

- (BOOL)isSubscribedFolderSelected;
{
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
    return [self isFolderSelected:subredditPrefs.folderForSubscribedReddits];
}

- (BOOL)isCasualFolderSelected;
{
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
    return [self isFolderSelected:subredditPrefs.folderForCasualReddits];    
}

- (void)saveSubredditFolderAssociations;
{
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];

    NSArray *selectedFolders = [self.selectedFolderIdents map:^id(NSString *folderIdent) {
        return [subredditPrefs.subredditFolders match:^BOOL(SubredditFolder *folder) {
            return [folder.ident equalsString:folderIdent];
        }];
    }];
    
    BSELF(DiscoveryAddController);
        
    [selectedFolders each:^(SubredditFolder *selectedFolder) {
        [subredditPrefs addSubreddit:blockSelf.subreddit toFolder:selectedFolder];
    }];
    
    if ((self.isSubscribedFolderSelected || self.optionShowInFrontPage) && !self.isCasualFolderSelected)
    {
        [Subreddit subscribeToSubredditWithUrl:self.subreddit.url];
        [subredditPrefs addSubreddit:self.subreddit toFolder:subredditPrefs.folderForSubscribedReddits];
    }
    
    [subredditPrefs checkSyncThreshold];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRedditGroupsDidChangeNotification object:nil];
}

- (void)addRemoveAllSection;
{
    BSELF(DiscoveryAddController);
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
    BOOL isSubbed = [subredditPrefs.folderForSubscribedReddits containsSubreddit:self.subreddit];
    DiscoveryOptionNode *removeNode = [[DiscoveryOptionNode alloc] init];
    removeNode.backgroundColor = [UIColor colorWithHex:0xcf0000];
    removeNode.titleColor = [UIColor whiteColor];
    NSString *title = isSubbed ? @"Remove & Unsubscribe" : @"Remove from All Groups";
    removeNode.title = title;
    removeNode.bold = YES;
    removeNode.hidesTitleShadow = YES;
    removeNode.onSelect = ^{
        [subredditPrefs removeSubredditFromAllFolders:blockSelf.subreddit];
        [blockSelf.selectedFolderIdents removeAllObjects];
        [blockSelf saveSubredditFolderAssociations];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRedditGroupsDidChangeNotification object:nil];
        [blockSelf dismissAddController];
    };
    [self addNode:removeNode];
}

- (void)generateNodes;
{
    [self removeAllNodes];

    UIImage *offIcon = [UIImage skinImageNamed:@"icons/state-off" withColor:[UIColor colorForAccessoryButtons]];
    UIImage *onIcon = [UIImage skinImageNamed:@"icons/state-on" withColor:[UIColor colorWithHex:0x6d9f60]];
    UIImage *onIconGray = [UIImage skinImageNamed:@"icons/state-on" withColor:[UIColor colorForAccessoryButtons]];
    
    BSELF(DiscoveryAddController);
    
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
    
    
    BOOL listedInUserFolder = [subredditPrefs folderContainingSubreddit:self.subreddit] != nil;
    if (!self.excludeRemoveOption && listedInUserFolder)
    {
        [self addRemoveAllSection];
    }
    
    [subredditPrefs.subredditFolders each:^(SubredditFolder *folder) {
        OptionNode *node = [[OptionNode alloc] init];
        node.title = folder.title;
        node.icon = [blockSelf isFolderSelected:folder] ? onIcon : offIcon;
        node.onSelect = ^{
            [blockSelf toggleSelectionForFolder:folder];
        };
        [blockSelf addNode:node];
    }];
    
    SectionSpacerNode *spacerNode = [SectionSpacerNode spacerNode];
    spacerNode.backgroundColor = [UIColor colorForBackgroundAlt];
    [self addNode:spacerNode];
    
    if (self.shouldShowFrontPageOption)
    {
        DiscoveryOptionNode *showInFrontPage = [[DiscoveryOptionNode alloc] init];
        showInFrontPage.secondaryIcon = (self.optionShowInFrontPage) ? onIconGray : offIcon;
        showInFrontPage.onSelect = ^{
            [blockSelf toggleShowInFrontPageOption];
            [blockSelf animateNodeChanges];
        };
        showInFrontPage.title = @"Include in my Front Page";
        [self addNode:showInFrontPage];
    }

    if (!self.excludeDontShowOption)
    {
        DiscoveryOptionNode *rememberSettings = [[DiscoveryOptionNode alloc] init];
        rememberSettings.secondaryIcon = (self.optionRememberSettings) ? onIconGray : offIcon;
        rememberSettings.onSelect = ^{
            [blockSelf toggleRememberSettingsOption];
            [blockSelf animateNodeChanges];
        };    
        rememberSettings.title = @"Don't ask me again";
        rememberSettings.titleColor = (self.optionRememberSettings) ? [UIColor colorWithHex:0xf86b6b] : [UIColor grayColor];
        rememberSettings.subtitle = @"(resets when leaving this category)";
        [self addNode:rememberSettings];
    }
    
    [self reload];
}

- (void)animateNodeChanges;
{
    BSELF(DiscoveryAddController);
    [UIView jm_transition:self.tableView animations:^{
        [blockSelf generateNodes];
    } completion:nil animated:YES];
}

@end
