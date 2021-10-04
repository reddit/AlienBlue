//
//  SettingsViewController_iPad.m
//  AlienBlue
//
//  Created by J M on 2/03/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SettingsViewController_iPad.h"
#import "NavigationManager_iPad.h"
#import "AppDelegate_iPad.h"
#import "LoginPasswordController_iPad.h"
#import "SFHFKeychainUtils.h"
#import "OverlayViewContainer.h"
#import "GestureTutorialViewController.h"
#import "Resources.h"
#import "NCenteredTextCell.h"
#import "NSectionSpacerCell.h"

#define kGestureButtonTitle @"Useful Gestures and Pro-Tips"

@interface SettingsViewController()
- (NSMutableArray *)generateNodesForHomeScreen;
@end

@interface SettingsViewController_iPad()
@property (strong) OverlayViewContainer *headerView;
- (void)showGestureGuide;
@end

@implementation SettingsViewController_iPad

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        NSInteger settingsViewCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"settings_view_count"];
        [[NSUserDefaults standardUserDefaults] setInteger:(settingsViewCount + 1) forKey:@"settings_view_count"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

- (void)showGestureGuide;
{
    GestureTutorialViewController *controller = [GestureTutorialViewController new];
    [self.navigationController pushViewController:controller animated:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = YES;
}


- (void)postStyleChangeNotification;
{
    UIView *wrapper = [NavigationManager_iPad foldingNavigation].wrapperView;

    BSELF(SettingsViewController_iPad);
[blockSelf setNavbarTitle:blockSelf.navigationItem.title];
    [UIView animateWithDuration:0.6 animations:^{
        wrapper.left = wrapper.width;
//        [blockSelf nightModeSwitch];
        [blockSelf.headerView setNeedsDisplay];
        blockSelf.headerView.backgroundColor = [UIColor colorForBackground];
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNightModeSwitchNotification object:nil];
        [[NavigationManager_iPad foldingNavigation] layoutControllers];
        wrapper.right = 0.;
        [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
            wrapper.right = wrapper.width;
        } completion:nil];
    }];
}

- (NSMutableArray *)generateNodesForHomeScreen;
{
  NSMutableArray *homeNodes = [super generateNodesForHomeScreen];
  
  CenteredTextNode *gestureGuideNode = [CenteredTextNode nodeWithTitle:kGestureButtonTitle];
  BSELF(SettingsViewController_iPad);
  gestureGuideNode.onSelect = ^{
    [blockSelf showGestureGuide];
  };
  
  [homeNodes insertObject:gestureGuideNode atIndex:0];
  [homeNodes insertObject:[SectionSpacerNode spacerNodeWithCustomHeight:10. decoration:SectionSpacerDecorationNone] atIndex:1];
  
  return homeNodes;
}

@end
