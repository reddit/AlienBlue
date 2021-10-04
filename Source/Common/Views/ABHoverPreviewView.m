#import "ABHoverPreviewView.h"
#import "JMGalleryFocusMediaView.h"
#import "JMGalleryItem+MediaFetch.h"
#import "JMSiteMedia.h"
#import "ABWindow.h"
#import "ABHoverLoadingIndicatorView.h"
#import "ABHoverScrubberView.h"
#import "JMOptimalStaticGalleryView.h"
#import "JMGalleryPagingView.h"
#import "JMAlbumContentOptimizer.h"
#import "JMGalleryImageScrollView.h"
#import "JMSiteMediaImgurHandler.h"

#define kABHoverPreviewArrowHeight 16.

#define kABHoverPreviewIndetermineProgress -1.

#define kABHoverPreviewMinimumSecondsToWaitBeforeAttemptingLoad 0.25
#define kABHoverPreviewMinimumSecondsToWaitBeforeDisplaying 0.1
#define kABHoverPreviewManualAdjustmentTouchBuffer 3.

#define kABHoverPreviewDragDistanceToDimiss 100.

@interface ABHoverPreviewView()
@property (strong) UIImageView *frostedUnderlayView;
@property (strong) JMOptimalStaticGalleryView *galleryView;
@property (strong) UIImageView *arrowClippingView;
@property (strong) UIImageView *contentContainerView;
@property (strong) ABHoverLoadingIndicatorView *loadingIndicator;
@property (strong) ABHoverScrubberView *scrubberView;
@property (copy) JMAction onSuccessfulPresentationAction;

@property (readonly) UIView *attachToView;
@property (strong) NSURL *previewURL;
@property CGRect presentedFromRect;

@property BOOL shouldShowStatusBarDismiss;
@property BOOL shouldSkipStatusBarManipulationOnDismiss;
@property NSTimeInterval timeOfTouchStart;
@property BOOL isCancelling;
@property BOOL previewIsActivated;
@property CGPoint moveStartPoint;
@property CGSize aspectContentSize;
@property CGSize initialContainerSize;
@property BOOL mediaDidLoad;

@property (readonly) JMGalleryFocusMediaView *activeFocusMediaView;
@property (readonly) BOOL isYouTubeVideo;
@property (readonly) BOOL isAlbum;

@end

@implementation ABHoverPreviewView

static ABHoverPreviewView *s_currentHoverPreview = nil;
static NSTimeInterval s_lastDismissedTimestamp = 0;

- (instancetype)initWithURL:(NSURL *)URL presentedFromRect:(CGRect)presentedFromRect;
{
  JM_SUPER_INIT(init);
  
  self.previewURL = URL;
  self.presentedFromRect = presentedFromRect;
  
  self.frostedUnderlayView = [[UIImageView alloc] initWithFrame:self.bounds];
  self.frostedUnderlayView.autoresizingMask = JMFlexibleSizeMask;
  [self addSubview:self.frostedUnderlayView];
  
  self.contentContainerView = [UIImageView new];
  self.contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.contentContainerView.clipsToBounds = NO;
  self.contentContainerView.backgroundColor = [UIColor clearColor];
  [self addSubview:self.contentContainerView];
  
  self.galleryView = [JMOptimalStaticGalleryView new];
  self.galleryView.shouldAutoresizeContentsWithoutDelay = YES;
  [self.contentContainerView addSubview:self.galleryView];
  
  self.arrowClippingView = [[UIImageView alloc] initWithSize:CGSizeMake(self.contentContainerView.size.width, kABHoverPreviewArrowHeight)];
  self.arrowClippingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  self.arrowClippingView.backgroundColor = [UIColor clearColor];
  self.arrowClippingView.bottom = self.contentContainerView.height + 1.;
  [self.contentContainerView addSubview:self.arrowClippingView];
  
  self.scrubberView = [[ABHoverScrubberView alloc] initWithSize:CGSizeMake(self.contentContainerView.size.width, kABHoverPreviewArrowHeight)];
  [self.scrubberView setStartingTouchCenterXOffset:CGRectGetMidX(self.presentedFromRect)];
  self.scrubberView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  self.scrubberView.bottom = self.contentContainerView.bounds.size.height;
  self.scrubberView.hidden = YES;
  [self.contentContainerView addSubview:self.scrubberView];
  
  self.loadingIndicator = [ABHoverLoadingIndicatorView new];
  
  return self;
}

