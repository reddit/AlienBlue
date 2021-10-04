//
//  FoldersViewController.m
//  AlienBlue
//
//  Created by J M on 11/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "FoldersViewController.h"
#import "FoldersViewController+EditSupport.h"
#import "NSubredditFolderCell.h"
#import "ABNavigationController.h"
#import "NavigationManager.h"
#import "JMTextFieldEntryCell.h"

#import "Resources.h"
#import "RedditsViewController.h"

@interface FoldersViewController ()
@property (strong) UserSubredditPreferences *subredditPrefs;
@property (strong) SubredditFolder *renamingFolder;
@property (copy) ABAction onComplete;
@property BOOL ranOnComplete;
- (id)initWithSubredditPreferences:(UserSubredditPreferences *)subredditPrefs  onComplete:(ABAction)onComplete;
@end

@implementation FoldersViewController

+ (UINavigationController *)navControllerWithSubredditPreferences:(UserSubredditPreferences *)subredditPrefs onComplete:(ABAction)onComplete;
{
    FoldersViewController *foldersController = [[FoldersViewController alloc] initWithSubredditPreferences:subredditPrefs onComplete:onComplete];
    UINavigationController *navController = [[ABNavigationController alloc] initWithRootViewController:foldersController];
    navController.toolbarHidden = YES;
    return navController;
}

- (id)initWithSubredditPreferences:(UserSubredditPreferences *)subredditPrefs  onComplete:(ABAction)onComplete;
{
    self = [super init];
    if (self)
    {
        [self jm_usePreIOS7ScrollBehavior];
      
        self.subredditPrefs = subredditPrefs;
        self.onComplete = onComplete;
        self.hidesBottomBarWhenPushed = YES;
      
        [self setNavbarTitle:@"Subreddit Groups"];
        
      CGSize doneButtonOffset = JMIsIOS7() ? CGSizeMake(16., 4.) : CGSizeMake(0., 4.);
      self.navigationItem.rightBarButtonItem = [UIBarButtonItem skinBarItemWithTitle:@"Done" textColor:nil fillColor:nil positionOffset:doneButtonOffset target:self action:@selector(closeFolderEditor)];
    }
    return self;
}

- (void)loadView;
{
    [super loadView];
    [self generateNodes];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [self.tableView setEditing:YES animated:YES];
    
    // the back button will suffice, done button would be redundant
    if ([self.navigationController.viewControllers indexOfObject:self] > 0)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)animateFolderChanges;
{
    BSELF(FoldersViewController);

    [UIView jm_transition:self.tableView animations:^{
        [blockSelf generateNodes];
    } completion:nil animated:YES];

}

- (void)generateNodes;
{
    [self.nodes removeAllObjects];
    
    BSELF(FoldersViewController);
    
    JMTextFieldEntryNode *addFolderNode = [JMTextFieldEntryNode textEntryNodeOnComplete:^(NSString *text){
        [blockSelf.subredditPrefs createSubredditFolderWithTitle:text];
        [blockSelf performSelector:@selector(animateFolderChanges) withObject:nil afterDelay:0.2];
    }];
    addFolderNode.placeholder = @"Add a new group";
    addFolderNode.capitalizationType = UITextAutocapitalizationTypeWords;
    [self addNode:addFolderNode];

    [self.subredditPrefs.subredditFolders each:^(SubredditFolder *folder) {
        
        if (folder != blockSelf.renamingFolder)
        {
            SubredditFolderNode *folderNode = [SubredditFolderNode folderNodeForFolder:folder];
            folderNode.editable = YES;
            folderNode.collapsable = NO;
            [folderNode collapseNode];
            BOOL allowRename = (folder != blockSelf.subredditPrefs.folderForSubscribedReddits) && (folder != blockSelf.subredditPrefs.folderForCasualReddits);
            if (allowRename)
            {
                folderNode.onDoubleTap = ^{
                    blockSelf.renamingFolder = folder;
                    [blockSelf animateFolderChanges];
                };
            }
            [blockSelf addNode:folderNode];
        }
        else
        {
            // rename
            JMTextFieldEntryNode *renameFolderNode = [JMTextFieldEntryNode textEntryNodeOnComplete:^(NSString *text){
                if (![text isEmpty])
                {
                    [blockSelf.subredditPrefs renameSubredditFolder:self.renamingFolder toTitle:text];
                }
                blockSelf.renamingFolder = nil;
                [blockSelf animateFolderChanges];
            }];
            renameFolderNode.placeholder = folder.title;
            renameFolderNode.defaultText = folder.title;
            renameFolderNode.capitalizationType = UITextAutocapitalizationTypeWords;
            [self addNode:renameFolderNode];
        }
    }];
    
    [self reload];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRedditGroupsDidChangeNotification object:nil];
    
    if (!self.ranOnComplete && self.onComplete)
    {
        self.onComplete();
    }
    
    [super viewWillDisappear:animated];
}

- (void)closeFolderEditor;
{
    if (self.onComplete)
    {
        self.onComplete();
    }
    self.ranOnComplete = YES;
}

- (CGSize)contentSizeForViewInPopover;
{
    return CGSizeMake(270., 360.);
}

- (CGSize)preferredContentSize;
{
  return self.contentSizeForViewInPopover;
}

@end
