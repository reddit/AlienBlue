//
//  RedditsViewController+EditSupport.m
//  AlienBlue
//
//  Created by J M on 9/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsViewController+EditSupport.h"
#import "NSubredditCell.h"
#import "NSectionTitleCell.h"
#import "NSectionSpacerCell.h"
#import "NSubredditFolderCell.h"
#import "RedditsViewController+Subscriptions.h"
#import "NSArray+BlocksKit.h"
#import "Subreddit+API.h"
#import "RedditAPI.h"
#import "RedditAPI+Account.h"

@interface RedditsViewController (EditSupport_)
- (SubredditFolderNode *)folderNodeHousingRow:(NSUInteger)row;

@property JMOutlineNode *ghostNode;
@property UIView *ghostView;
@property BOOL dragDirectionUpward;
- (NSNumber *)shouldSuppressReorderFrameChangeForNode:(JMOutlineNode *)node;
- (void)enableGhostingForNode:(JMOutlineNode *)node;
- (void)disableGhosting;

@end

@implementation RedditsViewController (EditSupport)

SYNTHESIZE_ASSOCIATED_STRONG(JMOutlineNode, ghostNode, GhostNode);
SYNTHESIZE_ASSOCIATED_STRONG(UIView, ghostView, GhostView);
SYNTHESIZE_ASSOCIATED_BOOL(dragDirectionUpward, DragDirectionUpward);

#define kRedditsViewControllerEditButtonOffset JMIsIOS7() ? CGSizeMake(14., 3.) : CGSizeMake(0., 3.)

- (void)enableEditMode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
  
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem skinBarItemWithTitle:@"Done" textColor:nil fillColor:nil positionOffset:kRedditsViewControllerEditButtonOffset target:self action:@selector(disableEditMode)];
    [self.tableView setEditing:YES animated:YES];
    
    [self performSelector:@selector(animateNodeChanges) withObject:nil afterDelay:0.25];
}

