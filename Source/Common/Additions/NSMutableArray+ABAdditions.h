//
//  NSMutableArray+ABAdditions.h
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (ABAdditions)

- (void)addUniqueStringObject:(NSString *)uniqueStr;
- (void)addUniqueStringObjectsFromArray:(NSArray *)array;
- (void)sortAlphabetically;
- (void)sortDescending;
- (void)reduceToLast:(NSUInteger)amt;
- (void)safeInsertObject:(id)object atIndex:(NSUInteger)ind;

- (void)moveObject:(id)object toIndex:(NSUInteger)toIndex;
- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)toIndex;

@end
