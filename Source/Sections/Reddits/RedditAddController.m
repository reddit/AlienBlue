//
//  RedditAddController.m
//  AlienBlue
//
//  Created by J M on 25/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditAddController.h"
#import "JMTextFieldEntryCell.h"
#import "NSectionTitleCell.h"
#import "NBaseOptionCell.h"
#import "ABNavigationController.h"
#import "DiscoverySceneController.h"
#import "NavigationManager.h"
#import "RedditsViewController.h"
#import "MultiSubredditSelectorViewController.h"
#import "SessionManager.h"
#import "Resources.h"
#import "MKStoreManager.h"
#import "Subreddit+API.h"

@interface RedditAddController()
@property (strong) SubredditFolder *folder;
- (void)generateNodes;
- (void)dismiss;
@end

@implementation RedditAddController

- (id)initWithDestinationFolder:(SubredditFolder *)folder;
{
    self = [super init];
    if (self)
    {
        self.folder = folder;
        self.title = @"Add a Subreddit";
        [self setNavbarTitle:self.title];
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

+ (UINavigationController *)navControllerForAddingToSubredditFolder:(SubredditFolder *)folder;
{
    RedditAddController *controller = [[[self class] alloc] initWithDestinationFolder:folder];
    ABNavigationController *navController = [[ABNavigationController alloc] initWithRootViewController:controller];
    navController.toolbarHidden = YES;
    return navController;    
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [self generateNodes];
}

- (void)finishWithSubreddit:(NSString *)subreddit;
{
    NSString * sr = nil;
    
    // user hasn't entered /r/ so we'll do this for them
    if ([subreddit rangeOfString:@"/r/"].location == NSNotFound)
        sr = [NSString stringWithFormat:@"%@%@/",@"/r/", subreddit];
    else    
        sr = [subreddit stringByAppendingString:@"/"];
    
    if ([sr equalsString:@"/r/"] || [sr equalsString:@"/r//"])
    {
        [self dismiss];
        return;
    }

    Subreddit *s = [Subreddit subredditWithUrl:sr name:@""];
    [[SessionManager manager].subredditPrefs addSubreddit:s toFolder:self.folder atIndex:0];
    if (self.folder == [SessionManager manager].subredditPrefs.folderForSubscribedReddits)
    {
      [Subreddit subscribeToSubredditWithUrl:sr];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kRedditGroupsDidChangeNotification object:nil];
    
    [self dismiss];
}

- (void)showSubredditsSelector;
{
    BSELF(RedditAddController);
    SubredditFolder *sourceFolder = [[SessionManager manager].subredditPrefs folderForSubscribedReddits];
    MultiSubredditSelectorViewController *selectorViewController = [[MultiSubredditSelectorViewController alloc] initWithSourceFolder:sourceFolder onComplete:^(NSArray *subreddits) {
        if (subreddits)
        {
            [subreddits each:^(Subreddit *selectedSubreddit) {
                [[SessionManager manager].subredditPrefs addSubreddit:selectedSubreddit toFolder:blockSelf.folder];
            }];
            NSString *msg = [NSString stringWithFormat:@"Added %d subreddit(s) to %@ group", subreddits.count, blockSelf.folder.title];
            [PromptManager showMomentaryHudWithMessage:msg minShowTime:2.5];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRedditGroupsDidChangeNotification object:nil];    
        }
    }];
    [self.navigationController pushViewController:selectorViewController animated:YES];    
}

- (void)dismiss;
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)showDiscovery;
{
//    REQUIRES_PRO;
    Class discoveryControllerClass = [Resources isIPAD] ? NSClassFromString(@"DiscoverySceneController_iPad") : NSClassFromString(@"DiscoverySceneController");
    DiscoverySceneController *discoverController = [[discoveryControllerClass alloc] initWithTitle:@"Discover Subreddits" sceneIdent:@"main"];
    
    if ([Resources isIPAD])
    {
        [self dismiss];        
        [[NavigationManager shared].postsNavigation popToRootViewControllerAnimated:NO];
        [[NavigationManager shared].postsNavigation pushViewController:discoverController animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:discoverController animated:YES];
    }

}

- (void)generateNodes;
{
    [self removeAllNodes];

    BSELF(RedditAddController);
    
    JMTextFieldEntryNode *textNode = [JMTextFieldEntryNode textEntryNodeOnComplete:^(NSString *text) {
        [blockSelf finishWithSubreddit:text];
    }];
    textNode.placeholder = @"/r/";
    textNode.defaultText = @"/r/";
    textNode.autoCorrectionType = UITextAutocorrectionTypeNo;

    [self addNode:textNode];
    
    if (self.folder != [SessionManager manager].subredditPrefs.folderForSubscribedReddits)
    {
        OptionNode *chooseSubscribedNode = [[OptionNode alloc] init];
        chooseSubscribedNode.title = @"Choose from Subscriptions";
        chooseSubscribedNode.onSelect = ^{
            [blockSelf showSubredditsSelector];
        };
        [self addNode:chooseSubscribedNode];
    }

    OptionNode *discoveryNode = [[OptionNode alloc] init];
//    discoveryNode.title = [Resources isPro] ? @"Discover Subreddits" : @"Discover Subreddits (PRO)";
    discoveryNode.title = @"Discover Subreddits";
    discoveryNode.bold = YES;
    discoveryNode.onSelect = ^{
        [blockSelf showDiscovery];
    };
    [self addNode:discoveryNode];
    
    [self reload];
}

- (CGSize)contentSizeForViewInPopover;
{
    CGFloat height = 240.;
    if (self.folder != [SessionManager manager].subredditPrefs.folderForSubscribedReddits)
    {
        height += 40.;
    }
    
    return CGSizeMake(320., height);
}

- (CGSize)preferredContentSize;
{
  return self.contentSizeForViewInPopover;
}

@end