- (void)disableEditMode;
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem skinBarItemWithTitle:@"Edit" textColor:nil fillColor:nil positionOffset:kRedditsViewControllerEditButtonOffset target:self action:@selector(enableEditMode)];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    
    [self disableGhosting];
    
    [self performSelector:@selector(animateNodeChanges) withObject:nil afterDelay:0.25];
    
    if (self.tableView.editing)
    {
        [self.subredditPrefs recommendSyncToCloud];
    }
    
    [self.tableView setEditing:NO animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	SubredditNode *subredditNode = (SubredditNode *)[self nodeForRow:indexPath.row];

    if (!subredditNode.editable)
        return NO;
    
    if (![subredditNode isKindOfClass:[SubredditNode class]])
        return NO;
    
    SubredditFolderNode *folderNode = [self folderNodeHousingRow:indexPath.row];
    if (folderNode.collapsed)
        return NO;
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	JMOutlineNode *node = [self nodeForRow:indexPath.row];
    return node.editable;    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    SubredditNode *fromNode = (SubredditNode *)[self nodeForRow:indexPath.row];
    SubredditFolderNode *fromFolderNode = [self folderNodeHousingRow:indexPath.row];
    [self.subredditPrefs removeSubreddit:fromNode.subreddit fromFolder:fromFolderNode.subredditFolder];
    [self generateNodes];
    
    if (fromFolderNode.subredditFolder == self.subredditPrefs.folderForSubscribedReddits)
    {
//        fromNode.subreddit.subscribed = NO;
        [Subreddit unsubscribeToSubredditWithUrl:fromNode.subreddit.url];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
{
    if (proposedDestinationIndexPath.row <= 3)
        return sourceIndexPath;
  
    SubredditFolderNode *destFolder = [self folderNodeHousingRow:proposedDestinationIndexPath.row];
    SubredditFolderNode *sourceFolder = [self folderNodeHousingRow:sourceIndexPath.row];
    BOOL changingFolders = (destFolder != sourceFolder);
    self.dragDirectionUpward = (sourceIndexPath.row > proposedDestinationIndexPath.row);
    BOOL requiresGhosting = changingFolders && sourceFolder.subredditFolder == self.subredditPrefs.folderForSubscribedReddits && destFolder.subredditFolder != self.subredditPrefs.folderForCasualReddits;
    
    if (!destFolder)
        return  sourceIndexPath;

    // exclude system folders like "My Account" and "Explore Reddit"
    if (![self.subredditPrefs.subredditFolders containsObject:destFolder.subredditFolder])
        return sourceIndexPath;
    
    SubredditNode *node = (SubredditNode *)[self nodeForRow:sourceIndexPath.row];
    if (requiresGhosting && !self.ghostNode)
    {
        node.titleColor = [UIColor orangeColor];
        JMOutlineCell *cell = (JMOutlineCell *)[self.tableView cellForRowAtIndexPath:sourceIndexPath];
        [cell.containerView setNeedsDisplay];
        [self enableGhostingForNode:node];
        node.title = [NSString stringWithFormat:@"%@ (Copy)", node.subreddit.title];
    }
    else if (!requiresGhosting)
    {
        node.titleColor = nil;
        node.title = node.subreddit.title;
        [self disableGhosting];
    }
    JMOutlineCell *cell = (JMOutlineCell *)[self.tableView cellForRowAtIndexPath:sourceIndexPath];
    [cell.containerView setNeedsDisplay];
    
    
    if  (destFolder.collapsed && sourceIndexPath.row > proposedDestinationIndexPath.row)
    {
//        destFolder = (SubredditFolderNode *)[self nodeForRow:proposedDestinationIndexPath.row];
        return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row + 1 inSection:0];
    }
        
    NSUInteger folderRow = [self rowForNode:destFolder];
    NSUInteger maxRow = folderRow + destFolder.subredditFolder.subreddits.count;
    NSUInteger minRow = folderRow + 1;
        
    if (changingFolders)
    {        
        if (sourceIndexPath.row > proposedDestinationIndexPath.row)
            maxRow++;
        else
            minRow--;
    
        if  (destFolder.collapsed && sourceIndexPath.row < proposedDestinationIndexPath.row)
            maxRow++;
        else if (destFolder.collapsed && sourceIndexPath.row > proposedDestinationIndexPath.row)
            minRow--;
    }
    
//    DLog(@"trying: (%d) :: minrow: (%d) maxrow (%d) :: %@", proposedDestinationIndexPath.row, minRow, maxRow, destFolder.title);
    
    if (proposedDestinationIndexPath.row > maxRow || proposedDestinationIndexPath.row < minRow)
        return sourceIndexPath;

    return proposedDestinationIndexPath;
}

- (SubredditFolderNode *)folderNodeHousingRow:(NSUInteger)row;
{
    NSArray *rnodes = [[[self.nodes take:(row + 1)] reverseObjectEnumerator] allObjects];
    SubredditFolderNode *folderNode = [rnodes match:^BOOL(JMOutlineNode *node) {
        return [node isKindOfClass:[SubredditFolderNode class]];
    }];
    return folderNode;
}

- (NSUInteger)indexOffsetFromFolderForRow:(NSUInteger)subredditRow;
{
//    NSUInteger subredditRow = [self rowForNode:subredditNode];
    SubredditFolderNode *folderNode = [self folderNodeHousingRow:subredditRow];

    if (!folderNode)
        return NSNotFound;

    NSUInteger folderRow = [self rowForNode:folderNode];
    NSUInteger offset = subredditRow - folderRow - 1;
    return offset;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self disableGhosting];
    
    SubredditNode *fromNode = (SubredditNode *)[self nodeForRow:fromIndexPath.row];
    SubredditFolderNode *fromFolderNode = [self folderNodeHousingRow:fromIndexPath.row];
    SubredditFolderNode *toFolderNode = [self folderNodeHousingRow:toIndexPath.row];

    NSUInteger indexToInsert = [self indexOffsetFromFolderForRow:toIndexPath.row];
    
    if (!toFolderNode.collapsed && fromFolderNode != toFolderNode && toIndexPath.row > fromIndexPath.row)
    {
        indexToInsert++;
    }

//    if (toFolderNode.collapsed && fromFolderNode != toFolderNode)
//    {
//        // handle collapsed folders
//        if (fromIndexPath.row > toIndexPath.row)
//            indexToInsert--;
//        else if  (fromIndexPath.row < toIndexPath.row)
//            indexToInsert++;
//    }
    BOOL changingFolders = (fromFolderNode.subredditFolder != toFolderNode.subredditFolder);
    BOOL leaveDuplicate = changingFolders && fromFolderNode.subredditFolder == self.subredditPrefs.folderForSubscribedReddits && toFolderNode.subredditFolder != self.subredditPrefs.folderForCasualReddits && ![toFolderNode.subredditFolder containsSubreddit:fromNode.subreddit];
    
    if (!leaveDuplicate)
    {
        // dragging from subscribed subreddits leaves a duplicate (except when dragging to Casual)
        [self.subredditPrefs removeSubreddit:fromNode.subreddit fromFolder:fromFolderNode.subredditFolder];
    }
    
    [toFolderNode.subredditFolder insertSubreddit:fromNode.subreddit atIndex:indexToInsert];

    [self.subredditPrefs recordChange:FolderChangeAddSubreddit subreddit:fromNode.subreddit folder:toFolderNode.subredditFolder];
    [self.subredditPrefs recordReorderOfSubreddit:fromNode.subreddit folder:toFolderNode.subredditFolder rowIndex:indexToInsert];
    
    [self.subredditPrefs save];
    
//    [self generateNodes];
    [self animateNodeChanges];
    
    if (fromFolderNode.subredditFolder == self.subredditPrefs.folderForSubscribedReddits && toFolderNode.subredditFolder == self.subredditPrefs.folderForCasualReddits)
    {
//        fromNode.subreddit.subscribed = NO;
        [Subreddit unsubscribeToSubredditWithUrl:fromNode.subreddit.url];
    } else if (fromFolderNode.subredditFolder != self.subredditPrefs.folderForSubscribedReddits && toFolderNode.subredditFolder == self.subredditPrefs.folderForSubscribedReddits)
    {
//        fromNode.subreddit.subscribed = YES;
        [Subreddit subscribeToSubredditWithUrl:fromNode.subreddit.url];        
    }    
    
}

