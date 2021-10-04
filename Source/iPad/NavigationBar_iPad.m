//
//  NavigationBar_iPad.m
//  AlienBlue
//
//  Created by J M on 19/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NavigationBar_iPad.h"
#import "AppDelegate_iPad.h"
#import "JMFNContainerView.h"
#import "UIViewController+JMFoldingNavigation.h"

#import "SettingsViewController.h"
#import "NavigationManager_iPad.h"

@interface NavigationBar_iPad()
@property (strong) JMViewOverlay *titleOverlay;
@property (strong) JMViewOverlay *dividerOverlay;
@property (strong) JMViewOverlay *shadowOverlay;
@property (strong) JMViewOverlay *roundedEdgeOverlay;
@property CGFloat shadowOpacity;
- (void)respondToDoubleTap:(UITapGestureRecognizer *)gesture;
@end

@implementation NavigationBar_iPad

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.contentView = [[OverlayViewContainer alloc] initWithFrame:CGRectMake(0., 0., self.width, self.height - 5.)];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor = [UIColor colorForBackground];
        [self addSubview:self.contentView];
        
        self.contentView.forceOverlayRedrawOnTouchAndRelease = YES;
        
        BSELF(NavigationBar_iPad);
        
        self.shadowOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., self.height - 5., self.width , 5.)  drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
            UIColor *gradientColor = [UIColor colorWithWhite:0. alpha:blockSelf.shadowOpacity];
            [UIView drawGradientInRect:bounds minHeight:5. startColor:gradientColor endColor:[UIColor clearColor]];
        }];
        [self addOverlay:self.shadowOverlay];
        
        self.titleOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(kNavigationHeaderPadding, kNavigationHeaderPadding, 200., 50.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
            UIFont *titleFont = [UIFont skinFontWithName:kBundleFontNavigationTitle_iPad];
            [[UIColor colorWithHex:0x999999] set];
            [blockSelf.title drawInRect:CGRectMake(0., 0., bounds.size.width, 25.) withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation];
        }];
        [self.contentView addOverlay:self.titleOverlay];

        self.dividerOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(kNavigationHeaderPadding, self.height - 7., self.width - 2 * kNavigationHeaderPadding, 1.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
            if (blockSelf.shadowOpacity < 0.15)
            {
                [UIView startEtchedDraw];
                [[UIColor colorForDivider] set];
                [[UIBezierPath bezierPathWithRect:bounds] fill];
                [UIView endEtchedDraw];
            }
        }]; 
        self.dividerOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addOverlay:self.dividerOverlay];

        self.roundedEdgeOverlay = [JMViewOverlay overlayWithFrame:self.contentView.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
            if (!blockSelf.straightEdged)
            {
              [[UIColor tiledPatternForBackground] set];
              
              UIBezierPath *leftCornerPath = JMNavbarLeftCornerEdgeBezierPath(CGRectMake(0., 0., 4., 4.));
              [leftCornerPath fill];
              
              UIBezierPath *rightCornerPath = JMNavbarRightCornerEdgeBezierPath(CGRectMake(bounds.size.width - 4., 0., 4., 4.));
              [rightCornerPath fill];
              
              // draw faux shadow over the background
              [kJMFNContainerDividerShadowColor set];
              [leftCornerPath fill];
              [rightCornerPath fill];
            }
        }];
        self.roundedEdgeOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addOverlay:self.roundedEdgeOverlay];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToStyleChangeNotification) name:kNightModeSwitchNotification object:nil];
      
        UITapGestureRecognizer *tripleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTripleTap:)];
        tripleTapGesture.numberOfTapsRequired = 3;
        tripleTapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tripleTapGesture];
      
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToDoubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        [doubleTapGesture requireGestureRecognizerToFail:tripleTapGesture];
        [self addGestureRecognizer:doubleTapGesture];
      
        UISwipeGestureRecognizer *twoFingerSwipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTwoFingerSwipeUp:)];
        twoFingerSwipeUpGesture.numberOfTouchesRequired = 2;
        twoFingerSwipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:twoFingerSwipeUpGesture];

        UISwipeGestureRecognizer *twoFingerSwipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTwoFingerSwipeDown:)];
        twoFingerSwipeDownGesture.numberOfTouchesRequired = 2;
        twoFingerSwipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:twoFingerSwipeDownGesture];
    }
    return self;
}

