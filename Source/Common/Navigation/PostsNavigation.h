//
//  PostsNavigation.h
//  AlienBlue
//
//  Created by JM on 5/09/10.
//  Copyright (c) 2010 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedditAPI.h"
#import "ABNavigationController.h"
#import "JMSlideableNavigation.h"

@interface PostsNavigation : JMSlideableNavigationController
{
}

// fixes an iOS 7 related issue that occurs when another push/pop call is made
// during an existing push/pop animation
@property BOOL shouldSuppressPushingOrPopping;

- (UIViewController *)secondLastController;
+ (PostsNavigation *)postsNavigationWithRootControllerOrNil:(UIViewController *)rootControllerOrNil;
- (void)replaceNavigationItemWithCustomBackButton:(UINavigationItem *)item;
- (void)customBackTapped;

@end
