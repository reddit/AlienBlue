//
//  UIFont+Skin.m
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "UIFont+Skin.h"

@implementation UIFont (Skin)

+ (UIFont *)skinFontWithName:(NSString *)name;
{
    return [[ABBundleManager sharedManager] fontForKey:name];
}

+ (CTFontRef)skinFontRefWithName:(NSString *)name;
{
    return [[ABBundleManager sharedManager] fontRefForKey:name];
}

@end