UIBezierPath *JMNavbarLeftCornerEdgeBezierPath(CGRect frame)
{
  UIBezierPath* path = [UIBezierPath bezierPath];
  [path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00000 * CGRectGetHeight(frame))];
  [path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 1.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.00151 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00091 * CGRectGetHeight(frame))];
  [path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00000 * CGRectGetHeight(frame))];
  [path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00000 * CGRectGetHeight(frame))];
  [path closePath];
  return path;
}

UIBezierPath *JMNavbarRightCornerEdgeBezierPath(CGRect frame)
{
  UIBezierPath* path = [UIBezierPath bezierPath];
  [path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 1.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00000 * CGRectGetHeight(frame))];
  [path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 1.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99849 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00091 * CGRectGetHeight(frame))];
  [path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 1.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.00000 * CGRectGetHeight(frame))];
  [path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 1.00000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 1.00000 * CGRectGetHeight(frame))];
  [path closePath];
  return path;
}

- (void)updateWithContentOffset:(CGPoint)offset;
{
    CGFloat maxOffset = MIN(fabs(offset.y - self.shadowTriggerOffset), 100.);
    CGFloat newOpacity = JM_RANGE(0., 0.15, (maxOffset / 50.));
    
    if (self.shadowOpacity != newOpacity)
    {
        self.shadowOpacity = newOpacity;
        [self.shadowOverlay setNeedsDisplay];
        [self.dividerOverlay setNeedsDisplay];
    }
}

- (void)respondToStyleChangeNotification;
{
    [self setNeedsDisplay];
    [self.contentView setNeedsDisplay];
    self.contentView.backgroundColor = [UIColor colorForBackground];
}

- (UIViewController *)controller;
{
    // hacky, but keeps the view controllers tidier
    JMFNContainerView *containerView = (JMFNContainerView *)[self firstParentOfClass:[JMFNContainerView class]];
    if (containerView)
    {
        UIViewController *controller = containerView.controller;
        if (controller && [controller isKindOfClass:[UIViewController class]])
        {
            return controller;
        }
    }
    return nil;
}

- (void)respondToDoubleTap:(UITapGestureRecognizer *)gesture;
{
    UIViewController *controller = self.controller;
    [controller toggleFullscreen];
}

- (void)respondToTripleTap:(UITapGestureRecognizer *)gesture;
{
  UIView *viewToAnimate = [NavigationManager_iPad foldingNavigation].wrapperView;
  [UIView jm_transition:viewToAnimate animations:^{
    [SettingsViewController toggleNightTheme];
  } completion:^{
    [UIView jm_transition:viewToAnimate animations:^{
      [[NavigationManager_iPad foldingNavigation] viewWillDisappear:NO];
      [[NavigationManager_iPad foldingNavigation] viewDidDisappear:NO];
      [[NavigationManager_iPad foldingNavigation] viewWillAppear:YES];
      [[NavigationManager_iPad foldingNavigation] viewDidAppear:YES];
    } completion:nil animated:YES];
  } animated:YES];
}

- (void)respondToTwoFingerSwipeUp:(UISwipeGestureRecognizer *)gesture;
{
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
  [[NavigationManager_iPad foldingNavigation] statusBarDidChangeVisibility];
}


- (void)respondToTwoFingerSwipeDown:(UISwipeGestureRecognizer *)gesture;
{
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
  [[NavigationManager_iPad foldingNavigation] statusBarDidChangeVisibility];
}

@end
