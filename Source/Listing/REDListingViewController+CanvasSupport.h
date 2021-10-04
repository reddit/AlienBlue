//  REDListingViewController+CanvasSupport.h
//  RedditApp

#import "RedditApp/Listing/REDListingViewController.h"

@interface REDListingViewController (CanvasSupport)
@property BOOL shouldLaunchCanvasWithViewHidden;
@property(readonly) BOOL isCanvasShowing;

- (void)removeCanvas;
- (void)notifyCanvasViewDidRotate:(UIInterfaceOrientation)fromInterfaceOrientation;
- (void)notifyCanvasViewWillAppearAnimated:(BOOL)animated;
- (void)notifyCanvasViewWillDisappearAnimated:(BOOL)animated;
- (void)notifyCanvasViewDidUnload;
- (void)showCanvas;
@end
