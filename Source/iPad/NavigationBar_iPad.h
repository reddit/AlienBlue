//
//  NavigationBar_iPad.h
//  AlienBlue
//
//  Created by J M on 19/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "OverlayViewContainer.h"

#define kNavigationHeaderPadding 15.

@interface NavigationBar_iPad : OverlayViewContainer
@property (readonly, strong) JMViewOverlay *titleOverlay;

@property (strong) NSString *title;
@property (strong) UIView *contentView;
@property BOOL straightEdged;
@property CGFloat shadowTriggerOffset;
- (void)updateWithContentOffset:(CGPoint)offset;
- (void)respondToStyleChangeNotification;
- (UIViewController *)controller;

@end
