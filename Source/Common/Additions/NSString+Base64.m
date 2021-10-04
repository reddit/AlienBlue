//
//  NSString+Base64.m
//  AlienBlue
//
//  Created by J M on 29/11/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "NSString+Base64.h"
#import "QSUtilities.h"
#import "NSData+Base64.h"

@implementation NSString (Base64)

+ (NSString *)base64FromString:(NSString *)plain;
{
    NSString *b64 = [QSStrings encodeBase64WithString:plain];
    return b64;
}

+ (NSString *)decodeBase64String:(NSString *)encoded;
{
    NSData *decodedData = [NSData dataWithBase64EncodedString:encoded];
    NSString *decoded = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decoded;
}

@end