////
//
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated
//{
//	[super setEditing:editing animated:animated];
//	
//	if (!editing)
//	{
//		[self saveSortOrder];
//		[self refreshTable];
//	}
//}
//

//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	if ((indexPath.section == SECTION_SUBREDDITS && indexPath.row < [subreddits count]) || ![redAPI authenticated])
//		return @"Unsubscribe";
//    else
//        return @"Delete";
//}

#pragma mark - Ghosting (for Re-ordering)

- (void)enableGhostingForNode:(JMOutlineNode *)node;
{
    self.ghostNode = node;

//    NSUInteger row = [self rowForNode:node];
//    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
//    JMOutlineCell *cell = (JMOutlineCell *)[self.tableView cellForRowAtIndexPath:ip];
    SubredditNode *subredditNode = (SubredditNode *)node;
    CGRect ghostRect = [self rectForNode:node];
    if (!self.dragDirectionUpward)
    {
        ghostRect = CGRectOffset(ghostRect, 0, -ghostRect.size.height);
    }
    ghostRect = CGRectOffset(ghostRect, 0, -ghostRect.size.height / 2.);
    
    UIView *gv = [[OverlayViewContainer alloc] initWithFrame:ghostRect];
    gv.backgroundColor = [UIColor clearColor];
    JMViewOverlay *overlay = [JMViewOverlay overlayWithFrame:gv.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [UIView startEtchedDraw];
        CGRect boxRect = CGRectCenterWithSize(bounds, CGSizeMake(200., 12.));
        boxRect.origin.x = bounds.size.width - boxRect.size.width - 4.;
        [[UIColor orangeColor] set];
        
        CGPoint triangleCenter = CGRectIntegral(CGRectCenterWithSize(bounds, CGSizeMake(1, 1))).origin;
        triangleCenter.y -= 1;
        triangleCenter.x = bounds.size.width - 160.;
        
        CGRect underlineRect = CGRectMake(triangleCenter.x, triangleCenter.y, 160., 1.);
        [[UIBezierPath bezierPathWithRect:underlineRect] fill];
        [UIView endEtchedDraw];        
        
        UIFont *font = [UIFont boldSystemFontOfSize:9.];
        CGRect titleBounds = CGRectMake(underlineRect.origin.x + 5., underlineRect.origin.y - 6., underlineRect.size.width - 45., 14.);
        NSString *title = [NSString stringWithFormat:@"Copy : %@", subredditNode.subreddit.title];
        
        CGFloat titleWidth = MIN([title widthWithFont:font], 90.);
        CGRect titleRect = CGRectCenterWithSize(titleBounds, CGSizeMake(titleWidth + 10., 14.));

        [[UIColor colorForBackground] set];
        [[UIBezierPath bezierPathWithRect:titleRect] fill];
        
        [UIView startEtchedDraw];
        [[UIColor orangeColor] set];
        [title drawInRect:titleRect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
        [[UIBezierPath bezierPathWithTriangleCenter:triangleCenter sideLength:7. angle:90.] fill];

        [UIView endEtchedDraw];
    }];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [gv addOverlay:overlay];
    
    self.ghostView = gv;
    
//    self.ghostView = [cell imageViewRepresentation];
//    self.ghostView.backgroundColor = [UIColor colorForBackground];
//    self.ghostView.frame = CGRectOffset(ghostRect, 0, -ghostRect.size.height);
    [self.tableView addSubview:self.ghostView];
}

- (void)disableGhosting;
{
    [self.ghostView removeFromSuperview];
    self.ghostView = nil;
    self.ghostNode = nil;
}

//- (NSNumber *)shouldSuppressReorderFrameChangeForNode:(JMOutlineNode *)node;
//{
//    BOOL suppressOrder = NO;
//    if (self.tableView.editing && self.ghostNode)
//    {
//        NSUInteger nodeRow = [self rowForNode:node];
//        NSUInteger ghostRow = [self rowForNode:self.ghostNode];
//        
//        if (self.dragDirectionUpward && nodeRow < ghostRow)
//            suppressOrder = YES;
////        else if (!self.dragDirectionUpward && nodeRow > ghostRow)
////            suppressOrder = YES;
//    }
//    
//    return [NSNumber numberWithBool:suppressOrder];
//}

@end
