//
//  NSMutableString+ABAdditions.m
//  AlienBlue
//
//  Created by J M on 7/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "NSMutableString+ABAdditions.h"

@implementation NSMutableString (ABAdditions)

- (void)replaceString:(NSString *)sStr withString:(NSString *)rStr;
{
    if (!sStr)
        return;
    
    if (!rStr)
        return;
    
    [self replaceOccurrencesOfString:sStr withString:rStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.length)];
}

- (void)removeOccurrencesOfString:(NSString *)str
{
    [self replaceString:str withString:@""];
}

@end
