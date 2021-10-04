//
//  GestureTutorialViewController.m
//  AlienBlue
//
//  Created by J M on 5/03/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "GestureTutorialViewController.h"
#import "NavigationManager_iPad.h"
#import "ABNavigationController.h"

@interface GestureTutorialViewController()
@property (strong) NSMutableArray *sheets;
@property (strong) NSArray *sheetImageViews;
@property (strong) UIScrollView *scrollView;
@property (strong) UIPageControl *pageControl;
@end

@implementation GestureTutorialViewController

+ (UIImageView *)imageViewForSheet:(NSString *)sheet;
{
    UIImage *image = [UIImage skinImageNamed:[NSString stringWithFormat:@"tutorial/tutorial-%@", sheet]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView sizeToFit];
    return imageView;
}

- (id)init;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        [self jm_usePreIOS7ScrollBehavior];
        self.sheets = [NSMutableArray array];
        [self.sheets addObject:@"navigation"];
        [self.sheets addObject:@"closing"];
        [self.sheets addObject:@"full-width"];
        [self.sheets addObject:@"switch"];
        [self.sheets addObject:@"drag-load"];
        [self.sheets addObject:@"voting"];
        [self.sheets addObject:@"post-options"];
        [self.sheets addObject:@"collapsing"];
        [self.sheets addObject:@"hiding"];
        [self.sheets addObject:@"scroll-areas"];
      
        [self setNavbarTitle:@"Gestures"];
    }
    return self;
}

- (void)close;
{
    [[NavigationManager_iPad shared] dismissModalView];
}

- (void)loadView;
{
    [super loadView];
    BSELF(GestureTutorialViewController);
    
    self.sheetImageViews = [self.sheets map:^UIImageView *(NSString *sheet) {
        return [GestureTutorialViewController imageViewForSheet:sheet];
    }];
    
    UIImageView *bgImageView = [GestureTutorialViewController imageViewForSheet:@"background"];
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
    
    __block CGFloat xOffset = -10.;
    __block CGFloat yOffset = -5.;
    __block CGFloat imageHeight = 0.;
    [self.sheetImageViews each:^(UIImageView *imageView) {
        [blockSelf.scrollView addSubview:imageView];
        imageView.left = xOffset;
        imageView.top = yOffset;
        imageHeight = imageView.height;
        xOffset += imageView.width;
    }];
    self.scrollView.contentSize = CGSizeMake(xOffset, imageHeight - 10);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;

    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollView.backgroundColor = [UIColor clearColor];
  
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0., self.view.height - 50., self.view.width, 50.)];
    self.pageControl.numberOfPages = self.sheets.count;
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.pageControl.currentPage = 0;
    self.pageControl.defersCurrentPageDisplay = YES;

    [self.view addSubview:self.pageControl];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    NSUInteger page = floor((scrollView.contentOffset.x + 10.) / scrollView.width);
    self.pageControl.currentPage = page;
};

@end
