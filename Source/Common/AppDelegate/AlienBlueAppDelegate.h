//
//  AlienBlueAppDelegate.h
//  Alien Blue :: http://alienblue.org
//
//  Created by Jason Morrissey on 28/03/10.
//  Copyright The Design Shed 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationManager.h"

@interface AlienBlueAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
{
  UIBackgroundTaskIdentifier backgroundTask;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NavigationManager *navigationManager;
@property (readonly) BOOL isActiveInForeground;

- (void)proVersionUpgraded;
- (void)stopPurchaseIndicator;

@end
