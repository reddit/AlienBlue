//
//  SidePane_iPad.h
//  AlienBlue
//
//  Created by J M on 21/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABButton.h"

#define kSidePaneNeedsRefreshNotification @"kSidePaneNeedsRefreshNotification"
#define kSidePaneWidth 52

@interface SidePane_iPad : UIView
@property (strong,readonly) ABButton *tipButton;
- (void)setPaneTitle:(NSString *)paneTitle;
+ (BOOL)shouldDisplayAnnouncementBanner;
@end
