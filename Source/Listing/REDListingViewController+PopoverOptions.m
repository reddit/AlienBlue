//  REDListingViewController+PopoverOptions.m
//  RedditApp

#import "RedditApp/Listing/REDListingViewController+PopoverOptions.h"

#import <BlocksKit/UIActionSheet+BlocksKit.h>

#import "Common/Navigation/NavigationManager.h"
#import "Helpers/Resources.h"
#import "Helpers/SessionManager.h"
#import "MKStoreKit/MKStoreManager.h"
#import "RedditApp/Listing/REDListingViewController+CanvasSupport.h"
#import "Sections/Discovery/DiscoveryAddController.h"
#import "Sections/Reddits/RedditsViewController.h"
#import "Sections/Reddits/Subreddit.h"
#import "Sections/Reddits/SubredditSidebarViewController.h"

@implementation REDListingViewController (PopoverOptions)

- (void)toggleVoteIcons;
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  [prefs setBool:![prefs boolForKey:kABSettingKeyShowVoteArrowsOnPosts]
          forKey:kABSettingKeyShowVoteArrowsOnPosts];
  [self reload];
}

- (void)popupExtraOptionsActionSheet:(id)sender {
  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];

  BSELF(REDListingViewController);

  Subreddit *sr = [Subreddit subredditWithUrl:self.subreddit name:@""];

  BOOL isSubscribed = [[SessionManager manager].subredditPrefs folderContainingSubreddit:sr] != nil;
  //
  //    if (isInUserFolder)
  //    {
  //        [actionSheet setDestructiveButtonWithTitle:@"Remove from Groups" handler:^{
  //            [[SessionManager manager].subredditPrefs removeSubredditFromAllFolders:sr];
  //            [[NSNotificationCenter defaultCenter]
  //            postNotificationName:kRedditGroupsDidChangeNotification object:nil];
  //        }];
  //    }

  if ([sr isNativeSubreddit]) {
    NSString *subscribeTitle = isSubscribed ? @"Unsubscribe / Ungroup" : @"Subscribe";
    if (!isSubscribed) {
      //          NSString *subscribeTitleSuffix = [Resources isPro] ? @"" : @" (PRO)";
      NSString *subscribeTitleSuffix = @"";
      subscribeTitle = [subscribeTitle stringByAppendingString:subscribeTitleSuffix];
    }
    [actionSheet bk_addButtonWithTitle:subscribeTitle
                               handler:^{ [blockSelf showAddSubredditToGroup]; }];

    //        NSString *groupTitle = [Resources isPro] ? @"Manage Group" : @"Manage Group (PRO)";
    NSString *groupTitle = @"Manage Group";
    [actionSheet bk_addButtonWithTitle:groupTitle
                               handler:^{ [blockSelf showAddSubredditToGroup]; }];

    [actionSheet bk_addButtonWithTitle:@"Show Sidebar"
                               handler:^{ [blockSelf showSidebarForSubreddit:sr]; }];

    [actionSheet
        bk_addButtonWithTitle:@"Message Moderators"
                      handler:^{
                          NSString *modUser = [NSString stringWithFormat:@"#%@", sr.title];
                          [[NavigationManager shared] showSendDirectMessageScreenForUser:modUser];
                      }];
  }

  //    NSString *submitTitle = [Resources isPro] ? @"Submit a Link" : @"Submit a Link (PRO)";
  NSString *submitTitle = @"Submit a Link";
  [actionSheet bk_addButtonWithTitle:submitTitle
                             handler:^{ [[NavigationManager shared] showCreatePostScreen]; }];

  NSString *voteIconsTitle =
      [Resources showPostVotingIcons] ? @"Hide Voting Icons" : @"Show Voting Icons";
  [actionSheet bk_addButtonWithTitle:voteIconsTitle handler:^{ [blockSelf toggleVoteIcons]; }];

  [actionSheet bk_addButtonWithTitle:@"Refresh"
                             handler:^{ [blockSelf fetchPostsRemoveExisting:YES]; }];

  [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];

  [actionSheet jm_showInView:[NavigationManager mainView]];
}

- (void)presentSubredditOptionsActionSheet:(UIActionSheet *)sheet;
{ [sheet jm_showInView:[NavigationManager mainView]]; }

- (void)showAddSubredditToGroup;
{
  //    REQUIRES_PRO;
  Subreddit *sr = [Subreddit subredditWithUrl:self.subreddit name:@""];
  DiscoveryAddController *controller =
      [[DiscoveryAddController alloc] initWithSubreddit:sr onComplete:^{}];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)showSidebarForSubreddit:(Subreddit *)sr;
{
  SubredditSidebarViewController *controller =
      [[SubredditSidebarViewController alloc] initWithSubredditNamed:sr.title];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)popupSubredditOptions;
{
  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];

  BSELF(REDListingViewController);

  Subreddit *sr = [Subreddit subredditWithUrl:self.subreddit name:@""];
  BOOL isInUserFolder =
      [[SessionManager manager].subredditPrefs folderContainingSubreddit:sr] != nil;
  BOOL isSubscribed =
      [[SessionManager manager].subredditPrefs.folderForSubscribedReddits containsSubreddit:sr];

  if (isInUserFolder || isSubscribed) {
    NSString *destructiveButtonTitle = isSubscribed ? @"Unsubscribe" : @"Remove from Groups";
    [actionSheet
        bk_setDestructiveButtonWithTitle:destructiveButtonTitle
                                 handler:^{
                                     [[SessionManager manager].subredditPrefs
                                         removeSubredditFromAllFolders:sr];
                                     [[NSNotificationCenter defaultCenter]
                                         postNotificationName:kRedditGroupsDidChangeNotification
                                                       object:nil];
                                 }];
  }

  NSString *addGroupTitle = isSubscribed ? @"Add to Group..." : @"Subscribe...";
  [actionSheet bk_addButtonWithTitle:addGroupTitle
                             handler:^{ [blockSelf showAddSubredditToGroup]; }];

  [actionSheet bk_addButtonWithTitle:@"Show Sidebar"
                             handler:^{ [blockSelf showSidebarForSubreddit:sr]; }];

  [actionSheet
      bk_addButtonWithTitle:@"Message Moderators"
                    handler:^{
                        NSString *modUser = [NSString stringWithFormat:@"#%@", sr.title];
                        [[NavigationManager shared] showSendDirectMessageScreenForUser:modUser];
                    }];

  [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];

  [self presentSubredditOptionsActionSheet:actionSheet];
}

- (void)showSidebar;
{
  Subreddit *sr = [Subreddit subredditWithUrl:self.subreddit name:@""];
  [self showSidebarForSubreddit:sr];
}

- (void)showMessageModsScreen;
{
  Subreddit *sr = [Subreddit subredditWithUrl:self.subreddit name:@""];
  NSString *modUser = [NSString stringWithFormat:@"#%@", sr.title];
  [[NavigationManager shared] showSendDirectMessageScreenForUser:modUser];
}

- (void)showGallery;
{ [self showCanvas]; }

- (BOOL)isSubscribedToSubreddit;
{
  Subreddit *sr = [Subreddit subredditWithUrl:self.subreddit name:@""];
  return [[SessionManager manager].subredditPrefs folderContainingSubreddit:sr] != nil;
}

- (BOOL)isNativeSubreddit;
{
  Subreddit *sr = [Subreddit subredditWithUrl:self.subreddit name:@""];
  return sr.isNativeSubreddit;
}

@end
