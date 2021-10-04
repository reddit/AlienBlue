//
//  PostsHeaderCoordinator.h
//  AlienBlue
//
//  Created by J M on 10/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMTabView.h"
#import "Subreddit+Moderation.h"

#define kPostOrderHot @""
#define kPostOrderNew @"new"
#define kPostOrderControversial @"controversial"
#define kPostOrderTop @"top"

#define kPostSearchOrderRelevance @"relevance"
#define kPostSearchOrderNew @"new"
#define kPostSearchOrderTop @"top"
#define kPostSearchOrderComments @"comments"

#define kPostTopTimespanAll @"all"
#define kPostTopTimespanHour @"hour"
#define kPostTopTimespanToday @"day"
#define kPostTopTimespanWeek @"week"
#define kPostTopTimespanMonth @"month"
#define kPostTopTimespanYear @"year"

@class PostsHeaderCoordinator;

@protocol PostsHeaderDelegate <NSObject>
- (UITableView *)tableView;
@property (strong, readonly) NSString *subreddit;
@property (strong, readonly) NSString *subredditTitle;
- (void)updateNavbarIcons;
- (void)updateNavbarTitle;
@end

@interface PostsHeaderCoordinator : NSObject <UISearchBarDelegate>
@property (ab_weak) id<PostsHeaderDelegate> delegate;
@property (readonly, strong) NSString *sortOrder;
@property (readonly, strong) NSString *topTimespan;
@property (readonly, strong) NSString *searchSortOrder;
@property (readonly, strong) NSString *searchQuery;
@property (readonly) BOOL searchRestrictToSubreddit;
@property (readonly) BOOL showingSearch;
@property (readonly) SubredditModFolder modFolderSelection;
- (id)initWithDelegate:(id<PostsHeaderDelegate>)delegate onChange:(ABAction)handleChange;
- (UIView *)view;
- (void)showSearch;
- (void)hideSearch;
- (void)handleScrolling;
- (void)layoutHeaderView;

- (BOOL)modFeaturesEnabled;
- (void)enableModFeatures;
@end
