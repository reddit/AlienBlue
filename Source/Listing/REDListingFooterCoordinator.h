//  REDListingFooterCoordinator.h
//  RedditApp

#import <Foundation/Foundation.h>

#import "JMSlider/JMSlider/JMSlider.h"

@class REDListingFooterCoordinator;

@protocol REDPostsFooterDelegate<NSObject>
- (UITableView *)tableView;
- (NSInteger)nodeCount;

@optional
- (void)loadMore;
- (void)hideRead;
- (void)hideAll;
@end

@interface REDListingFooterCoordinator : NSObject<JMSliderDelegate>
@property(ab_weak) id<REDPostsFooterDelegate> delegate;
@property(strong) JMSlider *sliderView;
@property(strong) UILabel *pullLabel;
@property BOOL isShowingLoadingIndicator;

- (id)initWithDelegate:(id<REDPostsFooterDelegate>)delegate;
- (UIView *)view;
- (void)setShowLoadingIndicator:(BOOL)loading;

- (void)handleScrolling;
- (void)handleDragRelease;

- (void)disallowHorizontalSliderDragging;
@end
