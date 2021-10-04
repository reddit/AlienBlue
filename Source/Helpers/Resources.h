//
//  Resources.h
//  Alien Blue :: http://alienblue.org
//
//  Created by Jason Morrissey on 5/05/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RedditAPI.h"

typedef enum tagSkinTheme
{
	SkinThemeClassic = 0,
	SkinThemeLion = 1,
	SkinThemeFire = 2,
	SkinThemeBlossom = 3,
	SkinThemeLionAlt = 4
} SkinTheme;

@interface Resources : NSObject

+ (BOOL)isIPAD;

+ (NSUInteger)maxThreadLevel;

+ (BOOL)showCommentVotingIcons;
+ (BOOL)showPostVotingIcons;
+ (BOOL)shouldShowPostThumbnails;
+ (BOOL)shouldAutoHideStatusBarWhenScrolling;

+ (BOOL)isNight;
+ (SkinTheme)skinTheme;

+ (CGSize)thumbSize;
+ (BOOL)showRetinaThumbnails;

+ (BOOL)compact;
+ (BOOL)compactPortrait;

// required for App Store guideline: 16.1, 18.2
+ (BOOL)safeFilter;
+ (BOOL)isPro;
+ (BOOL)useActionMenu;

@end
