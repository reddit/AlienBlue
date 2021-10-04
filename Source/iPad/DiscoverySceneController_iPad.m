//
//  DiscoverySceneController_iPad.m
//  AlienBlue
//
//  Created by J M on 16/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "DiscoverySceneController_iPad.h"
#import "DiscoveryHeaderView_iPad.h"
#import "DiscoveryCategory.h"
#import "UIViewController+JMFoldingNavigation.h"
#import "NBaseOptionCell.h"
#import "Subreddit.h"
#import "NavigationManager_iPad.h"
#import "NDiscoverySubredditCell.h"
#import "DiscoveryAddController_iPad.h"
#import "SubredditSidebarViewController.h"

@interface DiscoverySceneController_iPad()
@property (strong) DiscoveryHeaderView_iPad *headerView;
@end

@implementation DiscoverySceneController_iPad

- (void)loadView;
{
    [super loadView];
    
    self.disallowFullscreen = YES;
    
    self.headerView = [[DiscoveryHeaderView_iPad alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 55.)];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerView.title = self.title;
    [self.view addSubview:self.headerView];
    
    self.tableView.top = self.headerView.height - 5.;
    self.tableView.height -= self.tableView.top;
    self.loadingIndicator = self.headerView.loadingIndicator;
}

- (CGFloat)pageWidth;
{
    return 300.;
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

- (void)showCategory:(DiscoveryCategory *)category;
{
    DiscoverySceneController_iPad *controller = [[DiscoverySceneController_iPad alloc] initWithTitle:category.title sceneIdent:category.ident];
    [self.foldingNavigationController pushViewController:controller afterPoppingToController:self];
}

- (void)showSubreddit:(Subreddit *)subreddit;
{
    [(NavigationManager_iPad *)[NavigationManager_iPad shared] showPostsForSubreddit:subreddit.url title:subreddit.title fromController:self];
}

- (void)showSidebarInfoForSubreddit:(NSString *)subredditTitle;
{
  SubredditSidebarViewController *controller = [[UNIVERSAL(SubredditSidebarViewController) alloc] initWithSubredditNamed:subredditTitle];
  [self.foldingNavigationController pushViewController:controller afterPoppingToController:self];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [self.headerView updateWithContentOffset:scrollView.contentOffset];
}

- (void)showAddSubredditForNode:(DiscoverySubredditNode *)subredditNode;
{
    BSELF(DiscoverySceneController_iPad);
    Subreddit *sr = subredditNode.subreddit;
    UINavigationController *navController = [DiscoveryAddController_iPad navControllerForAddingSubreddit:sr onComplete:^{
        [blockSelf animateFolderChanges];
    }];
  
    CGRect cellRect = [self rectForNode:subredditNode];
    CGRect secondaryIconRect = CGRectMake(cellRect.size.width - 42., 2., 40., 40.);
    secondaryIconRect = CGRectOffset(secondaryIconRect, cellRect.origin.x - 50., cellRect.origin.y + 50.);
    secondaryIconRect = CGRectOffset(secondaryIconRect, -1. * self.tableView.contentOffset.x, -1. * self.tableView.contentOffset.y);
    secondaryIconRect = CGRectOffset(secondaryIconRect, self.tableView.top, self.tableView.left);

    [(NavigationManager_iPad *)[NavigationManager_iPad shared] showPopoverWithContentViewController:navController inView:self.view fromRect:secondaryIconRect permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown)];
}

@end
