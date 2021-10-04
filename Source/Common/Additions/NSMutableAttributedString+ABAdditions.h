//
//  NSMutableAttributedString+ABAdditions.h
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (ABAdditions)

- (void)applyAttribute:(NSString *)attributeName value:(id)value toString:(NSString *)string;
- (void)applyAttribute:(NSString *)attributeName value:(id)value;

@end