- (JMGalleryFocusMediaView *)activeFocusMediaView;
{
  return self.galleryView.activeFocusMediaView;
}

- (void)prepareBlurUnderlayView;
{
  BSELF(ABHoverPreviewView);
  self.loadingIndicator.hidden = YES;
  UIImage *viewHierarchySnapshotImage = [self.attachToView jm_imageRepresentation];
  self.loadingIndicator.hidden = NO;
  
  UIColor *averageBackgroundColor = [viewHierarchySnapshotImage jm_averageColor];
  UIColor *tintColor = [averageBackgroundColor colorWithAlphaComponent:0.4];
  self.frostedUnderlayView.opaque = YES;
  self.frostedUnderlayView.backgroundColor = [viewHierarchySnapshotImage jm_averageColor];
  
  DO_IN_BACKGROUND(^{
    UIImage *blurredSnapshot = [viewHierarchySnapshotImage jm_applyBlurWithRadius:4 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil opaque:YES];
    DO_IN_MAIN(^{
      blockSelf.frostedUnderlayView.image = blurredSnapshot;
      blockSelf.frostedUnderlayView.opaque = YES;
      [blockSelf updateArrowClippingViewImage];
    });
  });
}

- (void)updateArrowClippingViewImage;
{
  BSELF(ABHoverPreviewView);
  UIImage *clippedBackgroundImage = [self.frostedUnderlayView.image jm_clipToRect:self.arrowClippingView.frame];
  UIImage *image = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    CGFloat triangleCenterX = CGRectGetMidX(blockSelf.presentedFromRect);
    CGPoint triangleCenter = CGPointMake(triangleCenterX, kABHoverPreviewArrowHeight / 2. - 5.);
    UIBezierPath *trianglePath = [UIBezierPath bezierPathWithTriangleCenter:CGPointZero sideLength:kABHoverPreviewArrowHeight angle:180.];
    [trianglePath applyTransform:CGAffineTransformMakeScale(2, 1.)];
    [trianglePath applyTransform:CGAffineTransformMakeTranslation(triangleCenter.x, triangleCenter.y)];
    
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:bounds];
    clipPath.usesEvenOddFillRule = YES;
    [clipPath appendPath:trianglePath];

    CGContextRef context = UIGraphicsGetCurrentContext();
    [clipPath addClip];
    [clippedBackgroundImage drawAtPoint:CGPointZero];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectCropToTop(bounds, 10.)];
    [shadowPath applyTransform:CGAffineTransformMakeTranslation(0., -10.)];
    [shadowPath appendPath:trianglePath];
    
    CGContextSetShadowWithColor(context, CGSizeMake(0., 1.), 5., [UIColor blackColor].CGColor);
    [shadowPath setLineWidth:0.3];
    [shadowPath stroke];
  } opaque:NO withSize:self.arrowClippingView.size cacheKey:nil];
  self.arrowClippingView.image = image;
}

NSString *JMAppendReducedSizeImgurSuffixIfNecessary(NSString *imageUrl)
{
  if (![imageUrl jm_contains:@"imgur.com"])
    return imageUrl;
  
  NSString *imgurIdent = JMImgurIdentFromURL([imageUrl URL]);
  
  if (!imgurIdent)
    return imageUrl;
  
  if (![imageUrl jm_contains:@".jpg"] && ![imageUrl jm_contains:@".png"])
    return imageUrl;
  
  // h = huge (typically limited to 1024 pixels wide)
  // l = large (limited to 640px)
  return [NSString stringWithFormat:@"http://i.imgur.com/%@l.jpg", imgurIdent];
}


