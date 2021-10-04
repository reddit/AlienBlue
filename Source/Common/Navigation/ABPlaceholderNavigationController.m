//
//  ABPlaceholderNavigationController.m
//  AlienBlue
//
//  Created by JM on 3/09/13.
//
//

#import "ABPlaceholderNavigationController.h"
#import "UINavigationController+ABAdditions.h"

@interface ABPlaceholderNavigationController ()

@end

@implementation ABPlaceholderNavigationController

- (BOOL)shouldAutorotate;
{
  // fix for iOS 7 status bar showing up on the side when launching in landscape
  return JMIsIphone() ? NO : YES;
}

@end
