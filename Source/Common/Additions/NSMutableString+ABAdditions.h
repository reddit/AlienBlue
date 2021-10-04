//
//  NSMutableString+ABAdditions.h
//  AlienBlue
//
//  Created by J M on 7/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (ABAdditions)

- (void)replaceString:(NSString *)sStr withString:(NSString *)rStr;
- (void)removeOccurrencesOfString:(NSString *)str;
@end
