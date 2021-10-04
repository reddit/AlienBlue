#import "FullscreenGalleryController_iPad.h"
#import "JMOptimalStaticGalleryView.h"
#import "JMGalleryFocusCoordinator_iPad.h"
#import "JMCarouselView.h"
#import "JMSiteMedia.h"
#import "JMSiteMediaImgurHandler.h"
#import "JMSiteMediaQuickMemeHandler.h"

#import "SHK.h"
#import "MBProgressHUD.h"
#import "JMGalleryToolbarItem.h"
#import "JMGalleryInteractionToolbar.h"

@interface JMGalleryViewController(ABFullscreen_Private)
@property (readonly) JMGalleryFocusCoordinator_iPad *focusCoordinator;
- (void)handleSwipeDownward:(UISwipeGestureRecognizer *)gesture;
- (void)handleSwipeUpward:(UISwipeGestureRecognizer *)gesture;
@end

@interface JMGalleryFocusCoordinator_iPad(ABFullscreen_Private)
@property (strong) JMCarouselView *carouselView;
@end

@interface FullscreenGalleryController_iPad()
@property NSUInteger startingIndex;
@property (readonly) BOOL singlePhotoMode;
@property BOOL statusBarShouldShowAfterDismiss;
@end

@implementation FullscreenGalleryController_iPad

- (id)initWithGalleryItems:(NSArray *)galleryItems startingAtIndex:(NSUInteger)startingIndex;
{
  JM_SUPER_INIT(init);
  [self jm_usePreIOS7ScrollBehavior];
  [self.galleryItems addObjectsFromArray:galleryItems];
  self.startingIndex = startingIndex;
  [self.galleryItems each:^(JMGalleryItem *item) {
    if (!item.thumbnailUrl)
    {
      item.thumbnailUrl = JMFullscreenGalleryThumbnailFromURL([item.imageUrl URL]);
    }
  }];
  return self;
}

- (id)initWithImageUrls:(NSArray *)imageUrls startingAtIndex:(NSUInteger)startingIndex;
{
  NSArray *galleryItems = [imageUrls map:^id(NSString *imageUrl) {
    JMGalleryItem *galleryItem = [JMGalleryItem new];
    galleryItem.imageUrl = JMFullscreenGalleryDeeplinkFromURL([imageUrl URL]);
    galleryItem.thumbnailUrl = JMFullscreenGalleryThumbnailFromURL([imageUrl URL]);
    return galleryItem;
  }];
  return [self initWithGalleryItems:galleryItems startingAtIndex:startingIndex];
}

- (BOOL)singlePhotoMode;
{
  return self.galleryItems.count == 1;
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
  
  self.view.accessibilityLabel = @"Fullscreen Gallery";
  self.view.isAccessibilityElement = YES;
  
  BSELF(FullscreenGalleryController_iPad);

  self.focusCoordinator.onPinchCloseAction = ^{
    blockSelf.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [blockSelf dismiss];
  };
  
  if (self.singlePhotoMode)
  {
    self.focusCoordinator.onSingleTapAction = ^{
      [blockSelf dismiss];
    };
  }
  
  JMGalleryItem *startingGalleryItem = [self.galleryItems jm_objectAtIndexOrNil:self.startingIndex];
  [self switchToFocusForGalleryItem:startingGalleryItem animated:NO];
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];

//  [self.focusCoordinator willBecomeActiveForGalleryItem:self.focusCoordinator.lastActiveGalleryItem];
  if (self.singlePhotoMode)
  {
    [self.focusCoordinator toggleFullscreenAnimated:NO];
  }
  
  self.statusBarShouldShowAfterDismiss = ![UIApplication sharedApplication].statusBarHidden;
  
  if (JMIsIOS7())
  {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
  }
}

- (void)viewWillDisappear:(BOOL)animated;
{
  [super viewWillDisappear:animated];
  if (self.statusBarShouldShowAfterDismiss)
  {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
  }
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  [self.focusCoordinator.carouselView reloadData];
}