- (void)prepareGalleryItemsOnComplete:(void(^)(NSArray *preparedGalleryItems))onComplete;
{
  BSELF(ABHoverPreviewView);
  JMGalleryItem *item = [JMGalleryItem new];
  
  if (JMURLIsDirectLinkToImage(self.previewURL) || [self.previewURL.absoluteString jm_contains:@"gfycat.com"])
  {
    item.imageUrl = self.previewURL.absoluteString;
    onComplete(@[item]);
    return;
  }
  
  if (self.isAlbum)
  {
    [self prepareGalleryItemsForAlbumOnComplete:onComplete];
    return;
  }
  
  // attempting deeplink search
  item.linkedUrl = self.previewURL.absoluteString;
  [JMGalleryItem updateGalleryItemsWithThumbnailAndMediaUrls:@[item] shouldStopWhen:^BOOL{
    return NO;
  } onComplete:^(NSArray *galleryReadyItems) {
    DO_IN_MAIN(^{
      if (galleryReadyItems.count != 1)
      {
          [blockSelf failedToObtainPreview];
      }
      else
      {
        onComplete(galleryReadyItems);
      }
    });
  } skipThumbnailExtraction:YES];
}

- (void)prepareGalleryItemsForAlbumOnComplete:(void(^)(NSArray *preparedGalleryItems))onComplete;
{
  BSELF(ABHoverPreviewView);
  [JMAlbumContentOptimizer fetchAlbumGalleryItemsFromURL:self.previewURL onComplete:^(NSString *albumTitle, NSArray *galleryItems) {
    onComplete(galleryItems);
  } onError:^(NSString *errorMessage) {
    [blockSelf failedToObtainPreview];
  }];
}

+ (BOOL)canShowPreviewForURL:(NSURL *)URL;
{
  if (JMIsIpad())
    return NO;
  
  BOOL isCompatibleAlbum = [JMAlbumContentOptimizer canHandleOptimizationForURL:URL];
  return isCompatibleAlbum || JMURLIsDirectLinkToImage(URL) || [JMGalleryItem isGalleryCompatibleURL:URL] || [JMSiteMedia hasDeeplinkedImageForURL:URL];
}

- (void)loadDidProgress:(CGFloat)progress;
{
  [self.loadingIndicator updateWithProgressRatio:progress];
}

- (void)presentLoadedPreviewOnscreen;
{
  if (self.isCancelling)
    return;

  BSELF(ABHoverPreviewView);
  NSTimeInterval expectedPresentationTime = self.timeOfTouchStart + kABHoverPreviewMinimumSecondsToWaitBeforeAttemptingLoad + kABHoverPreviewMinimumSecondsToWaitBeforeDisplaying;
  NSTimeInterval nowTime = CACurrentMediaTime();
  if (nowTime <= expectedPresentationTime)
  {
    NSTimeInterval needToWaitDelay = expectedPresentationTime - nowTime + 0.05;
    DO_AFTER_WAITING(needToWaitDelay, ^{
      [blockSelf presentLoadedPreviewOnscreen];
    });
    return;
  }
  
  UIView *viewToSnapshot = self.isYouTubeVideo ? self.galleryView : self.activeFocusMediaView.imageView;
  UIImage *mediaSnapshot = [viewToSnapshot jm_imageRepresentation];
  UIImage *aspectFilledSnapshot = JMAspectScaleToFillImageToSize(mediaSnapshot, self.contentContainerView.size);
  UIImage *blurredSnapshot = [aspectFilledSnapshot jm_blurUsingAverageColorWithStrength:0.05];
  self.contentContainerView.image = blurredSnapshot;
  
  self.frame = self.attachToView.frame;
  self.alpha = 0.;
  self.shouldShowStatusBarDismiss = !JMIsStatusBarHidden();
  JMAnimateStatusBarHidden(YES);
  [UIView jm_transition:self animations:^{
    blockSelf.alpha = 1.;
    blockSelf.loadingIndicator.alpha = 0.;
  } completion:^{
    [blockSelf.loadingIndicator stopAnimating];
    if (blockSelf.onSuccessfulPresentationAction)
    {
      blockSelf.onSuccessfulPresentationAction();
    }
  }];
}

