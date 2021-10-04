//
//  PostsNavigationTitleView.h
//  AlienBlue
//
//  Created by J M on 2/06/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayViewContainer.h"
#import "Subreddit.h"

@interface PostsNavigationTitleView : OverlayViewContainer
- (id)initWithFrame:(CGRect)frame forSubreddit:(Subreddit *)subreddit;
@end
