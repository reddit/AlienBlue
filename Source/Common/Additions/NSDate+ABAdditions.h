//
//  NSDate+ABAdditions.h
//  AlienBlue
//
//  Created by J M on 19/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ABAdditions)
- (BOOL)isEarlierThanDate:(NSDate *)date;
- (BOOL)isLaterThanDate:(NSDate *)date;
- (BOOL)isSameAsDate:(NSDate *)date;
+ (NSDate *)latestOfDate:(NSDate *)date1 date:(NSDate *)date2;
@end