- (void)scaleGalleryViewToFitContainer;
{
  if (CGSizeEqualToSize(CGSizeZero, self.aspectContentSize))
    return;
  
  CGFloat inset = self.isYouTubeVideo ? 1. : -1.;
  CGSize overdrawSize = CGRectInset(self.contentContainerView.bounds, inset, inset).size;
  CGSize aspectSizeThatFitsBoundary = JMAspectFitImageSize(self.aspectContentSize, overdrawSize, YES);
  if (CGSizeEqualToSize(CGSizeZero, aspectSizeThatFitsBoundary) || isnan(self.aspectContentSize.width))
    return;
  
  if (self.isYouTubeVideo)
  {
    self.galleryView.size = aspectSizeThatFitsBoundary;
    [self.activeFocusMediaView scaleToFitAnimated:NO];
    [self.galleryView centerInSuperView];
  }
  else
  {
    self.galleryView.size = self.contentContainerView.size;
    [self.activeFocusMediaView scaleToFitAnimated:NO];
    [self.galleryView centerInSuperView];
  }
}

- (void)didFinishLoadingMediaWithAspectContentSize:(CGSize)aspectContentSize;
{
  self.mediaDidLoad = YES;
  self.aspectContentSize = aspectContentSize;
  
  self.galleryView.backgroundColor = [UIColor clearColor];
  self.galleryView.pagingView.backgroundColor = [UIColor clearColor];
  self.activeFocusMediaView.backgroundColor = [UIColor clearColor];

//  self.activeFocusMediaView.imageView.layer.borderColor = [UIColor orangeColor].CGColor;
//  self.activeFocusMediaView.imageView.layer.borderWidth = 10.;
//  self.activeFocusMediaView.imageView.backgroundColor = [UIColor purpleColor];
  
  [self scaleGalleryViewToFitContainer];
  
  self.galleryView.pageLabel.hidden = YES;

  BSELF(ABHoverPreviewView);
  JMAction onContentReadyAction = ^{
    CGFloat renderDelay = 0.15;
    DO_AFTER_WAITING(renderDelay, ^{
      [blockSelf presentLoadedPreviewOnscreen];
    });
  };

  if (self.isYouTubeVideo)
  {
    [self.activeFocusMediaView startAutoplayShowingTitleIntro:NO onPlaybackComplete:nil];
    self.activeFocusMediaView.youTubeVideoDidFinishLoadingAction = onContentReadyAction;
  }
  else
  {
    onContentReadyAction();
  }
  
  BOOL showScrubber = self.isAlbum && JMIsIphone();
  if (showScrubber)
  {
    NSString *iconNameForScrubberEndPoint = self.isYouTubeVideo ? @"tiny-speaker-icon" : @"tiny-album-icon";
    UIImage *icon = [UIImage skinIcon:iconNameForScrubberEndPoint withColor:[UIColor grayColor]];
    [self.scrubberView updateIconForEndPoint:icon];
  }
  self.scrubberView.hidden = !showScrubber;
}

- (void)didScrubToPercentage:(CGFloat)scrubPercentage;
{
   if (self.isAlbum)
   {
     NSUInteger maxPageLimit = MIN(5, self.galleryView.pagingView.numberOfPages);
     NSUInteger photoIndexToShow = (scrubPercentage * maxPageLimit);
     photoIndexToShow = JM_LIMIT(0, maxPageLimit - 1, photoIndexToShow);

     if (photoIndexToShow == self.galleryView.pagingView.pageIndex)
       return;
     
     if (photoIndexToShow == (self.galleryView.pagingView.pageIndex + 1))
     {
       [self.galleryView.pagingView goNext];
     }
     else
     {
       BSELF(ABHoverPreviewView);
       [UIView jm_animate:^{
         blockSelf.galleryView.pagingView.alpha = 0.;
       } completion:^{
         [blockSelf.galleryView.pagingView jumpToPageIndex:photoIndexToShow];
         [blockSelf.galleryView.pagingView scrollToCurrent];
         blockSelf.galleryView.pagingView.alpha = 1.;
       }];
     }
   }
}

