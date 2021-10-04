//
//  RedditsViewController+Subscriptions.m
//  AlienBlue
//
//  Created by J M on 8/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsViewController+Subscriptions.h"
#import "RedditAPI.h"
#import "Subreddit.h"
#import "NSectionTitleCell.h"
#import "NBaseOptionCell.h"
#import "UserSubredditPreferences.h"
#import "EMAddNoteViewController.h"
#import "Resources.h"
#import "NSubredditCell.h"
#import "NSectionSpacerCell.h"
#import "NSubredditFolderCell.h"
#import "Subreddit+API.h"
#import "RedditAPI+Account.h"
#import "UIImage+Resize.h"
#import "SessionManager.h"
#import "SubredditSidebarViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "JMTextViewController.h"
#import "RedditAddController.h"
#import "MKStoreManager.h"

@interface RedditsViewController(Subscriptions_)
- (void)showRedditEntryViewForFolderNode:(SubredditFolderNode *)folderNode;
@end

@implementation RedditsViewController (Subscriptions)

SYNTHESIZE_ASSOCIATED_STRONG(NSMutableArray, subscribedReddits, SubscribedReddits)
SYNTHESIZE_ASSOCIATED_STRONG(AFHTTPRequestOperation, loadSubredditsOperation, LoadSubredditsOperation);
SYNTHESIZE_ASSOCIATED_BOOL(forceServerRefresh, ForceServerRefresh);
SYNTHESIZE_ASSOCIATED_BOOL(isSyncing, IsSyncing);

- (UserSubredditPreferences *)subredditPrefs;
{
    return [[SessionManager manager] subredditPrefs];
}

- (void)syncSubscriptions;
{
    [[SessionManager manager] switchUserSubredditPreferencesToAuthenticatedUser];
    
    if (![[RedditAPI shared] authenticated])
    {        
        [self generateNodes];
        return;
    }
    
    self.isSyncing = YES;
    
    BSELF(RedditsViewController);
    self.loadSubredditsOperation = [Subreddit fetchSubscribedSubredditsUsingCache:!self.forceServerRefresh onComplete:^(NSArray *newSubreddits) {
        blockSelf.forceServerRefresh = NO;
        blockSelf.isSyncing = NO;
        blockSelf.loadSubredditsOperation = nil;
        if (newSubreddits && [newSubreddits count] > 0)
        {
            [blockSelf.subredditPrefs syncServerRetrievedSubredditsToSubscribed:newSubreddits];
        }
        [blockSelf generateNodes];
    }];
}

- (void)showSidebarInfoForSubreddit:(NSString *)subredditTitle;
{
  SubredditSidebarViewController *controller = [[SubredditSidebarViewController alloc] initWithSubredditNamed:subredditTitle];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)addSectionForSubredditFolder:(SubredditFolder *)folder editable:(BOOL)editable;
{
    BSELF(RedditsViewController);
    
    BOOL isSubscriptionFolder = (folder == blockSelf.subredditPrefs.folderForSubscribedReddits);
    
    SubredditFolderNode *folderNode = [SubredditFolderNode folderNodeForFolder:folder];
    folderNode.editable = editable && self.tableView.editing;
    folderNode.collapsable = YES;
    folderNode.onSelect = ^{
        NSString *aggregateUrl = isSubscriptionFolder ? @"" : [folder aggregateUrl];
        NSString *title = isSubscriptionFolder ? @"Front Page" : folder.title;
        [blockSelf showPostsForSubreddit:aggregateUrl withTitle:title];
    };
        
    BOOL showAddIcon = (folderNode.editable && folderNode.collapsable);

    if (showAddIcon)
    {
        __block __ab_weak SubredditFolderNode *weakFolderNode = folderNode;
        UIImage *secondaryIcon = [UIImage skinImageNamed:@"icons/add-button-rounded" withColor:[UIColor colorForHighlightedOptions]];
        folderNode.secondaryIcon = secondaryIcon;
        folderNode.secondaryAction = ^{
            [blockSelf showRedditEntryViewForFolderNode:weakFolderNode];
        };
    } else if (isSubscriptionFolder)
    {
        UIColor *iconColor = blockSelf.isSyncing ? [UIColor colorForBackgroundAlt] : [UIColor colorForAccessoryButtons];
        UIImage *secondaryIcon = [UIImage skinImageNamed:@"icons/sync" withColor:iconColor];
        if (blockSelf.isSyncing)
        {
            folderNode.title = @"Syncing ...";
        }
        folderNode.secondaryIcon = secondaryIcon;
        folderNode.secondaryAction = ^{
            blockSelf.forceServerRefresh = YES;
            [blockSelf syncSubscriptions];
            [blockSelf animateNodeChanges];
        };
    }
    else
    {
        [folderNode setDisclosureStyle:OptionDisclosureStyleArrow];
    }
    
    [self addNode:folderNode];
    
    [folder.subreddits each:^(Subreddit *sr) {
        SubredditNode *srNode = [SubredditNode nodeForSubreddit:sr];
        [blockSelf addNode:srNode];
        srNode.editable = editable;
        srNode.hiddenThumbnail = ![UDefaults boolForKey:kABSettingKeyShowSubredditIcons];
        srNode.onSelect = ^{
            [blockSelf showPostsForSubreddit:sr.url withTitle:sr.title];
        };
        UIImage *disclosureImage = [UIImage skinIcon:@"tiny-disclosure-icon" withColor:[UIColor colorForAccessoryButtons]];
        srNode.secondaryIcon = (blockSelf.tableView.editing) ? nil : disclosureImage;
        srNode.secondaryAction = ^{
            [blockSelf showSidebarInfoForSubreddit:sr.title];
        };
        [folderNode addChildNode:(JMOutlineNode *)srNode];
    }];
    
//    OptionNode *addMoreNode = [self addOptionNodeWithTitle:@"Add a subreddit" icon:nil onTap:nil onSecondary:nil];
//    addMoreNode.disabled = blockSelf.tableView.editing;
//    addMoreNode.onSelect = ^{
//        [blockSelf showRedditEntryViewForFolder:folder];
//    };
    
    SectionSpacerNode *spacerNode = [self addSpacerNode];
    [folderNode addChildNode:(JMOutlineNode *)spacerNode];
    
    if (folder.collapsed)
    {
        [folderNode collapseNode];
    }

}

- (void)addRedditsSection;
{
    if (![[RedditAPI shared] authenticatedUser] || [[[RedditAPI shared] authenticatedUser] isEmpty] )
    {
        [self addSectionForSubredditFolder:[UserSubredditPreferences defaultSubredditsFolder] editable:NO];
        return;
    }
    
    BSELF(RedditsViewController);
    [self.subredditPrefs.subredditFolders each:^(SubredditFolder *folder) {
        [blockSelf addSectionForSubredditFolder:folder editable:YES];
    }];
}

- (void)showRedditEntryViewForFolderNode:(SubredditFolderNode *)folderNode;
{
//    if (folderNode.subredditFolder != self.subredditPrefs.folderForCasualReddits)
//    {
//      REQUIRES_PRO;
//    }
    RedditAddController *controller = [[UNIVERSAL(RedditAddController) alloc] initWithDestinationFolder:folderNode.subredditFolder];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
