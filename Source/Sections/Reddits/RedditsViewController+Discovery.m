//
//  RedditsViewController+Discovery.m
//  AlienBlue
//
//  Created by J M on 14/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsViewController+Discovery.h"
#import "RedditsViewController+Subscriptions.h"
#import "NSubredditCell.h"
#import "NSubredditFolderCell.h"
#import "NBaseOptionCell.h"
#import "NSectionSpacerCell.h"
#import "Subreddit+API.h"
#import "RedditAPI+Account.h"

#import "Resources.h"
#import "UIViewController+Additions.h"
#import "EMAddNoteViewController.h"
#import "ABNavigationController.h"
#import "SubredditManager.h"
#import "DiscoverySceneController.h"
#import "MKStoreManager.h"

#import "JMTextViewController.h"

@implementation RedditsViewController (Discovery)

- (void)showManualEntryView;
{
  BSELF(RedditsViewController);
  
  JMTextViewController *controller = [JMTextViewController controllerOnComplete:^(NSString *text) {
    NSString* sr = nil;
    NSString *trimmedText = [text stringByReplacingOccurrencesOfString:@" " withString:@""];

    if ([trimmedText rangeOfString:@"/r/"].location == NSNotFound)
      sr = [NSString stringWithFormat:@"%@%@/",@"/r/", trimmedText];
    else
      sr = [trimmedText stringByAppendingString:@"/"];
    
    if ([sr isEqualToString:@"/r/"] || [sr isEqualToString:@"/r//"])
      return;
    
    Subreddit *manualSubreddit = [Subreddit subredditWithUrl:sr name:@""];
    
    if (![Resources isIPAD])
    {
      [blockSelf.navigationController popToViewController:blockSelf animated:NO];
    }
    
    [blockSelf showPostsForSubreddit:manualSubreddit.url withTitle:manualSubreddit.title];

  } onDismiss:nil];
  controller.placeholderText = @"/r/";
  controller.defaultText = @"/r/";
  controller.preserveDefaultText = YES;
  controller.singleLine = YES;
  controller.autoCorrectionType = UITextAutocorrectionTypeNo;
  controller.title = @"Enter a Subreddit";
  
  if ([Resources isIPAD])
  {
      ABNavigationController *navc = [[ABNavigationController alloc] initWithRootViewController:controller];
      navc.modalPresentationStyle = UIModalPresentationFormSheet;
      navc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
      [[NavigationManager mainViewController] presentModalViewController:navc animated:YES];
  }
  else
  {
      [self.navigationController pushViewController:controller animated:YES];
  }
}


- (void)showLookupUserEntry
{
  BSELF(RedditsViewController);
  
  JMTextViewController *controller = [JMTextViewController controllerOnComplete:^(NSString *text) {
    if (!text || [text length] == 0)
      return;
    
    if ([text jm_matches:@"/u/"])
      return;
    
    NSString *username = [text jm_removeOccurrencesOfString:@"/u/"];
    username = [username jm_trimmed];
    
    [[NavigationManager shared].postsNavigation popToViewController:blockSelf animated:NO];
    [[NavigationManager shared] showUserDetails:username];
  } onDismiss:nil];
  controller.placeholderText = @"/u/";
  controller.defaultText = @"/u/";
  controller.preserveDefaultText = YES;
  controller.singleLine = YES;
  controller.autoCorrectionType = UITextAutocorrectionTypeNo;
  controller.title = @"Enter a Username";
  
  if ([Resources isIPAD])
  {
      ABNavigationController * navc = [[ABNavigationController alloc] initWithRootViewController:controller];
      navc.modalPresentationStyle = UIModalPresentationFormSheet;
      navc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
      [[NavigationManager mainViewController] presentModalViewController:navc animated:YES];
  }
  else
  {
      [self.navigationController pushViewController:controller animated:YES];
  }
}

