//
//  FoldersViewController.h
//  AlienBlue
//
//  Created by J M on 11/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "ABOutlineViewController.h"
#import "UserSubredditPreferences.h"

@interface FoldersViewController : ABOutlineViewController
@property (readonly, strong) UserSubredditPreferences *subredditPrefs;
- (id)initWithSubredditPreferences:(UserSubredditPreferences *)subredditPrefs  onComplete:(ABAction)onComplete;
+ (UINavigationController *)navControllerWithSubredditPreferences:(UserSubredditPreferences *)subredditPrefs onComplete:(ABAction)onComplete;
- (void)animateFolderChanges;
- (void)generateNodes;
@end
