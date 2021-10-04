//
//  UIColor+Skin.m
//  AlienBlue
//
//  Created by J M on 15/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "UIColor+Skin.h"
#import "Resources.h"

@implementation UIColor (Skin)

+ (UIColor *)colorForText;
{
  long hex = [Resources isNight] ? 0xeeeeee : 0x050505;
  return [UIColor colorWithHex:hex];
}

+ (UIColor *)colorForHighlightedOptions;
{    
  if ([Resources isNight])
    return [UIColor colorWithHex:0x009ed9];
  else if ([Resources skinTheme] == SkinThemeClassic)
    return [UIColor colorWithHex:0x2DA1D0];
  else if ([Resources skinTheme] == SkinThemeLion)
    return [UIColor colorWithHex:0xa23737];
  else if ([Resources skinTheme] == SkinThemeFire)
    return [UIColor colorWithHex:0xae0000];
  else if ([Resources skinTheme] == SkinThemeBlossom)
    return [UIColor colorWithHex:0xc2778e];
  else
    return [UIColor colorWithHex:0x6b86a3]; // SkinThemeClassic
}

+ (UIColor *)colorForToolbar;
{
  return [UIColor colorForNavigationBar];
}

+ (UIColor *)colorForNavigationBar;
{
  return [UIColor colorForBackground];
//  if ([Resources isNight])
//    return [UIColor colorWithHex:0x1f1f1f];
//  else
//    return [UIColor colorWithHex:0xE3E4E5];
}

+ (UIColor *)colorForToolbarRibbon;
{
  if ([Resources isNight])
    return [UIColor colorWithHex:0x222222];
  else if ([Resources skinTheme] == SkinThemeClassic)
    return [UIColor colorWithHex:0x566d8b];
  else if ([Resources skinTheme] == SkinThemeLion)
    return [UIColor colorWithHex:0x9e9e9e];
  else if ([Resources skinTheme] == SkinThemeFire)
    return [UIColor colorWithHex:0x7e0000];
  else if ([Resources skinTheme] == SkinThemeBlossom)
    return [UIColor colorWithHex:0xa2576e];

  return nil;
}

+ (UIColor *)colorForHighlightedText;
{
  return [[UIColor colorForTint] jm_darkenedWithStrength:0.1];
}

+ (UIColor *)colorForTint;
{
  if ([Resources isNight])
    return JMHexColor(1A9CD1);

  if ([Resources skinTheme] == SkinThemeLion || [Resources skinTheme] == SkinThemeLionAlt)
    return JMHexColor(a23737);
  else if ([Resources skinTheme] == SkinThemeFire)
    return JMHexColor(930000);
  else if ([Resources skinTheme] == SkinThemeBlossom)
    return JMHexColor(b93960);
  else
    return JMHexColor(0D7EAC);
}

+ (UIColor *)colorForBackground;
{
  long hex;
  if ([Resources isIPAD])
    hex = [Resources isNight] ? 0x191919 : 0xf2f2f2;
  else
    hex = [Resources isNight] ? 0x1c1c1c : 0xf6f7f8;
  return [UIColor colorWithHex:hex];
}

+ (UIColor *)colorForBackgroundAlt;
{
  long hex;
  if ([Resources isIPAD])
    hex = [Resources isNight] ? 0x181818 : 0xf0f0f0;
  else
    hex = [Resources isNight] ? 0x181818 : 0xf5f6f7;

  return [UIColor colorWithHex:hex];
}

+ (UIColor *)colorForInsetInnerShadow;
{
  if ([Resources isNight])
    return nil;
  else
    return [UIColor colorWithWhite:0. alpha:0.5];
}

+ (UIColor *)colorForInsetDropShadow;
{
  long hex = [Resources isNight] ? 0x000000 : 0xf3f3f3;
  return [UIColor colorWithHex:hex];
}

+ (UIColor *)colorForBevelInnerShadow;
{
  if ([Resources isNight])
    return [UIColor colorWithWhite:1. alpha:0.05];
  else    
    return [UIColor colorWithWhite:1. alpha:0.1];
}

+ (UIColor *)colorForBevelDropShadow;
{
  return [UIColor colorWithWhite:0. alpha:0.1];
}

+ (UIColor *)colorForPullToRefreshForeground;
{
  return [UIColor colorWithHex:0xbcbcbc];
}

