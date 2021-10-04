//
//  NSString+HTML.m
//  AlienBlue
//
//  Created by JM on 20/11/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "NSString+HTML.h"
#import "GTMNSString+HTML.h"

@implementation NSString (HTML)

- (NSString *)stringByDecodingHTMLEntities {
	return [NSString stringWithString:[self gtm_stringByUnescapingFromHTML]]; // gtm_stringByUnescapingFromHTML can return self so create new string ;)
}

@end
