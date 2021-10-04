//
//  NSArray+ABAdditions.m
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NSArray+BlocksKit.h"
#import "NSArray+ABAdditions.h"

@implementation NSArray (ABAdditions)

- (NSArray *)limitToLength:(NSUInteger)len;
{
    if ([self count] > len)
    {
        return [self subarrayWithRange:NSMakeRange(0, len)];
    }
    else
    {
        return self;
    }
}

- (BOOL)matchesStringContentsInArray:(NSArray *)array;
{
    if (!array || array.count != self.count)
        return NO;

    __block BOOL same = YES;
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSString *obj2 = [array objectAtIndex:idx];
        if (![obj2 equalsString:obj])
        {
            same = NO;
            *stop = YES;
        }
    }];
    
    return same;
}

- (id)safeObjectAtIndex:(NSUInteger)ind;
{
    if (ind >= [self count])
        return nil;

    return [self objectAtIndex:ind];
}

@end
