//
//  RedditAddController.h
//  AlienBlue
//
//  Created by J M on 25/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "ABOutlineViewController.h"
#import "SubredditSelectorViewController.h"
#import "SubredditFolder.h"

@interface RedditAddController : ABOutlineViewController

- (id)initWithDestinationFolder:(SubredditFolder *)folder;
+ (UINavigationController *)navControllerForAddingToSubredditFolder:(SubredditFolder *)folder;

@end
