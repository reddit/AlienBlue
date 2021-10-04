//
//  RedditsHeaderView_iPad.h
//  AlienBlue
//
//  Created by J M on 19/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NavigationBar_iPad.h"

@interface RedditsHeaderView_iPad : NavigationBar_iPad
@property (strong) JMViewOverlay *editOverlay;
@property (strong) JMViewOverlay *doneOverlay;
- (void)switchMode;
@end
