//
//  RedditsViewController_iPad.m
//  AlienBlue
//
//  Created by J M on 14/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsViewController_iPad.h"
#import "RedditsHeaderView_iPad.h"
#import "RedditsFooterView_iPad.h"
#import "RedditsViewController+EditSupport.h"
#import "RedditsViewController+Subscriptions.h"
#import "SubredditSidebarViewController.h"
#import "RedditAddController.h"
#import "FoldersViewController.h"
#import "ABTableView.h"

#import "NavigationManager_iPad.h"
#import "DiscoverySceneController_iPad.h"
#import "NBaseOptionCell.h"
#import "RedditAPI+Account.h"
#import "NSubredditFolderCell.h"

@interface RedditsViewController_iPad ()
@property (strong) RedditsHeaderView_iPad *headerView;
@property (strong) RedditsFooterView_iPad *footerView;
@end

@implementation RedditsViewController_iPad

- (void)loadView
{
    [super loadView];
    
    self.disallowFullscreen = YES;
    
    self.headerView = [[RedditsHeaderView_iPad alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 55.)];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerView.title = @"reddit";
    [self.view addSubview:self.headerView];
    
    self.tableView.top = self.headerView.height - 5.;
    self.tableView.height -= self.tableView.top;
    self.topShadowView.hidden = YES;
  
    BSELF(RedditsViewController_iPad);
    self.headerView.editOverlay.onTap = ^(CGPoint touchPoint)
    {
        REQUIRES_REDDIT_AUTHENTICATION;
        [blockSelf.headerView performSelector:@selector(switchMode) withObject:nil afterDelay:0.2];
        [blockSelf enableEditMode];
    };
    
    self.headerView.doneOverlay.onTap = ^(CGPoint touchPoint)
    {
        [blockSelf.headerView performSelector:@selector(switchMode) withObject:nil afterDelay:0.2];
        [blockSelf disableEditMode];
    };
    
    self.headerView.doneOverlay.hidden = YES;
        
    self.footerView = [[RedditsFooterView_iPad alloc] initWithFrame:CGRectMake(0., 0., self.tableView.width, 55.)];
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.footerView.top = self.view.height;
    self.footerView.foldersButtonOverlay.onTap = ^(CGPoint touchPoint)
    {
        [blockSelf showFolderManagementView];
    };
    
    self.footerView.sortButtonOverlay.onTap = ^(CGPoint touchPoint)
    {
        [blockSelf sortFoldersAlphabetically];
    };
    
    [self.view addSubview:self.footerView];
}

- (void)enableEditMode;
{
    [super enableEditMode];
    
    BSELF(RedditsViewController_iPad);
    [UIView jm_animate:^{
        blockSelf.footerView.bottom = blockSelf.view.height + 5.;
    } completion:nil];
}

- (void)disableEditMode;
{
    [super disableEditMode];
    BSELF(RedditsViewController_iPad);
    [UIView jm_animate:^{
        blockSelf.footerView.top = blockSelf.view.height;
    } completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [self.headerView updateWithContentOffset:scrollView.contentOffset];
}

- (void)dismissFolderManagementView;
{
    [[NavigationManager shared] dismissPopoverIfNecessary];
}

- (void)showSidebarInfoForSubreddit:(NSString *)subredditTitle;
{
  SubredditSidebarViewController *controller = [[UNIVERSAL(SubredditSidebarViewController) alloc] initWithSubredditNamed:subredditTitle];
  [self.foldingNavigationController pushViewController:controller afterPoppingToController:self];
}

- (void)showFolderManagementView;
{
    BSELF(RedditsViewController_iPad);
    UINavigationController *navController = [FoldersViewController navControllerWithSubredditPreferences:self.subredditPrefs onComplete:^{
        [blockSelf animateNodeChanges];
        [blockSelf dismissFolderManagementView];
    }];
  
    CGRect fromRect = CGRectOffset(self.footerView.foldersButtonOverlay.frame, self.footerView.left, self.footerView.top);
    [(NavigationManager_iPad *)[NavigationManager_iPad shared] showPopoverWithContentViewController:navController inView:self.view fromRect:fromRect permittedArrowDirections:UIPopoverArrowDirectionAny];
}

- (void)showDiscovery;
{
    DiscoverySceneController_iPad *discoverController = [[DiscoverySceneController_iPad alloc] initWithTitle:@"Discover Subreddits" sceneIdent:@"main"];
	[self.foldingNavigationController pushViewController:discoverController afterPoppingToController:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    OptionNode *selectedNode = (OptionNode *)[self.nodes objectAtIndex:indexPath.row];
    [self deselectNodes];
    if ([selectedNode isKindOfClass:[OptionNode class]] && selectedNode.stickyHighlight)
    {
        [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES];
    }
}

- (void)showAlienBlueSubreddit;
{
    [(NavigationManager_iPad *)[NavigationManager_iPad shared] showPostsForSubreddit:@"/r/AlienBlue/" title:@"Alien Blue" fromController:self];
}

- (void)showRedditEntryViewForFolderNode:(SubredditFolderNode *)folderNode;
{
    UINavigationController *navc = [RedditAddController navControllerForAddingToSubredditFolder:folderNode.subredditFolder];
    CGRect cellRect = [self rectForNode:folderNode];
    CGRect fromRect = CGRectOffset(CGRectMake(cellRect.size.width - 42., 0., 40., 40.), cellRect.origin.x, cellRect.origin.y);
    fromRect = CGRectOffset(fromRect, 0., -1 * self.tableView.contentOffset.y + 50.);
    [(NavigationManager_iPad *)[NavigationManager_iPad shared] showPopoverWithContentViewController:navc inView:self.view fromRect:fromRect permittedArrowDirections:UIPopoverArrowDirectionAny];
}

- (CGFloat)pageWidth;
{
    return 300.;
}

@end
