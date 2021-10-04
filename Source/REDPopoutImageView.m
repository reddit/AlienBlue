//  REDPopoutImageView.m
//  RedditApp

#import "RedditApp/REDPopoutImageView.h"

#import <JTSImageViewController.h>

@interface REDPopoutImageView ()<JTSImageViewControllerOptionsDelegate>
@end

@implementation REDPopoutImageView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                           action:@selector(userTappedImage)]];
    self.userInteractionEnabled = YES;
  }
  return self;
}

#pragma mark - JTSImageViewControllerOptionsDelegate

- (CGFloat)alphaForBackgroundDimmingOverlayInImageViewer:(JTSImageViewController *)imageViewer {
  return 1.0;
}

#pragma mark - private

- (void)userTappedImage {
  if (self.viewController) {
    JTSImageInfo *info = [[JTSImageInfo alloc] init];
    info.image = self.image;
    info.referenceView = self;
    info.referenceRect = self.bounds;
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
        initWithImageInfo:info
                     mode:JTSImageViewControllerMode_Image
          backgroundStyle:JTSImageViewControllerBackgroundOption_None];
    imageViewer.optionsDelegate = self;
    [imageViewer showFromViewController:self.viewController
                             transition:JTSImageViewControllerTransition_FromOriginalPosition];
  }
}

@end
