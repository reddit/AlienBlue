//
//  PostsViewController+CanvasSupport.h
//  AlienBlue
//
//  Created by J M on 12/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController.h"

@interface PostsViewController (CanvasSupport)
@property BOOL shouldLaunchCanvasWithViewHidden;
@property (readonly) BOOL isCanvasShowing;

- (void)removeCanvas;
- (void)notifyCanvasViewDidRotate:(UIInterfaceOrientation)fromInterfaceOrientation;
- (void)notifyCanvasViewWillAppearAnimated:(BOOL)animated;
- (void)notifyCanvasViewWillDisappearAnimated:(BOOL)animated;
- (void)notifyCanvasViewDidUnload;
- (void)showCanvas;
@end
