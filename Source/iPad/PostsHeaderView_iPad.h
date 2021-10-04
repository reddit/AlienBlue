//
//  PostsHeaderView_iPad.h
//  AlienBlue
//
//  Created by J M on 15/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationBar_iPad.h"

@class Subreddit;

@interface PostsHeaderView_iPad : NavigationBar_iPad
@property (strong, readonly) JMViewOverlay *searchButton;
@property (strong, readonly) JMViewOverlay *createPostButton;
@property (strong, readonly) JMViewOverlay *showCanvasButton;
@property (strong, readonly) JMViewOverlay *subredditIconOverlay;

- (id)initWithFrame:(CGRect)frame forSubreddit:(Subreddit *)subreddit;
@end
