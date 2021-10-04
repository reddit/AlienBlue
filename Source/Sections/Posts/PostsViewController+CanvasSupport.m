//
//  PostsViewController+CanvasSupport.m
//  AlienBlue
//
//  Created by J M on 12/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController+CanvasSupport.h"
#import "Resources.h"
#import "NavigationManager.h"
#import "CanvasPreviewDemo.h"
#import "GalleryViewController.h"
#import "PostsViewController+API.h"
#import "MKStoreManager.h"

@interface PostsViewController (CanvasSupport_)
@property BOOL isCanvasShowing;
@property (strong, readonly) PostsHeaderCoordinator *headerCoordinator;
@end

@implementation PostsViewController (CanvasSupport)

SYNTHESIZE_ASSOCIATED_BOOL(isCanvasShowing, IsCanvasShowing);
SYNTHESIZE_ASSOCIATED_BOOL(shouldLaunchCanvasWithViewHidden, ShouldLaunchCanvasWithViewHidden);

- (void)showCanvasPreview;
{
	CanvasPreviewDemo * demoViewController = [[CanvasPreviewDemo alloc] initWithNibName:@"CanvasPreviewDemo" bundle:nil];
  ABNavigationController *nav = [[ABNavigationController alloc] initWithRootViewController:demoViewController];
  [[NavigationManager mainViewController] presentViewController:nav animated:YES completion:nil];
}

- (void)showCanvas;
{
  REQUIRES_PRO;
  self.isCanvasShowing = YES;
  NSString *additionalParams = [[self additionalURLParamsFromHeaderCoordinator] urlEncodedString];
	GalleryViewController *galleryController = [[UNIVERSAL(GalleryViewController) alloc] initWithSubredditUrl:self.subreddit additionalParams:additionalParams title:self.title];
  [self.navigationController pushViewController:galleryController animated:YES];
}

- (void)removeCanvas;
{
  self.isCanvasShowing = NO;
}

- (void)notifyCanvasViewWillAppearAnimated:(BOOL)animated;
{
}

- (void)notifyCanvasViewWillDisappearAnimated:(BOOL)animated;
{
}

- (void)notifyCanvasViewDidRotate:(UIInterfaceOrientation)fromInterfaceOrientation;
{
}

- (void)notifyCanvasViewDidUnload;
{
}

@end
