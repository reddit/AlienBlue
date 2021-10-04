//
//  FoldersViewController+EditSupport.m
//  AlienBlue
//
//  Created by J M on 11/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "FoldersViewController+EditSupport.h"
#import "NSubredditFolderCell.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "NavigationManager.h"

@implementation FoldersViewController (EditSupport)

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	JMOutlineNode *node = [self nodeForRow:indexPath.row];
    return node.editable && [node isKindOfClass:[SubredditFolderNode class]];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	JMOutlineNode *node = [self nodeForRow:indexPath.row];
    return node.editable;    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    SubredditFolderNode *folderNode = (SubredditFolderNode *)[self nodeForRow:indexPath.row];
    BSELF(FoldersViewController);
    if ([folderNode isKindOfClass:[SubredditFolderNode class]])
    {
        if ([folderNode.subredditFolder.subreddits count] > 0)
        {
            NSArray *subredditsToPort = [NSArray arrayWithArray:folderNode.subredditFolder.subreddits];
            NSString *message = [NSString stringWithFormat:@"This folder contains %d subreddit(s). What would you like to do with the contents?", [subredditsToPort count]];
            UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:message];
            
            [sheet bk_setDestructiveButtonWithTitle:@"Delete Subreddits" handler:^{
                [blockSelf.subredditPrefs removeSubredditFolder:folderNode.subredditFolder];
                [blockSelf animateFolderChanges];
            }];
            
            NSArray *destinationFolders = [self.subredditPrefs.subredditFolders reject:^BOOL(SubredditFolder *folder) {
                return [folder.ident equalsString:folderNode.subredditFolder.ident];
            }];

            [destinationFolders each:^(SubredditFolder *folder){
                NSString *title = [NSString stringWithFormat:@"Move to %@", folder.title];
                [sheet bk_addButtonWithTitle:title handler:^{
                    [blockSelf.subredditPrefs removeSubredditFolder:folderNode.subredditFolder];
                    [subredditsToPort each:^(Subreddit *sr) {
                        [folder addSubreddit:sr];
                    }];
                    [blockSelf.subredditPrefs save];
                    [blockSelf animateFolderChanges];
                }];
            }];
            
            [sheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
            [sheet jm_showInView:[NavigationManager mainView]];
        }
        else
        {
            [blockSelf.subredditPrefs removeSubredditFolder:folderNode.subredditFolder];
            [blockSelf animateFolderChanges];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SubredditFolderNode *node = (SubredditFolderNode *)[self nodeForRow:indexPath.row];
    if ([node isKindOfClass:[SubredditFolderNode class]])
    {
        if (node.subredditFolder != self.subredditPrefs.folderForSubscribedReddits && node.subredditFolder != self.subredditPrefs.folderForCasualReddits)
        {
            return UITableViewCellEditingStyleDelete;
        }
    }

    return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
{
    if (proposedDestinationIndexPath.row <= 0)
        return sourceIndexPath;
    
	JMOutlineNode *node = [self nodeForRow:proposedDestinationIndexPath.row];
    if (!node.editable)
    {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    SubredditFolderNode *fromNode = (SubredditFolderNode *)[self nodeForRow:fromIndexPath.row];

    [self.subredditPrefs.subredditFolders removeObject:fromNode.subredditFolder];
    [self.subredditPrefs recordChange:FolderChangeRemoveFolder subreddit:nil folder:fromNode.subredditFolder];
    
    NSUInteger moveToIndex = (toIndexPath.row - 1);
    [self.subredditPrefs addSubredditFolder:fromNode.subredditFolder atIndex:moveToIndex];
    [self.subredditPrefs recordReorderOfSubreddit:nil folder:fromNode.subredditFolder rowIndex:moveToIndex];
    
    [self generateNodes];
}


@end
