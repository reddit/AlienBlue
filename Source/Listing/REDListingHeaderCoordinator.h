//  REDListingHeaderCoordinator.h
//  RedditApp

#import <Foundation/Foundation.h>

#import "JMTabView/JMTabView/Classes/Subviews/JMTabView.h"
#import "Sections/Reddits/Subreddit+Moderation.h"

#define kPostOrderHot @""
#define kPostOrderNew @"new"
#define kPostOrderControversial @"controversial"
#define kPostOrderTop @"top"

#define kPostTopTimespanAll @"all"
#define kPostTopTimespanHour @"hour"
#define kPostTopTimespanToday @"day"
#define kPostTopTimespanWeek @"week"
#define kPostTopTimespanMonth @"month"
#define kPostTopTimespanYear @"year"

@class REDListingHeaderCoordinator;

@protocol REDPostsHeaderDelegate<NSObject>
- (UITableView *)tableView;
@property(strong, readonly) NSString *subreddit;
@property(strong, readonly) NSString *subredditTitle;
- (void)updateNavbarIcons;
- (void)updateNavbarTitle;
@end

@interface REDListingHeaderCoordinator : NSObject<UISearchBarDelegate>
@property(ab_weak) id<REDPostsHeaderDelegate> delegate;
@property(readonly, strong) NSString *sortOrder;
@property(readonly, strong) NSString *topTimespan;
@property(readonly, strong) NSString *searchSortOrder;
@property(readonly, strong) NSString *searchQuery;
@property(readonly) BOOL searchRestrictToSubreddit;
@property(readonly) SubredditModFolder modFolderSelection;
- (id)initWithDelegate:(id<REDPostsHeaderDelegate>)delegate onChange:(ABAction)handleChange;
- (UIView *)view;
- (void)layoutHeaderView;

- (BOOL)modFeaturesEnabled;
- (void)enableModFeatures;
@end
