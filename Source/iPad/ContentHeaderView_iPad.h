//
//  ContentHeaderView_iPad.h
//  AlienBlue
//
//  Created by J M on 19/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NavigationBar_iPad.h"
#import "Post.h"

#define kNavigationBarVoteStatusChanged @"kNavigationBarVoteStatusChanged"

@interface ContentHeaderView_iPad : NavigationBar_iPad
@property (readonly,strong) Post *post;
@property (readonly,strong) JMViewOverlay *actionButton;
@property (readonly,strong) UIBarButtonItem *actionBarButtonItemProxy;
- (void)updateWithPost:(Post *)post;
@end
