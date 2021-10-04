//
//  NavigationManager_iPad.m
//  AlienBlue
//
//  Created by J M on 14/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NavigationManager_iPad.h"

#import "RedditsViewController_iPad.h"
#import "Post.h"
#import "Post+Sponsored.h"
#import "BrowserViewController_iPad.h"
#import "FullScreenPhotoViewer_iPad.h"
#import "FullscreenGalleryController_iPad.h"
#import "CommentsViewController_iPad.h"
#import "UserDetailsViewController_iPad.h"
#import "MessagesViewController_iPad.h"
#import "SettingsViewController_iPad.h"
#import "PortraitTipViewController.h"
#import "PostsViewController_iPad.h"
#import "CreatePostViewController.h"
#import "SendMessageViewController+Submit.h"
#import "NavigationManager+Deprecated.h"
#import "SHK.h"
#import "RedditAPI+Account.h"
#import "ScreenLockViewController.h"

@interface NavigationManager()
@property (strong) Post *lastVisitedPost;
@property (strong) NSString *lastVisitedSubreddit;
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@interface NavigationManager_iPad();
@property (readonly) PostsNavigation_iPad *foldingNavigation;
@property (strong) UIPopoverController *popoverController;
@property (strong) NSString *subredditTitle;
@end

@implementation NavigationManager_iPad

- (PostsNavigation_iPad *)foldingNavigation;
{
  return (PostsNavigation_iPad *)self.postsNavigation;
}

+ (PostsNavigation_iPad *)foldingNavigation;
{
  return [(NavigationManager_iPad *)[NavigationManager_iPad shared] foldingNavigation];
}

- (void)showBrowserForUrl:(NSString *)url fromController:(UIViewController *)fromController;
{
  BrowserViewController_iPad * browserView = [[BrowserViewController_iPad alloc] initWithUrl:url];
  [self.foldingNavigation pushViewController:browserView afterPoppingToController:fromController];
}

- (void)showBrowserForPost:(Post *)npost fromController:(UIViewController *)fromController;
{
  [npost trackSponsoredLinkVisitIfNecessary];
  
  self.lastVisitedPost = npost;
  
  NSMutableDictionary *legacyDictionary = npost.legacyDictionary;
  [legacyDictionary setObject:npost.url forKey:@"url"];
  self.deprecated_legacyPostDictionary = legacyDictionary;
  
	BrowserViewController_iPad * browserView = [[BrowserViewController_iPad alloc] initWithPost:npost];
	[self.foldingNavigation pushViewController:browserView afterPoppingToController:fromController];
}

- (void)browseToURLFromMessageForIPAD:(NSString *) url
{
  [self dismissModalView];
	BrowserViewController_iPad * browserView = [[BrowserViewController_iPad alloc] initWithUrl:url];
	[self.foldingNavigation pushViewController:browserView afterPoppingToController:self.foldingNavigation.topViewController];
}

- (void)showCommentsForPost:(Post *)npost contextId:(NSString *)contextId fromController:(UIViewController *)fromController;
{
  [npost trackSponsoredCommentsVisitIfNecessary];
  
  self.lastVisitedPost = npost;
  self.deprecated_legacyPostDictionary = npost.legacyDictionary;

  NSString *context = nil;
  if (contextId)
  {
    context = [contextId convertRedditNameToIdent];
  }
  
  CommentsViewController_iPad *comments = [[CommentsViewController_iPad alloc] initWithPost:npost contextId:context];
	[self.foldingNavigation pushViewController:comments afterPoppingToController:fromController];
}

- (void)showPostsForSubreddit:(NSString *)sr title:(NSString *)title fromController:(UIViewController *)fromController;
{
  self.lastVisitedSubreddit = sr;
  self.subredditTitle = title;
  NSString *srPath = [sr generateSubredditPathFromSubredditTitle];
  PostsViewController_iPad *postsController = [[PostsViewController_iPad alloc] initWithSubreddit:srPath title:title];
	[self.foldingNavigation pushViewController:postsController afterPoppingToController:fromController];
}

- (void)goBack;
{
  if ([[self.foldingNavigation viewControllers] count] > 2)
  {
    [self.foldingNavigation popViewControllerAnimated:YES];
  }
}

- (void)goHome;
{
  [self.foldingNavigation activateController:self.foldingNavigation.rootViewController scrolling:YES pagingDirection:JMFNPagingDirectionRight];
}

- (void)showMessagesScreen;
{
  REQUIRES_REDDIT_AUTHENTICATION;

  [self.foldingNavigation dismissModalViewControllerAnimated:NO];
  NSString *defaultBoxUrl = [RedditAPI shared].hasModMail && ![RedditAPI shared].hasMail ? @"/message/moderator/" : @"/message/inbox/";
  MessagesViewController *mvc = [[UNIVERSAL(MessagesViewController) alloc] initWithBoxUrl:defaultBoxUrl];
  ABNavigationController *messagesNavigation = [[ABNavigationController alloc] initWithRootViewController:mvc];
  messagesNavigation.toolbarHidden = YES;
  messagesNavigation.navigationBarHidden = YES;
  messagesNavigation.modalPresentationStyle = UIModalPresentationFormSheet;
  messagesNavigation.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self.foldingNavigation presentModalViewController:messagesNavigation animated:YES];
}

