//
//  MarkupEngine.h
//  AlienBlue
//
//  Created by JM on 13/11/10.
//  Copyright (c) 2010 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#define kABCoreTextImageID @"kABCoreTextImageID"
#define kABCoreTextImage @"kABCoreTextImage"

@interface MarkupEngine : NSObject

+ (void)refreshCoreTextStyles;
+ (NSMutableAttributedString *)markDownHTML:(NSString *)html forSubreddit:(NSString *)subreddit;
+ (CGFloat)heightOfAttributedString:(CFAttributedStringRef) as constrainedToWidth:(CGFloat) width;
+ (BOOL)doesSupportMarkdown;
+ (NSString *)flattenHTML:(NSString *)html;

@end
