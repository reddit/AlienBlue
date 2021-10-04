//
//  NSMutableAttributedString+ABAdditions.m
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "NSMutableAttributedString+ABAdditions.h"

@implementation NSMutableAttributedString (ABAdditions)

- (void)applyAttribute:(NSString *)attributeName value:(id)value toString:(NSString *)string
{
    NSRange range = [self.string rangeOfString:string];
    [self addAttribute:attributeName value:value range:range];
}

- (void)applyAttribute:(NSString *)attributeName value:(id)value;
{
    NSRange range = NSMakeRange(0, self.length);
    [self addAttribute:attributeName value:value range:range];
}

@end