- (void)updateGalleryItemsWithReducedSizeEquivalents:(NSArray *)galleryItems;
{
  [galleryItems each:^(JMGalleryItem *item) {
    if (item.mediaType == JMGalleryItemMediaTypeImage)
    {
      item.imageUrl = JMAppendReducedSizeImgurSuffixIfNecessary(item.imageUrl);
    }
  }];
}

- (void)prepareMediaView;
{
  BSELF(ABHoverPreviewView);
  
  // place this offscreen while we scale and pre-render
  // the overlay sits behind the media view
  self.galleryView.size = self.contentContainerView.bounds.size;
  self.galleryView.left = self.bounds.size.width;
  
  [self prepareGalleryItemsOnComplete:^(NSArray *preparedGalleryItems) {
    [blockSelf updateGalleryItemsWithReducedSizeEquivalents:preparedGalleryItems];
    [blockSelf.galleryView updateWithGalleryItems:preparedGalleryItems startingIndex:0 onActiveViewDownloadProgress:^(CGFloat progress) {
      [blockSelf loadDidProgress:progress];
    } onActiveViewDownloadComplete:^{
      if (!blockSelf.isCancelling && blockSelf.scrubberView.hidden)
      {
        [blockSelf.activeFocusMediaView determineVisibleContentDimensionsOnComplete:^(CGSize contentSize) {
          if (!blockSelf.isCancelling)
          {
            DO_IN_MAIN(^{
              [blockSelf didFinishLoadingMediaWithAspectContentSize:contentSize];
            });
          }
        }];
      }
    }];
  }];
  
//  self.galleryView.onActiveFocusMediaDidFinishLoad = ^{
//  };
//  
//  self.galleryView.onActiveFocusMediaLoadProgress = ^(CGFloat progress){
//
//  };
  
}

- (void)attachIndicatorToViewAndStartLoading;
{
  if (self.isCancelling)
    return;
  
  self.previewIsActivated = YES;
  
  CGPoint loadingIndicatorCenter = CGPointCenterOfRect(self.presentedFromRect);
  loadingIndicatorCenter.y -= 25.;
  self.loadingIndicator.center = loadingIndicatorCenter;

  [self.attachToView addSubview:self.loadingIndicator];
  [self.loadingIndicator startAnimating];
  
  CGFloat initialProgress = self.isYouTubeVideo ? kABHoverPreviewIndetermineProgress : 0.01;
  [self.loadingIndicator updateWithProgressRatio:initialProgress];
  
  [self i_AttachPreviewToWindowOffscreen];
}

- (BOOL)isAlbum;
{
  return [JMAlbumContentOptimizer canHandleOptimizationForURL:self.previewURL];
}

- (BOOL)isYouTubeVideo;
{
  return [self.previewURL.absoluteString jm_contains:@"youtube.com"] || [self.previewURL.absoluteString jm_contains:@"youtu.be"];
}

- (void)i_AttachPreviewToWindowOffscreen;
{
  [self.attachToView addSubview:self];
  [ABWindow bringDimmingOverlayToFrontIfNecessary];
  
  self.frame = self.attachToView.bounds;

  // place offscreen until everything has loaded
  self.left = self.bounds.size.width;
  self.autoresizingMask = JMFlexibleSizeMask;

  self.contentContainerView.frame = CGRectCropToTop(self.bounds, self.presentedFromRect.origin.y);
  
  [self prepareBlurUnderlayView];

  [self prepareMediaView];
}

- (void)failedToObtainPreview;
{
  DLog(@"failed to create preview for : %@", self.previewURL);
  BSELF(ABHoverPreviewView);
  [self.loadingIndicator updateWithProgressRatio:kABHoverLoadingIndicatorViewProgressRatioForError];
  DO_AFTER_WAITING(1., ^{
    [blockSelf dismissAnimated:NO];
  });
}

