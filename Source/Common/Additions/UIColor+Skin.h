//
//  UIColor+Skin.h
//  AlienBlue
//
//  Created by J M on 15/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Skin)

+ (UIColor *)colorForText;
+ (UIColor *)colorForHighlightedText;
+ (UIColor *)colorForTint;

+ (UIColor *)colorForBackground;
+ (UIColor *)colorForBackgroundAlt;

+ (UIColor *)colorForInsetInnerShadow;
+ (UIColor *)colorForInsetDropShadow;

+ (UIColor *)colorForBevelInnerShadow;
+ (UIColor *)colorForBevelDropShadow;

+ (UIColor *)colorForPullToRefreshForeground;

+ (UIColor *)colorForUpvote;
+ (UIColor *)colorForDownvote;

+ (UIColor *)colorForHighlightedOptions;

+ (UIColor *)colorForSoftDivider;
+ (UIColor *)colorForDivider;
+ (UIColor *)colorForDottedDivider;

+ (UIColor *)colorForPaneBorder;
+ (UIColor *)tiledPatternForBackground;

+ (UIColor *)colorForAccessoryButtons;

+ (UIColor *)colorForToolbarRibbon;
+ (UIColor *)colorForBarButtonItem;
+ (UIColor *)colorForBarButtonItemShadow;

+ (UIColor *)colorForNavigationBar;
+ (UIColor *)colorForToolbar;

+ (UIColor *)colorForOpHighlight;

+ (UIColor *)tintColorWithAlpha:(CGFloat)alpha;
+ (UIColor *)tintColorWithWhite:(CGFloat)white;
+ (UIColor *)colorForRowHighlight;
+ (UIColor *)colorForSectionTitle;

+ (UIColor *)colorForInboxAlert;
+ (UIColor *)colorForModeratorMailAlert;

@end