- (JMGalleryInteractionToolbar *)interactionToolbarView;
{
  JMGalleryInteractionToolbar *toolbar = [super interactionToolbarView];
  JMGalleryToolbarItem *shareButton = [[JMGalleryToolbarItem alloc] initWithIconName:@"canvas-action"];
  shareButton.right = toolbar.bounds.size.width - 12.;
  shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  shareButton.top = 10.;
  [toolbar addSubview:shareButton];
  [shareButton addTarget:self action:@selector(showSharingOptionsForCurrentGalleryItem) forControlEvents:UIControlEventTouchUpInside];
  return toolbar;
}

- (void)showSharingOptionsForCurrentGalleryItem;
{
  if (!self.focusCoordinator.lastActiveGalleryItem)
    return;
  
  NSURL *URL = [self.focusCoordinator.lastActiveGalleryItem.linkedUrl URL];
  NSString *title = self.focusCoordinator.lastActiveGalleryItem.title;
  SHKItem *item = [SHKItem URL:URL title:title];
  item.shareType = SHKShareTypeImage;
  
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
  BSELF(FullscreenGalleryController_iPad);
  
  void(^linkShareAction)(NSURL *deeplinkURL) = ^(NSURL *deeplinkURL){
    NSURLRequest *request = [NSURLRequest requestWithURL:deeplinkURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20.];
    AFImageRequestOperation *downloadImageOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
      [MBProgressHUD hideHUDForView:blockSelf.view animated:YES];
      item.image = image;
      SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
      [actionSheet jm_showInView:blockSelf.view];
    }];
    [downloadImageOperation start];
  };
  if (JMURLIsDirectLinkToImage(URL))
  {
    linkShareAction(URL);
  }
  else
  {
    [JMSiteMedia deeplinkedImageURLForLinkURL:URL onComplete:^(NSURL *deepURL) {
      linkShareAction(deepURL);
    } onFailure:nil];
  }
}

//- (void)switchToGridView;
//{
//  [self jm_dismiss];
//}
//
- (void)handleSwipeUpward:(UISwipeGestureRecognizer *)gesture;
{
  if (!self.singlePhotoMode)
  {
    [super handleSwipeUpward:gesture];
  }
}

- (void)dismiss;
{
  [self jm_dismiss];
  if (self.onDismiss)
  {
    self.onDismiss();
  }
}

- (void)handleSwipeDownward:(UISwipeGestureRecognizer *)gesture;
{
  if (self.isShowingGrid)
  {
    [super handleSwipeDownward:gesture];
  }
  else
  {
    [self dismiss];
  }
}

- (BOOL)showsCaptions;
{
  JMGalleryItem *anyItemWithCaption = [self.galleryItems match:^BOOL(JMGalleryItem *item) {
    return !JMIsEmpty(item.title);
  }];
  return anyItemWithCaption != nil;
}

- (BOOL)hidesStatusBarAndNavigationBarWhenPresented;
{
  return NO;
}

@end

#pragma mark - Fast Deeplinkers

NSString *JMFullscreenGalleryDeeplinkFromURL(NSURL *linkURL)
{
  if(JMURLIsDirectLinkToImage(linkURL))
  {
    return linkURL.absoluteString;
  }
  
  NSString *imgurUrl = JMImgurDeeplinkedImageOrNilFromURL(linkURL);
  if (imgurUrl)
  {
    return imgurUrl;
  }
  
  NSString *quickmemeUrl = JMQuickMemeDeeplinkedImageOrNilFromURL(linkURL);
  if (quickmemeUrl)
  {
    return quickmemeUrl;
  }
  return nil;
}

NSString *JMFullscreenGalleryThumbnailFromURL(NSURL *linkURL)
{
  NSString *imgurUrl = JMImgurThumbnailImageOrNilFromURL(linkURL);
  if (imgurUrl)
  {
    return imgurUrl;
  }
  
  NSString *quickmemeUrl = JMQuickMemeThumbnailImageOrNilFromURL(linkURL);
  if (quickmemeUrl)
  {
    return quickmemeUrl;
  }
  return nil;
}
