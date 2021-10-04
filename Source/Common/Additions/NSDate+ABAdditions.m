//
//  NSDate+ABAdditions.m
//  AlienBlue
//
//  Created by J M on 19/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NSDate+ABAdditions.h"

@implementation NSDate (ABAdditions)

- (BOOL)isEarlierThanDate:(NSDate *)date;
{
    return [self compare:date] == NSOrderedAscending;
}

- (BOOL)isLaterThanDate:(NSDate *)date;
{
    return [self compare:date] == NSOrderedDescending;    
}

- (BOOL)isSameAsDate:(NSDate *)date;
{
    return [self compare:date] == NSOrderedSame;    
}

+ (NSDate *)latestOfDate:(NSDate *)date1 date:(NSDate *)date2;
{
    if ([date1 isLaterThanDate:date2])
        return date1;
    else
        return date2;
}

@end
