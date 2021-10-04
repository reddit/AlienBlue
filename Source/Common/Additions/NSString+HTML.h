//
//  NSString+HTML.h
//  AlienBlue
//
//  Created by JM on 20/11/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSString (HTML)
- (NSString *)stringByDecodingHTMLEntities;
@end