- (void)handleUserAdjustingContainerSizeToHeight:(CGFloat)proposedHeight
{
  if (self.contentContainerView.height == proposedHeight)
    return;
  
  if (CGSizeEqualToSize(CGSizeZero, self.initialContainerSize))
  {
    self.initialContainerSize = self.contentContainerView.size;
  }
  
  if (self.alpha != 1.)
  {
    self.alpha = 1.;
  }
  
  proposedHeight = JM_LIMIT(50., MAXFLOAT, proposedHeight);
  
  self.contentContainerView.height = proposedHeight;
  [self scaleGalleryViewToFitContainer];
  self.frostedUnderlayView.top = (proposedHeight - self.initialContainerSize.height) - kABHoverPreviewManualAdjustmentTouchBuffer;
}

- (BOOL)handleTouchEvent:(UIEvent *)touchEvent;
{
  NSString *eventDescription = [touchEvent description];

  BOOL touchDidEnd = [eventDescription jm_contains:@"ended"];
  BOOL touchMoved = [eventDescription jm_contains:@"moved"];
  
  BOOL shouldEndDueToLargeScrollMovement = NO;
  
  if (touchMoved)
  {
    CGPoint touchLocation = [[[touchEvent allTouches] anyObject] locationInView:[UIApplication sharedApplication].keyWindow];
    if (CGPointEqualToPoint(CGPointZero, self.moveStartPoint))
    {
      self.moveStartPoint = touchLocation;
    }
    else
    {
      CGFloat dX = touchLocation.x - self.moveStartPoint.x;
      CGFloat dY = touchLocation.y - self.moveStartPoint.y;
      
      CGPoint loadingIndicatorCenter = CGPointCenterOfRect(self.presentedFromRect);
      CGFloat dragThresholdBeforeTableUnderneathBeginsMoving = 8.;
      loadingIndicatorCenter.y -= 25.;
      CGFloat loadingIndicatorOffset = MAX(0, fabs(dY) - dragThresholdBeforeTableUnderneathBeginsMoving) * JMSign(dY);
      loadingIndicatorCenter.y += loadingIndicatorOffset;
      self.loadingIndicator.center = loadingIndicatorCenter;
      
      if (!self.mediaDidLoad && self.loadingIndicator.superview == nil && fabs(dY) > 5.)
      {
        // assume we mistook the users intent to scroll and dismiss
        [self dismissAnimated:NO];
        return NO;
      }
      
      BOOL draggedUpwardEnoughToDismiss = dY < -1 * kABHoverPreviewDragDistanceToDimiss;
      // avoid incidental movement while finger is resting
      BOOL significantDownwardMovement = dY > kABHoverPreviewManualAdjustmentTouchBuffer;
      BOOL significantHorizontalMovement = dX > kABHoverPreviewManualAdjustmentTouchBuffer;
      
      BOOL movementIsMainlyVertical = fabs(dY/dX) > 2.;
      
      if (movementIsMainlyVertical && !self.shouldSkipStatusBarManipulationOnDismiss)
      {
        self.shouldSkipStatusBarManipulationOnDismiss = YES;
      }
      
      shouldEndDueToLargeScrollMovement = draggedUpwardEnoughToDismiss && movementIsMainlyVertical;
      
      BOOL shouldScrub = significantHorizontalMovement && !self.scrubberView.hidden;
      
      if (!shouldEndDueToLargeScrollMovement && significantDownwardMovement)
      {
        CGFloat proposedContainerHeight = (self.presentedFromRect.origin.y + dY);
        [self handleUserAdjustingContainerSizeToHeight:proposedContainerHeight];
      }
      
      if (!shouldScrub && dY > -1 * kABHoverPreviewDragDistanceToDimiss && dY < 0)
      {
        self.alpha = 1. - JM_RANGE(0., 1., fabs(dY / kABHoverPreviewDragDistanceToDimiss));
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
      }
      
      if (shouldScrub)
      {
        self.alpha = 1.;
        CGFloat scrubberEndIconOffset = 40.;
        CGFloat totalScrubDistance = self.scrubberView.width - scrubberEndIconOffset - CGRectGetMidX(self.presentedFromRect);
        CGFloat scrubRatio = JM_LIMIT(0., 1., dX/totalScrubDistance);
        [self didScrubToPercentage:scrubRatio];
      }
    }
  }
  
  if (touchDidEnd || shouldEndDueToLargeScrollMovement)
  {
    BOOL shouldAnimateDismiss = self.loadingIndicator.superview == nil || self.loadingIndicator.alpha == 0.;
    [self dismissAnimated:shouldAnimateDismiss];
  }

  return NO;
}

