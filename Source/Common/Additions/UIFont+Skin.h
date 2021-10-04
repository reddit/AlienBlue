//
//  UIFont+Skin.h
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABBundleManager.h"

@interface UIFont (Skin)

+ (UIFont *)skinFontWithName:(NSString *)name;
+ (CTFontRef)skinFontRefWithName:(NSString *)name;

@end
