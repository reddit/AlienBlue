//
//  PostsNavigation_iPad.h
//  AlienBlue
//
//  Created by J M on 14/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMFNNavigationController.h"
#import "SidePane_iPad.h"

@interface PostsNavigation_iPad : JMFNNavigationController
@property (readonly) BOOL showingSidePane;
@property (strong,readonly) SidePane_iPad *sidePane;
@property (strong) UIToolbar *toolbar;
- (void)setPaneTitle:(NSString *)title;

- (void)hideSidePaneAnimated:(BOOL)animated showingRevealButton:(BOOL)showingRevealButton;
- (void)showSidePaneAnimated:(BOOL)animated;

- (void)hideNotification;
- (void)showNotification:(NSString *)message;

@end
