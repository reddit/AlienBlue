//
//  SidePaneBezelButton.h
//  AlienBlue
//
//  Created by J M on 22/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SidePaneBezelButton : UIControl
@property (readonly) NSString *title;
@property BOOL alternatePresentation;
- (void)setPaneTitle:(NSString *)title;
@end
