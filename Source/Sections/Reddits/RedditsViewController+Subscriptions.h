//
//  RedditsViewController+Subscriptions.h
//  AlienBlue
//
//  Created by J M on 8/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsViewController.h"
#import "AFHTTPRequestOperation.h"
#import "UserSubredditPreferences.h"

@interface RedditsViewController (Subscriptions)
@property BOOL forceServerRefresh;
@property BOOL isSyncing;
@property (readonly) UserSubredditPreferences *subredditPrefs;
@property (strong) AFHTTPRequestOperation *loadSubredditsOperation;


- (void)syncSubscriptions;
- (void)addRedditsSection;
@end