+ (UIColor *)colorForUpvote;
{
  return [UIColor colorWithHex:0xff4500];
}

+ (UIColor *)colorForDownvote;
{
  return [UIColor colorWithHex:0x659bfd];
}

+ (UIColor *)colorForSoftDivider;
{
  return [UIColor colorWithWhite:0.5 alpha:0.05];
}

+ (UIColor *)colorForDivider;
{
  return JMThemeColorA(A5A5A5, 0.15, 666666, 0.15);
}

+ (UIColor *)colorForDottedDivider;
{
  return JMThemeColor(ACACAC, 3C3C3C);
}

+ (UIColor *)colorForPaneBorder;
{
  return [Resources isNight] ? [UIColor colorWithHex:0x121212] : [UIColor colorWithHex:0xdad8d7];
}

+ (UIColor *)tiledPatternForBackground;
{
  UIImage *tileImage = nil;
  if ([Resources isNight])
    tileImage = [UIImage skinImageNamed:@"backgrounds/tiles/bg-night"];
  else if ([Resources skinTheme] == SkinThemeLion)
  {
    if ([UDefaults boolForKey:kABSettingKeyIpadLionThemeShowsLinen])
        return [UIColor underPageBackgroundColor];
    else
        tileImage = [UIImage skinImageNamed:@"backgrounds/tiles/bg-lion.jpg"];
  }
  else if ([Resources skinTheme] == SkinThemeBlossom)
    tileImage = [UIImage skinImageNamed:@"backgrounds/tiles/bg-blossom"];
  else if ([Resources skinTheme] == SkinThemeFire)
    tileImage = [UIImage skinImageNamed:@"backgrounds/tiles/bg-fire"];
  else
    tileImage = [UIImage skinImageNamed:@"backgrounds/tiles/bg-classic"];
  
  return [UIColor colorWithPatternImage:tileImage];
}

+ (UIColor *)colorForAccessoryButtons;
{
  return [Resources isNight] ? [UIColor colorWithWhite:0.3 alpha:1.] : [UIColor colorWithWhite:0.65 alpha:1.];
}

+ (UIColor *)colorForBarButtonItem;
{
  if ([Resources isNight])
    return [UIColor colorWithWhite:0.8 alpha:1.];
  
  if ([Resources skinTheme] == SkinThemeLion || [Resources skinTheme] == SkinThemeLionAlt)
    return [UIColor colorWithWhite:0.35 alpha:1.];
  
  return [UIColor colorForTint];
}

+ (UIColor *)colorForBarButtonItemShadow;
{
  return [Resources isNight] ? [UIColor blackColor] : [UIColor whiteColor];
}

+ (UIColor *)colorForOpHighlight;
{
  return JMHexColor(d40cbf);
}

+ (UIColor *)tintColorWithAlpha:(CGFloat)alpha;
{
  CGColorRef colorCopy = CGColorCreateCopyWithAlpha([UIColor colorForTint].CGColor, alpha);
  UIColor * fadedColor = [UIColor colorWithCGColor:colorCopy];
  CGColorRelease(colorCopy);
  return fadedColor;
}

+ (UIColor *)tintColorWithWhite:(CGFloat)white;
{
  const CGFloat* components = CGColorGetComponents([UIColor colorForTint].CGColor);
  CGFloat nComponents[4];
  nComponents[0] = components[0] * white;
  nComponents[1] = components[1] * white;
  nComponents[2] = components[2] * white;
  nComponents[3] = components[3];
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGColorRef nColorRef = CGColorCreate(colorSpace,nComponents);
  UIColor *nColor = [UIColor colorWithCGColor:nColorRef];
  CGColorSpaceRelease(colorSpace);
  CGColorRelease(nColorRef);
  return nColor;
}

+ (UIColor *)colorForRowHighlight;
{
  return [UIColor colorForBackgroundAlt];
}

+ (UIColor *)colorForSectionTitle;
{
  return [Resources isNight] ? [UIColor colorWithHex:0xFFFFFF] : [UIColor colorForText];
}

+ (UIColor *)colorForInboxAlert;
{
  return JMHexColor(ff4808);
}

+ (UIColor *)colorForModeratorMailAlert;
{
  return JMHexColor(ff59ed);
}

@end