- (void)showRandomSubreddit;
{
    NSString *randomSubreddit = [[SubredditManager sharedSubredditManager] randomSubreddit];
    NSString *url = [NSString stringWithFormat:@"/r/%@/", randomSubreddit];
    NSString *title = [randomSubreddit stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[randomSubreddit substringToIndex:1] uppercaseString]];
    [self showPostsForSubreddit:url withTitle:title];
}

- (void)showDiscovery;
{
//    REQUIRES_PRO;
    DiscoverySceneController *discoverController = [[DiscoverySceneController alloc] initWithTitle:@"Discover Subreddits" sceneIdent:@"main"];
    [[NavigationManager shared].postsNavigation pushViewController:discoverController animated:YES];
}

- (void)subscribeToAlienBlue;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [Subreddit subscribeToSubredditWithUrl:@"/r/AlienBlue/"];
    Subreddit *tempAB = [Subreddit subredditWithUrl:@"/r/AlienBlue/" name:@""];
    [self.subredditPrefs addSubreddit:tempAB toFolder:self.subredditPrefs.folderForSubscribedReddits];
    [self animateNodeChanges];
}

- (void)showAlienBlueSubreddit;
{
    [[NavigationManager shared] showPostsForSubreddit:@"/r/AlienBlue/" title:@"Alien Blue" animated:YES];
}

- (void)addDiscoverySection;
{
    BSELF(RedditsViewController);
    
    SubredditFolderNode *titleNode = [SubredditFolderNode folderNodeForFolder:self.subredditPrefs.folderForDiscoverSection];
    titleNode.title = @"Explore reddit";
    titleNode.collapsable = YES;
    [self addNode:titleNode];
    
//    NSString *discoverNodeTitle = [Resources isPro] ? @" Discover Subreddits" : @" Discover Subreddits (Pro)";
    NSString *discoverNodeTitle = @" Discover Subreddits";
    OptionNode *discoverNode = [self addOptionNodeWithTitle:discoverNodeTitle icon:nil];
    discoverNode.bold = YES;
    discoverNode.onSelect = ^{
        [blockSelf showDiscovery];
    };
    discoverNode.stickyHighlight = YES;
    
    
    OptionNode *randomNode = [self addOptionNodeWithTitle:@" Random Subreddit" icon:nil];
    randomNode.onSelect = ^{
        [blockSelf showRandomSubreddit];
    };
    randomNode.stickyHighlight = YES;
    
    
    OptionNode *manualNode = [self addOptionNodeWithTitle:@" Manually enter a subreddit" icon:nil];
    manualNode.onSelect = ^{
        [blockSelf showManualEntryView];
    };
    
    OptionNode *lookupUserNode = [self addOptionNodeWithTitle:@" Find a user" icon:nil];
    lookupUserNode.onSelect = ^{
        [blockSelf showLookupUserEntry];
    };
    
    Subreddit *tempAB = [Subreddit subredditWithUrl:@"/r/AlienBlue/" name:@""];
    if ([self.subredditPrefs folderContainingSubreddit:tempAB] == nil)
    {
        OptionNode *alienBlueSubredditNode = [self addOptionNodeWithTitle:@" Alien Blue Subreddit" icon:nil];
        alienBlueSubredditNode.secondaryIcon = [UIImage skinImageNamed:@"icons/add-button-rounded" withColor:[UIColor colorWithHex:0x6d9f60]];
        alienBlueSubredditNode.secondaryAction = ^{
            [blockSelf subscribeToAlienBlue];
        };
        alienBlueSubredditNode.onSelect = ^{
            [blockSelf showAlienBlueSubreddit];
        };
        [titleNode addChildNode:alienBlueSubredditNode];
    }
    
    NSArray *dNodes = [NSArray arrayWithObjects:discoverNode, randomNode, manualNode, lookupUserNode, nil];
    [dNodes each:^(OptionNode *node) {
        [node setDisclosureStyle:OptionDisclosureStyleArrow];
        [titleNode addChildNode:node];
    }];
    
    if (self.subredditPrefs.folderForDiscoverSection.collapsed)
    {
        [titleNode collapseNode];
    }
    
    [self addSpacerNode];
}

@end
