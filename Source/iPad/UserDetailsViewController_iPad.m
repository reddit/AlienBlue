//
//  UserDetailsViewController_iPad.m
//  AlienBlue
//
//  Created by J M on 1/03/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "UserDetailsViewController_iPad.h"
#import "MessagesViewController_iPad.h"
#import "PostsViewController_iPad.h"
#import "NavigationBar_iPad.h"
#import "UIViewController+JMFoldingNavigation.h"

@implementation UserDetailsViewController_iPad

- (CGFloat)pageWidth;
{
  return JMPortrait() ? 400. : 436.;
}

- (void)loadView;
{
  [super loadView];
  NavigationBar_iPad *headerView = [[NavigationBar_iPad alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 55.)];
  headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  headerView.title = [@"About : " stringByAppendingString:self.username];
  [self.view addSubview:headerView];
  
  self.tableView.top = headerView.height - 5.;
  self.tableView.height -= self.tableView.top;
  self.tableView.tableFooterView = nil; 
}

@end
