#import "GalleryViewController_iPad.h"
#import "AppDelegate_iPad.h"
#import "Post+API.h"
#import "UIViewController+JMFoldingNavigation.h"

@interface GalleryViewController_iPad ()

@end

@implementation GalleryViewController_iPad

- (void)loadView;
{
  [super loadView];
  self.view.clipsToBounds = YES;
}

- (void)dismiss;
{
  BSELF(GalleryViewController_iPad);
  self.view.layer.shouldRasterize = YES;
  [UIView jm_animate:^{
    blockSelf.view.alpha = 0.;
  } completion:^{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [GalleryViewController_iPad fixStatusBarOverlapping];
    [blockSelf dismissAfterHidingStatusBar];
  }];
}

- (void)dismissAfterHidingStatusBar;
{
  [super dismiss];
  [self jm_dismiss];
  [[NSNotificationCenter defaultCenter] postNotificationName:kCanvasExitNotification object:nil];  
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
  [self switchToFocusForGalleryItem:nil animated:NO];
}

- (void)showCommentsForPost:(NSDictionary *)postDictionary;
{
  [self stopAutoplay];
  Post *post = [Post postFromDictionary:postDictionary];
  [post markVisited];
  [[NavigationManager shared] showCommentsForPost:post contextId:nil fromController:self.parentViewController];
}

- (BOOL)hidesStatusBarAndNavigationBarWhenPresented;
{
  return YES;
}

+ (void)fixStatusBarOverlapping;
{
  [UIView jm_animate:^{
    CGRect windowFrame = [[UIScreen mainScreen] applicationFrame];
    [UIApplication sharedApplication].keyWindow.rootViewController.view.frame = windowFrame;
  } completion:nil animated:YES];
}

//- (void)viewWillAppear:(BOOL)animated;
//{
//  [super viewWillAppear:animated];
////  self.wantsFullScreenLayout = YES;
////  self.parentViewController.wantsFullScreenLayout = YES;
////  self.parentViewController.navigationController.wantsFullScreenLayout = YES;
////  [super viewWillAppear:animated];
////  DLog(@"%@ in %@", NSStringFromCGRect(rootFrame), NSStringFromCGRect(windowFrame));
//}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  DO_AFTER_WAITING(1, ^{
    [GalleryViewController_iPad fixStatusBarOverlapping];
  });
}

//- (void)viewWillDisappear:(BOOL)animated;
//{
//  [GalleryViewController_iPad fixStatusBarOverlapping];
//  [super viewWillDisappear:animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated;
//{
//  [super viewDidDisappear:animated];
//}

//- (void)viewWillDisappear:(BOOL)animated;
//{
//  [super viewWillDisappear:animated];
//  
//  DLog(@"viewWillDisappear : animated: %d", animated);
//  [UIView jm_animate:^{
//    [GalleryViewController_iPad fixStatusBarOverlapping];
//  } completion:nil animated:YES];
//}

//- (void)viewDidAppear:(BOOL)animated;
//{
//  [super viewDidAppear:animated];
//  self.navigationController.view.frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
//}

@end
