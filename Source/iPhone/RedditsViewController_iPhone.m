//
//  RedditsViewController_iPhone.m
//  AlienBlue
//
//  Created by J M on 8/05/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsViewController_iPhone.h"
#import "RedditsViewController+EditSupport.h"
#import "RedditsViewController+Discovery.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "ABCustomOutlineNavigationBar.h"
#import "NavigationManager_iPad.h"
#import "UIView+JMFNAnimation.h"
#import "Resources.h"
#import "RedditAPI+Account.h"

@implementation RedditsViewController_iPhone

- (void)enableEditMode;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    
    [super enableEditMode];

//    NSString *discoverTitle = [Resources isPro] ? @"Discover" : @"Discover (Pro)";
    NSString *discoverTitle = @"Discover";
  
    UIBarButtonItem *discoverButton = [UIBarButtonItem skinBarItemWithTitle:discoverTitle textColor:[UIColor skinColorForConstructive] fillColor:nil positionOffset:CGSizeZero target:self action:@selector(showDiscovery)];
  
    UIBarButtonItem *edgeMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    edgeMargin.width = -3.;
  
//    NSString *groupsTitle = [Resources isPro] ? @"Groups" : @"Groups (Pro)";
    NSString *groupsTitle = @"Groups";

    UIBarButtonItem *groupsButton = [UIBarButtonItem skinBarItemWithTitle:groupsTitle target:self action:@selector(showFolderManagementView)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *sortButton = [UIBarButtonItem skinBarItemWithTitle:@"Sort" target:self action:@selector(sortFoldersAlphabetically)];
    NSArray *toolbarItems = [NSArray arrayWithObjects:edgeMargin, groupsButton, spacer, discoverButton, spacer, sortButton, edgeMargin, nil];
    [self setToolbarItems:toolbarItems animated:YES];
  
    [self.navigationController setToolbarHidden:NO animated:YES];
  
    [self updateEditIconInCustomNavigationBar];
}

- (void)disableEditMode;
{
    [super disableEditMode];
  
    [(PostsNavigation *)self.navigationController replaceNavigationItemWithCustomBackButton:self.navigationItem];
    [[NavigationManager shared] interactionIconsNeedUpdate];
    if ([Resources useActionMenu])
    {
      [self.navigationController setToolbarHidden:YES animated:YES];
    }
    [self updateEditIconInCustomNavigationBar];
}

- (void)updateEditIconInCustomNavigationBar;
{
  BSELF(RedditsViewController_iPhone);
  NSString *title = self.tableView.isEditing ? @"Done" : @"Edit";
  ABCustomOutlineNavigationBar *customNavigationBar = (ABCustomOutlineNavigationBar *)self.attachedCustomNavigationBar;
  [customNavigationBar setCustomLeftButtonWithTitle:title onTapAction:^{
    if (blockSelf.tableView.isEditing)
    {
      [blockSelf disableEditMode];
    }
    else
    {
      [blockSelf enableEditMode];
    }
  }];
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  [self updateEditIconInCustomNavigationBar];
  if (self.tableView.isEditing)
  {
    [self.navigationController setToolbarHidden:NO animated:animated];
  }  
}

@end
