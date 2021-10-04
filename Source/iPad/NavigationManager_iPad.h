//
//  NavigationManager_iPad.h
//  AlienBlue
//
//  Created by J M on 14/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NavigationManager.h"
#import "PostsNavigation_iPad.h"

@interface NavigationManager_iPad : NavigationManager
- (void)goBack;
- (void)goHome;
+ (PostsNavigation_iPad *)foldingNavigation;
- (void)showPortraitSelectionTip;
- (void)showPostsForSubreddit:(NSString *)sr title:(NSString *)title fromController:(UIViewController *)fromController;
- (void)browseToURLFromMessageForIPAD:(NSString *)url;
- (void)showFullScreenViewerForImageUrls:(NSArray *)imageUrls startingAtIndex:(NSUInteger)atIndex onDismiss:(JMAction)onDismiss;

- (void)dismissPopoverIfNecessary;
- (void)showPopoverWithContentViewController:(UIViewController *)contentViewController inView:(UIView *)viewToPresentIn fromRect:(CGRect)fromRect permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections;

@end
