//
//  NSString+Base64.h
//  AlienBlue
//
//  Created by J M on 29/11/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+Base64.h"

@interface NSString (Base64)
+ (NSString *)base64FromString:(NSString *)plain;
+ (NSString *)decodeBase64String:(NSString *)encoded;
@end