- (void)showUserDetails:(NSString *)username;
{
  UserDetailsViewController_iPad *controller = [[UserDetailsViewController_iPad alloc] initWithUsername:username];
  [self.postsNavigation pushViewController:controller animated:YES];
}

- (void)showSendDirectMessageScreenForUser:(NSString *)username;
{
  REQUIRES_REDDIT_AUTHENTICATION;
  [self.foldingNavigation dismissModalViewControllerAnimated:NO];
  SendMessageViewController *pmViewController = [[SendMessageViewController alloc] initWithUsername:username];
  ABNavigationController * navc = [[ABNavigationController alloc] initWithRootViewController:pmViewController];
  navc.modalPresentationStyle = UIModalPresentationFormSheet;
  navc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self.foldingNavigation presentModalViewController:navc animated:YES];
}

- (void)showCreatePostScreen;
{
  REQUIRES_REDDIT_AUTHENTICATION;
  [self.foldingNavigation dismissModalViewControllerAnimated:NO];
  ABNavigationController *navc = [CreatePostViewController viewControllerWithNavigation];
  navc.modalPresentationStyle = UIModalPresentationFormSheet;
  navc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self.foldingNavigation presentModalViewController:navc animated:YES];
}

- (void)showSettingsScreen;
{
  SettingsViewController *controller = [[UNIVERSAL(SettingsViewController) alloc] initWithSettingsSection:SettingsSectionHome];
  ABNavigationController *nav = [[ABNavigationController alloc] initWithRootViewController:controller];
  nav.modalPresentationStyle = UIModalPresentationFormSheet;
  nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self.foldingNavigation presentModalViewController:nav animated:YES];
}

- (void)showPortraitSelectionTip;
{
  UIViewController *tipController = [PortraitTipViewController controller];

  [self dismissPopoverIfNecessary];
  self.popoverController = [[UIPopoverController alloc] initWithContentViewController:tipController];
  [self.popoverController presentPopoverFromRect:self.foldingNavigation.sidePane.tipButton.frame inView:[NavigationManager_iPad mainView] permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void)presentScreenLock;
{
  [self.foldingNavigation dismissModalViewControllerAnimated:NO];
  [self.foldingNavigation.view setHidden:YES];
  ScreenLockViewController * sc = [[ScreenLockViewController alloc] initWithNibName:@"ScreenLockView" bundle:nil];
  sc.modalPresentationStyle = UIModalPresentationFullScreen;
  sc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self.foldingNavigation presentModalViewController:sc animated:YES];
}

- (void)dismissModalView;
{
  // incase this was hidden via screen lock
  [self.foldingNavigation.view setHidden:NO];
  [self.foldingNavigation dismissModalViewControllerAnimated:YES];
}

- (void)handleHidePromptNotification;
{
  [self.foldingNavigation hideNotification];
}

- (void)handleShowPromptNotification:(NSString *)prompt;
{
  [self.foldingNavigation showNotification:prompt];
}

#pragma mark - Fullscreen Image Galleries

- (void)showFullScreenViewerForGalleryItems:(NSArray *)galleryItems startingAtIndex:(NSUInteger)atIndex;
{
  FullscreenGalleryController_iPad *controller = [[FullscreenGalleryController_iPad alloc] initWithGalleryItems:galleryItems startingAtIndex:atIndex];
  controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  controller.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.foldingNavigation presentViewController:controller animated:YES completion:nil];
}

- (void)showFullScreenViewerForImageUrls:(NSArray *)imageUrls startingAtIndex:(NSUInteger)atIndex onDismiss:(JMAction)onDismiss;
{
  FullscreenGalleryController_iPad *controller = [[FullscreenGalleryController_iPad alloc] initWithImageUrls:imageUrls startingAtIndex:atIndex];
  controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  controller.modalPresentationStyle = UIModalPresentationFullScreen;
  controller.onDismiss = onDismiss;
  [self.foldingNavigation presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Popover Management

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  [self dismissPopoverIfNecessary];
}

- (void)dismissPopoverIfNecessary;
{
  if (self.popoverController)
  {
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
  }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popController
{
  self.popoverController = nil;
}

- (void)showPopoverWithContentViewController:(UIViewController *)contentViewController inView:(UIView *)viewToPresentIn fromRect:(CGRect)fromRect permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections;
{
  [self dismissPopoverIfNecessary];
  self.popoverController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
  BSELF(NavigationManager_iPad);
  DO_IN_MAIN(^{
    [blockSelf.popoverController presentPopoverFromRect:fromRect inView:viewToPresentIn permittedArrowDirections:arrowDirections animated:YES];
  });
}

#pragma mark - Testing

//- (void)postLaunchTesting;
//{
//  [[NavigationManager shared] showSettingsScreen];
//  
////  UIActionSheet *testSheet = [UIActionSheet bk_actionSheetWithTitle:@"Test Action Sheet"];
////  [testSheet bk_addButtonWithTitle:@"Test Button 1" handler:^{
////    DLog(@"button 1 pressed");
////  }];
////
////  [testSheet bk_addButtonWithTitle:@"Test Button 2" handler:^{
////    DLog(@"button 2 pressed");
////  }];
////  
////  [testSheet bk_setDestructiveButtonWithTitle:@"Test Destructive Button" handler:^{
////    DLog(@"destructive button pressed");
////  }];
////
////  [testSheet jm_showInView:self.postsNavigation.view];
//  
//}

@end