- (void)dismissAnimated:(BOOL)animated;
{
  self.isCancelling = YES;
  if (self.previewIsActivated)
  {
    s_lastDismissedTimestamp = CACurrentMediaTime();
  }
  self.onSuccessfulPresentationAction = nil;
  [self cleanUpListeners];
  if (self.shouldShowStatusBarDismiss)
  {
    JMAnimateStatusBarHidden(NO);
  }
  BSELF(ABHoverPreviewView);
  self.layer.shouldRasterize = YES;
  [UIView jm_transition:self animations:^{
    blockSelf.alpha = 0.;
  } completion:^{
    [blockSelf detachFromView];
  } animated:animated];
}

- (void)cleanUpListeners;
{
  ABWindow *window = (ABWindow *)[UIApplication sharedApplication].keyWindow;
  window.customEventHandlerAction = nil;
}

- (void)detachFromView;
{
  [self.loadingIndicator removeFromSuperview];
  self.frostedUnderlayView.image = nil;
  self.arrowClippingView.image = nil;
  self.contentContainerView.image = nil;
  [self removeFromSuperview];
  self.previewIsActivated = NO;
  s_currentHoverPreview = nil;
}

+ (void)showPreviewForURL:(NSURL *)URL fromRect:(CGRect)rect onSuccessfulPresentation:(JMAction)onSuccessfulPresentation;
{
  if (s_currentHoverPreview)
  {
    [s_currentHoverPreview dismissAnimated:NO];
  }
  
  if (![ABHoverPreviewView canShowPreviewForURL:URL])
    return;
  
  ABHoverPreviewView *previewView = [[ABHoverPreviewView alloc] initWithURL:URL presentedFromRect:rect];
  previewView.onSuccessfulPresentationAction = onSuccessfulPresentation;
  [previewView handleUserTouchOfPreviewableItem];
  s_currentHoverPreview = previewView;
}

- (void)attachWindowTouchListener;
{
  BSELF(ABHoverPreviewView);
  ABWindow *window = (ABWindow *)[UIApplication sharedApplication].keyWindow;
  window.customEventHandlerAction = ^(UIEvent *event){
    return [blockSelf handleTouchEvent:event];
  };
}

- (void)handleUserTouchOfPreviewableItem;
{
  self.timeOfTouchStart = CACurrentMediaTime();
  [self attachWindowTouchListener];
  BSELF(ABHoverPreviewView);
  DO_AFTER_WAITING(kABHoverPreviewMinimumSecondsToWaitBeforeAttemptingLoad, ^{
    [blockSelf attachIndicatorToViewAndStartLoading];
  });
}

- (UIView *)attachToView;
{
  return [UIApplication sharedApplication].keyWindow;
}

- (void)willMoveToWindow:(UIWindow *)newWindow;
{
  if (!newWindow)
  {
    [self cleanUpListeners];
  }
  [super willMoveToWindow:newWindow];
}

- (void)willMoveToSuperview:(UIView *)newSuperview;
{
  if (!newSuperview)
  {
    [self cleanUpListeners];
  }
  [super willMoveToSuperview:newSuperview];
}

+ (BOOL)isShowingPreview;
{
  return s_currentHoverPreview != nil && s_currentHoverPreview.previewIsActivated;
}

+ (BOOL)hasRecentlyDismissedPreview;
{
  return (CACurrentMediaTime() - s_lastDismissedTimestamp) < 0.2;
}

+ (void)cancelVisiblePreviewAnimated:(BOOL)animated;
{
  if (!s_currentHoverPreview)
    return;
  
  [s_currentHoverPreview dismissAnimated:animated];
}

@end
