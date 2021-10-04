//
//  UINavigationController+ABAdditions.m
//  AlienBlue
//
//  Created by JM on 2/12/12.
//
//

#import "UINavigationController+ABAdditions.h"
#import "Resources.h"
#import "NavigationManager.h"
#import "BrowserViewController.h"
#import "GalleryViewController.h"

@implementation UINavigationController (ABAdditions)

+ (BOOL)ab_shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
	if ([Resources isIPAD])
		return YES;
	
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return NO;
	
  if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) && ![UDefaults boolForKey:kABSettingKeyAllowRotation])
    return NO;
	
	return YES;
}

+ (BOOL)ab_shouldAutorotate;
{
  return YES;
}

+ (NSUInteger)ab_supportedInterfaceOrientations;
{
  if ([Resources isIPAD])
    return UIInterfaceOrientationMaskAll;
  
  if (![NavigationManager shared].postsNavigation.presentedViewController)
  {
    BrowserViewController *browser = JMIsKindClassOrNil([NavigationManager shared].postsNavigation.topViewController, BrowserViewController);
    if (browser && [browser.currentURL contains:@"youtube.com"])
    {
      return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    GalleryViewController *gallery = JMIsKindClassOrNil([NavigationManager shared].postsNavigation.topViewController, GalleryViewController);
    if (gallery)
      return UIInterfaceOrientationMaskAllButUpsideDown;
  }
  
  if (![UDefaults boolForKey:kABSettingKeyAllowRotation])
  {
    return UIInterfaceOrientationMaskPortrait;
  }
  
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
