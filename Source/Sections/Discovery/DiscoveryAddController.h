//
//  DiscoveryAddController.h
//  AlienBlue
//
//  Created by J M on 17/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "ABOutlineViewController.h"
#import "UserSubredditPreferences.h"
#import "Subreddit.h"

@interface DiscoveryAddController : ABOutlineViewController

@property (strong, readonly) Subreddit *subreddit;
@property (readonly) BOOL shouldShowFrontPageOption;
@property (readonly) BOOL excludeDontShowOption;
@property (readonly) BOOL excludeRemoveOption;

- (id)initWithSubreddit:(Subreddit *)subreddit onComplete:(ABAction)onComplete;
+ (UINavigationController *)navControllerForAddingSubreddit:(Subreddit *)subreddit onComplete:(ABAction)onComplete;
+ (UINavigationController *)navControllerForAddingSubreddit:(Subreddit *)subreddit onComplete:(ABAction)onComplete excludeDontShowOption:(BOOL)excludeDontShow excludeRemoveOption:(BOOL)excludeRemoveOption;

- (void)toggleSelectionForFolder:(SubredditFolder *)folder;

+ (void)resetDontAskOption;
+ (BOOL)shouldAddWithoutView;
+ (void)processAutomaticAddingOfSubreddit:(Subreddit *)subreddit onComplete:(ABAction)onComplete;
@end
