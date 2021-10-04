//
//  FullScreenPhotoViewer_iPad.m
//  AlienBlue
//
//  Created by J M on 26/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "FullScreenPhotoViewer_iPad.h"
#import "NavigationManager_iPad.h"
#import <QuartzCore/QuartzCore.h>

@interface FullScreenPhotoViewer_iPad()
@property (strong) UIImage *image;
@property (strong) UIImageView *imageView;
@property (strong) UIScrollView *scrollView;
- (void)exitFullscreen;
@end

@implementation FullScreenPhotoViewer_iPad

- (id)initWithImage:(UIImage *)image;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.image = image;
    }
    return self;
}

- (void)loadView;
{
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithWhite:0. alpha:0.8];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];

    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    [self.scrollView addSubview:self.imageView];
	self.scrollView.contentSize = self.imageView.frame.size;

	CGFloat newZoomScale = (self.view.bounds.size.width * self.scrollView.zoomScale) / self.imageView.frame.size.width;
	[self.scrollView setMinimumZoomScale:newZoomScale];
	[self.scrollView setMaximumZoomScale:newZoomScale * 2.];
    CGFloat defaultScale = JMLandscape() ? 0.37 : 0.;
    CGFloat zoomScale = JM_RANGE(self.scrollView.minimumZoomScale, self.scrollView.maximumZoomScale, defaultScale);
    [self.scrollView setZoomScale:zoomScale];
	[self.scrollView setContentOffset:CGPointZero];
    
    BSELF(FullScreenPhotoViewer_iPad);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UIGestureRecognizer *gesture){
        if (gesture.state == UIGestureRecognizerStateRecognized)
        {
            [blockSelf exitFullscreen];
        }
    }];
    tapGesture.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
{
	return self.imageView;
}

- (void)exitFullscreen;
{
//    self.scrollView.scrollEnabled = NO;
    [self.scrollView.gestureRecognizers each:^(UIGestureRecognizer *gestureRecognizer) {
        gestureRecognizer.enabled = NO;
    }];
//    [self.scrollView.layer removeAllAnimations];
//    [self.view.layer removeAllAnimations];
//    [self.imageView.layer removeAllAnimations];
    [[NavigationManager shared] dismissModalView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	if (scrollView.zoomScale < (scrollView.minimumZoomScale * 0.67))
	{
        [self exitFullscreen];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return YES;
}

@end
