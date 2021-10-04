//
//  BrowserFooterView_iPad.m
//  AlienBlue
//
//  Created by J M on 25/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "BrowserFooterView_iPad.h"
#import "JMViewOverlay+NavigationButton.h"
#import "UIImage+JMOptimalBrowser.h"

@implementation BrowserFooterView_iPad

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    {
        self.straightEdged = YES;
        
        self.backButtonOverlay = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/navbar-back"];
        self.backButtonOverlay.top = 5.;
        self.backButtonOverlay.left = self.width - 134.;
        self.backButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.backButtonOverlay];
        
        self.refreshButtonOverlay = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/navbar-refresh"];
        self.refreshButtonOverlay.top = 5.;
        self.refreshButtonOverlay.left = self.backButtonOverlay.right + 1.;
        self.refreshButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.refreshButtonOverlay];
        
        self.forwardButtonOverlay = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/navbar-forward"];
        self.forwardButtonOverlay.top = 5.;
        self.forwardButtonOverlay.left = self.refreshButtonOverlay.right + 2.;
        self.forwardButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.forwardButtonOverlay];
        
        self.optimalButton = [ABButton buttonWithImageName:@"icons/ipad-navbar/format-standard" onTap:nil];
        self.optimalButton.imageSelected = [UIImage skinImageNamed:@"icons/ipad-navbar/format-optimal"];
        self.optimalButton.top = 6;
        self.optimalButton.left = 10.;
        self.optimalButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.optimalButton];
      
        self.optimalSettingsButton = [[ABButton alloc] initWithIcon:[UIImage optimalBrowserSettingsIcon]];
        self.optimalSettingsButton.top = 10;
        self.optimalSettingsButton.left = self.optimalButton.right;
        self.optimalSettingsButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.optimalSettingsButton.alpha = 0.5;
        [self.contentView addSubview:self.optimalSettingsButton];
    }
    return self;
}

@end
