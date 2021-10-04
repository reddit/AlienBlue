//
//  JMViewOverlay+NavigationButton.h
//  AlienBlue
//
//  Created by J M on 17/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMViewOverlay.h"

#define kTitledButtonWidthLimit 140.

@interface JMViewOverlay (NavigationButton)
+ (JMViewOverlay *)buttonWithIcon:(NSString *)iconName highlightColor:(UIColor *)highlightColor;
+ (JMViewOverlay *)buttonWithIcon:(NSString *)iconName title:(NSString *)title;
+ (JMViewOverlay *)buttonWithIcon:(NSString *)iconName title:(NSString *)title titleOffset:(CGFloat)titleOffset;
+ (JMViewOverlay *)buttonWithTitle:(NSString *)title;
+ (JMViewOverlay *)buttonWithIcon:(NSString *)iconName;

+ (JMViewOverlay *)tinyButtonWithIcon:(NSString *)iconName title:(NSString *)title color:(UIColor *)color;
+ (JMViewOverlay *)tinyButtonWithIcon:(NSString *)iconName title:(NSString *)title;
+ (JMViewOverlay *)tinyBoldButtonWithIcon:(NSString *)iconName title:(NSString *)title;
@end
