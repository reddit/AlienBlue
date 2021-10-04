//
//  PostsViewController+PopoverOptions.h
//  AlienBlue
//
//  Created by J M on 15/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController.h"

@interface PostsViewController (PopoverOptions)

@property (readonly) BOOL isSubscribedToSubreddit;
@property (readonly) BOOL isNativeSubreddit;

- (void)popupSubredditOptions;
- (void)showAddSubredditToGroup;
- (void)showSidebar;
- (void)showMessageModsScreen;
- (void)showGallery;
@end
