//
//  NSMutableArray+ABAdditions.m
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NSMutableArray+ABAdditions.h"
#import "NSArray+BlocksKit.h"

@implementation NSMutableArray (ABAdditions)

- (void)addUniqueStringObject:(NSString *)uniqueStr;
{
    NSString *match = [self match:^BOOL(NSString *str) {
        return [str equalsString:uniqueStr];
    }];

    if (!match)
    {
        [self addObject:uniqueStr];
    }
}

- (void)addUniqueStringObjectsFromArray:(NSArray *)array;
{
    BSELF(NSMutableArray);
    [array each:^(NSString *item) {
        [blockSelf addUniqueStringObject:item];
    }];
}

- (void)sortAlphabetically;
{
    [self sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 localizedCaseInsensitiveCompare:obj2];
    }];
}

- (void)sortDescending;
{
    [self sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj2 localizedCaseInsensitiveCompare:obj1];
    }];
}


- (void)reduceToLast:(NSUInteger)amt;
{
    if (self.count <= amt)
        return;
    
    NSUInteger clipTo = self.count - amt - 1;
    [self removeObjectsInRange:NSMakeRange(0, clipTo)];
}

- (void)safeInsertObject:(id)object atIndex:(NSUInteger)ind;
{
    if (ind == NSNotFound || ind >= self.count)
    {
        [self addObject:object];
    }
    else if (ind <= 0)
    {
        [self insertObject:object atIndex:0];
    }
    else 
    {
        [self insertObject:object atIndex:ind];
    }
}


- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
{
    if (to != from) {
        id obj = [self objectAtIndex:from];
        [self removeObjectAtIndex:from];
        if (to >= [self count])
        {
            [self addObject:obj];
        } else 
        {
            [self insertObject:obj atIndex:to];
        }
    }
}

- (void)moveObject:(id)object toIndex:(NSUInteger)toIndex;
{
    NSUInteger fromIndex = [self indexOfObject:object];
    [self moveObjectFromIndex:fromIndex toIndex:toIndex];
}

@end
