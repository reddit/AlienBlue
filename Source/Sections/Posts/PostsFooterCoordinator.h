//
//  PostsFooterCoordinator.h
//  AlienBlue
//
//  Created by J M on 10/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMSlider.h"

@class PostsFooterCoordinator;

@protocol PostsFooterDelegate <NSObject>
- (UITableView *)tableView;
- (NSInteger)nodeCount;

@optional
- (void)loadMore;
- (void)hideRead;
- (void)hideAll;
@end

@interface PostsFooterCoordinator : NSObject <JMSliderDelegate>
@property (ab_weak) id<PostsFooterDelegate> delegate;
@property (strong) JMSlider *sliderView;
@property (strong) UILabel *pullLabel;
@property BOOL isShowingLoadingIndicator;

- (id)initWithDelegate:(id<PostsFooterDelegate>)delegate;
- (UIView *)view;
- (void)setShowLoadingIndicator:(BOOL)loading;

- (void)handleScrolling;
- (void)handleDragRelease;

- (void)disallowHorizontalSliderDragging;
@end
