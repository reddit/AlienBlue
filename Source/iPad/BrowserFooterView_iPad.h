//
//  BrowserFooterView_iPad.h
//  AlienBlue
//
//  Created by J M on 25/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NavigationBar_iPad.h"
#import "ABButton.h"

@interface BrowserFooterView_iPad : NavigationBar_iPad
@property (strong) JMViewOverlay *backButtonOverlay;
@property (strong) JMViewOverlay *refreshButtonOverlay;
@property (strong) JMViewOverlay *forwardButtonOverlay;
@property (strong) ABButton *optimalButton;
@property (strong) ABButton *optimalSettingsButton;
@end
