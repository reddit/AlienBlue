//
//  AppDelegate_iPad.m
//  AlienBlue
//
//  Created by J M on 14/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "PostsNavigation_iPad.h"
#import "NavigationManager_iPad.h"
#import "UIApplication+ABAdditions.h"

@interface AppDelegate_iPad()
@end

@implementation AppDelegate_iPad

- (void)initWindow
{
  self.navigationManager = [UNIVERSAL(NavigationManager) new];
  [self.window setRootViewController:self.navigationManager.postsNavigation];
}

- (void)splashViewWillHide;
{
  DO_AFTER_WAITING(1., ^{
    [UIApplication ab_updateStatusBarTintWithTransition];
  });
}

@end
