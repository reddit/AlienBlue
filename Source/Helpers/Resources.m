//
//  Resources.m
//  Alien Blue :: http://alienblue.org
//
//  Created by Jason Morrissey on 5/05/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "Resources.h"
#import "NavigationManager.h"
#import "AlienBlueAppDelegate.h"
#import "UIColor+Hex.h"
#import "UIColor+Skin.h"
#import "RedditAPI+Account.h"
#import "MKStoreManager.h"

static BOOL s_cachedShouldShowPostThumbnailsNeedsUpdate = YES;
static BOOL s_cachedShouldShowPostThumbnails;
static BOOL s_cachedSkinThemeNeedsUpdate = YES;
static SkinTheme s_cachedSkinTheme;
static BOOL s_cachedNightModeNeedsUpdate = YES;
static BOOL s_cachedIsNightMode;
static BOOL s_cachedShowPostVotingIconsNeedsUpdate = YES;
static BOOL s_cachedShowPostVotingIcons;
static BOOL s_cachedShowRetinaThumbnailsNeedsUpdate = YES;
static BOOL s_cachedShowRetinaThumbnails;
static BOOL s_cachedShowCommentVotingIconsNeedsUpdate = YES;
static BOOL s_cachedShowCommentVotingIcons;
static BOOL s_cachedAutoHideStatusBarWhenScrollingNeedsUpdate = YES;
static BOOL s_cachedAutoHideStatusBarWhenScrolling;

@implementation Resources


+ (void)initialize
{
  if (self == [Resources class])
  {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChangedNotification:) name:NSUserDefaultsDidChangeNotification object:nil];
  }
}

+ (BOOL)isIPAD;
{
  return JMIsIpad();
}

+ (NSUInteger)maxThreadLevel
{
  return [self isIPAD] ? 10 : 6;
}

+ (BOOL)compactPortrait;
{
  if ([Resources isIPAD] && JMPortrait() && [[NSUserDefaults standardUserDefaults] boolForKey:@"compact_portrait"])
  {
    return YES;
  }
  else
  {
    return NO;
  }
}

+ (BOOL)isPro;
{
  if ([self isIPAD])
      return YES;
  
  return [MKStoreManager isProUpgraded];
}

+ (CGSize)thumbSize;
{
  if ([Resources isIPAD])
      return CGSizeMake(60., 60.);
  else
      return CGSizeMake(50., 50.);
};

+ (BOOL)compact;
{
  return [UDefaults boolForKey:kABSettingKeyCompactMode];
}

+ (BOOL)safeFilter;
{
  NSString *authUser = [RedditAPI shared].authenticatedUser;
  BOOL loggedIn = authUser && ![authUser isEmpty];
  
  if (!loggedIn)
    return YES;
  
  if (![RedditAPI shared].isOver18)
    return YES;
  
  // todo: switch this to check over_18 on me.json once the admins add it
  BOOL isTestUserAccount = [authUser jm_contains:@"apitest"];
  if (isTestUserAccount)
    return YES;
  
  return NO;
}

+ (BOOL)useActionMenu;
{
  return ![Resources isIPAD] && ![UDefaults boolForKey:kABSettingKeyUseClassicPhoneUI];
}

+ (BOOL)showCommentVotingIcons;
{
  if (s_cachedShowCommentVotingIconsNeedsUpdate)
  {
    s_cachedShowCommentVotingIcons = [UDefaults boolForKey:kABSettingKeyShowVoteArrowsOnComments];
    s_cachedShowCommentVotingIconsNeedsUpdate = NO;
  }
  return s_cachedShowCommentVotingIcons;
}

+ (BOOL)showRetinaThumbnails;
{
  if (s_cachedShowRetinaThumbnailsNeedsUpdate)
  {
    s_cachedShowRetinaThumbnails = [UDefaults boolForKey:kABSettingKeyShowLinkThumbnailsInComments];
    s_cachedShowRetinaThumbnailsNeedsUpdate = NO;
  }
  return s_cachedShowRetinaThumbnails;
}

+ (BOOL)showPostVotingIcons;
{
  if (s_cachedShowPostVotingIconsNeedsUpdate)
  {
    if (![UDefaults boolForKey:kABSettingKeyShowVoteArrowsOnPosts])
    {
      s_cachedShowPostVotingIcons = NO;
    }
    else if ([Resources compactPortrait] && [[NavigationManager shared].postsNavigation.viewControllers count] > 2)
    {
      // in ipad portrait mode, we need to make a bit more room for content
      s_cachedShowPostVotingIcons = NO;
    }
    else
    {
      s_cachedShowPostVotingIcons = YES;
    }
    s_cachedShowPostVotingIconsNeedsUpdate = NO;
  }
  return s_cachedShowPostVotingIcons;
}

+ (BOOL)isNight;
{

  if (s_cachedNightModeNeedsUpdate)
  {
    s_cachedIsNightMode = [UDefaults boolForKey:kABSettingKeyNightMode];
    s_cachedNightModeNeedsUpdate = NO;
  }
  return s_cachedIsNightMode;
}

+ (BOOL)shouldShowPostThumbnails;
{
  if (s_cachedShouldShowPostThumbnailsNeedsUpdate)
  {
    s_cachedShouldShowPostThumbnails = [UDefaults boolForKey:kABSettingKeyShowThumbnails];
    s_cachedShouldShowPostThumbnailsNeedsUpdate = NO;
  }
  return s_cachedShouldShowPostThumbnails;
}

+ (BOOL)shouldAutoHideStatusBarWhenScrolling;
{
  if (s_cachedAutoHideStatusBarWhenScrollingNeedsUpdate)
  {
    s_cachedAutoHideStatusBarWhenScrolling = JMIsIphone() && [UDefaults boolForKey:kABSettingKeyAutoHideStatusBarWhenScrolling];
    s_cachedAutoHideStatusBarWhenScrollingNeedsUpdate = NO;
  }
  return s_cachedAutoHideStatusBarWhenScrolling;
}

+ (SkinTheme)skinTheme;
{
  if (s_cachedSkinThemeNeedsUpdate)
  {
    s_cachedSkinTheme = (SkinTheme) [[UDefaults objectForKey:kABSettingKeySkinTheme] intValue];
    s_cachedSkinThemeNeedsUpdate = NO;
  }
  return s_cachedSkinTheme;
}

+ (void)userDefaultsChangedNotification:(NSNotification *)notification;
{
  s_cachedNightModeNeedsUpdate = YES;
  s_cachedShowPostVotingIconsNeedsUpdate = YES;
  s_cachedSkinThemeNeedsUpdate = YES;
  s_cachedShouldShowPostThumbnailsNeedsUpdate = YES;
  s_cachedShowRetinaThumbnailsNeedsUpdate = YES;
  s_cachedShowCommentVotingIconsNeedsUpdate = YES;
  s_cachedAutoHideStatusBarWhenScrollingNeedsUpdate = YES;
}

@end
