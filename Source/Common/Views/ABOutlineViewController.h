//
//  ABOutlineViewController.h
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMOutlineViewController.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "ABCustomOutlineNavigationBar.h"

@interface ABOutlineViewController : JMOutlineViewController

@property (readonly) ABCustomOutlineNavigationBar *navigationBar;
@property (readonly) NSString *customScreenNameForAnalytics;

- (void)respondToStyleChange;

@end
