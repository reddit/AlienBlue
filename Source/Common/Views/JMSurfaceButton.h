//
//  JMSurfaceButton.h
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIControl+Blocks.h"

typedef enum {
    JMSurfaceLevelInset = 0,
    JMSurfaceLevelOffset = 1
} JMSurfaceLevel;

@interface JMSurfaceButton : UIControl

- (id)initWithFrame:(CGRect)frame skinImageNamed:(NSString *)imageName imageColor:(UIColor *)color surfaceLevel:(JMSurfaceLevel)surfaceLevel;

@end
