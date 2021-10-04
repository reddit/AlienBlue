//  REDListingViewController+CanvasSupport.m
//  RedditApp

#import "RedditApp/Listing/REDListingViewController+CanvasSupport.h"

#import "Common/Navigation/NavigationManager.h"
#import "Helpers/Resources.h"
#import "MKStoreKit/MKStoreManager.h"
#import "RedditApp/Listing/REDListingViewController+API.h"
#import "Sections/Posts/CanvasPreviewDemo.h"
#import "Sections/Posts/GalleryViewController.h"

@interface REDListingViewController (CanvasSupport_)
@property BOOL isCanvasShowing;
@property(strong, readonly) REDListingHeaderCoordinator *headerCoordinator;
@end

@implementation REDListingViewController (CanvasSupport)

SYNTHESIZE_ASSOCIATED_BOOL(isCanvasShowing, IsCanvasShowing);
SYNTHESIZE_ASSOCIATED_BOOL(shouldLaunchCanvasWithViewHidden, ShouldLaunchCanvasWithViewHidden);

- (void)showCanvasPreview;
{
  CanvasPreviewDemo *demoViewController =
      [[CanvasPreviewDemo alloc] initWithNibName:@"CanvasPreviewDemo" bundle:nil];
  ABNavigationController *nav =
      [[ABNavigationController alloc] initWithRootViewController:demoViewController];
  [[NavigationManager mainViewController] presentViewController:nav animated:YES completion:nil];
}

- (void)showCanvas;
{
  REQUIRES_PRO;
  self.isCanvasShowing = YES;
  NSString *additionalParams = [[self additionalURLParamsFromHeaderCoordinator] urlEncodedString];
  GalleryViewController *galleryController =
      [[UNIVERSAL(GalleryViewController) alloc] initWithSubredditUrl:self.subreddit
                                                    additionalParams:additionalParams
                                                               title:self.title];
  [self.navigationController pushViewController:galleryController animated:YES];
}

- (void)removeCanvas;
{ self.isCanvasShowing = NO; }

- (void)notifyCanvasViewWillAppearAnimated:(BOOL)animated;
{}

- (void)notifyCanvasViewWillDisappearAnimated:(BOOL)animated;
{}

- (void)notifyCanvasViewDidRotate:(UIInterfaceOrientation)fromInterfaceOrientation;
{}

- (void)notifyCanvasViewDidUnload;
{}

@end
