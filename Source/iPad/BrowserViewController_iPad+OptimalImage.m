#import "BrowserViewController_iPad+OptimalImage.h"
#import "JMImageContentOptimizer.h"
#import "JMGalleryFocusMediaView.h"
#import "NavigationManager_iPad.h"

@interface BrowserViewController_iPad (OptimalImage_) <UIGestureRecognizerDelegate>
@property (readonly) JMGalleryFocusMediaView *focusMediaView;
@end

@implementation BrowserViewController_iPad (OptimalImage)

- (void)configureContentViewForImageIfNecessary;
{
  if (self.isShowingOptimal && JMIsClass(self.optimizer, JMImageContentOptimizer))
  {
    self.contentView.frame = CGRectInset(self.contentView.frame, 30., 30.);
    [self applyImageGestureRecognizers];
  }
}

- (JMGalleryFocusMediaView *)focusMediaView;
{
  JMGalleryFocusMediaView *mediaView = (JMGalleryFocusMediaView *)[self.optimizer.view jm_firstSubviewOfClass:[JMGalleryFocusMediaView class]];
  return mediaView;
}

- (void)applyImageGestureRecognizers;
{
  [self.optimizer.view jm_removeGestureRecognizers];
  [self.optimizer.view jm_removeGestureRecognizersInSubviews];
  
  self.focusMediaView.imageView.layer.borderWidth = 4.;
  self.focusMediaView.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage:)];
  tapGesture.delaysTouchesEnded = NO;
  tapGesture.delaysTouchesBegan = NO;
  [self.optimizer.view addGestureRecognizer:tapGesture];
  
  UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchImage:)];
  pinchGesture.delegate = self;
  [self.optimizer.view addGestureRecognizer:pinchGesture];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
{
  UIPinchGestureRecognizer *pinchGesture = JMCastOrNil(gestureRecognizer, UIPinchGestureRecognizer);
  if (pinchGesture && pinchGesture.scale < 1)
    return NO;
  
  return YES;
}


- (void)showOptimisedImageInFullscreen;
{
  JMImageContentOptimizer *imageOptimizer = JMCastOrNil(self.optimizer, JMImageContentOptimizer);
  if (imageOptimizer && imageOptimizer.deeplinkedImageURL)
  {
    UIImage *preFullscreenImage = self.focusMediaView.imageView.image;
    self.focusMediaView.imageView.image = nil;
    BSELF(BrowserViewController_iPad);
    [(NavigationManager_iPad *)[NavigationManager_iPad shared] showFullScreenViewerForImageUrls:@[imageOptimizer.deeplinkedImageURL.absoluteString] startingAtIndex:0 onDismiss:^{
      blockSelf.focusMediaView.imageView.image = preFullscreenImage;
    }];
  }
}

- (void)didTapImage:(UITapGestureRecognizer *)gesture;
{
  if (gesture.state != UIGestureRecognizerStateEnded)
    return;
  
  [self showOptimisedImageInFullscreen];
}

- (void)didPinchImage:(UIPinchGestureRecognizer *)gesture;
{
  if (gesture.state != UIGestureRecognizerStateChanged)
    return;
  
  // ignore inward pinch
  if (gesture.scale <= 1.)
  {
    return;
  }
  
  [self showOptimisedImageInFullscreen];
}

@end
