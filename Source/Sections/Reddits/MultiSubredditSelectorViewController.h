//
//  MultiSubredditSelectorViewController.h
//  AlienBlue
//
//  Created by J M on 4/06/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "ABOutlineViewController.h"
#import "SubredditFolder.h"

@interface MultiSubredditSelectorViewController : ABOutlineViewController

- (id)initWithSourceFolder:(SubredditFolder *)folder onComplete:(void (^)(NSArray *subreddits))onComplete;

@end
