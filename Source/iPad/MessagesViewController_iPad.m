//
//  MessagesTableViewController_iPad.m
//  AlienBlue
//
//  Created by J M on 1/03/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "MessagesViewController_iPad.h"
#import "NavigationBar_iPad.h"
#import "NavigationManager_iPad.h"
#import "AlienBlueAppDelegate.h"
#import "CommentEntryViewController.h"

@implementation MessagesViewController_iPad

- (void)loadView;
{
    [super loadView];
    if (self.shouldDecorateAsUserComments)
    {
        NavigationBar_iPad *headerView = [[NavigationBar_iPad alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 55.)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.title = @"User Comments";
        [self.view addSubview:headerView];

        self.tableView.top = headerView.height - 5.;
        self.tableView.height -= self.tableView.top;
        self.tableView.tableFooterView = nil; 
    }
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = YES;
}

@end
