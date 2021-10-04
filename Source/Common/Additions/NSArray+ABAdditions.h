//
//  NSArray+ABAdditions.h
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ABAdditions)

- (NSArray *)limitToLength:(NSUInteger)len;

- (BOOL)matchesStringContentsInArray:(NSArray *)array;

- (id)safeObjectAtIndex:(NSUInteger)ind;

@end
