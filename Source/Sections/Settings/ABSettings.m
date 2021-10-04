#import "ABSettings.h"
#import "Resources.h"

#define SET_DEFAULT_IF_EMPTY_BOOL(PREFKEY, BOOLVAL) if (![UDefaults objectForKey:PREFKEY]) [UDefaults setBool:BOOLVAL forKey:PREFKEY];
#define SET_DEFAULT_IF_EMPTY_OBJECT(PREFKEY, OBJECTVAL) if (![UDefaults objectForKey:PREFKEY]) [UDefaults setObject:OBJECTVAL forKey:PREFKEY];
#define SET_DEFAULT_IF_EMPTY_ENUM(PREFKEY, ENUMVAL) if (![UDefaults objectForKey:PREFKEY]) [UDefaults setInteger:ENUMVAL forKey:PREFKEY];
#define SET_DEFAULT_IF_EMPTY_INT(PREFKEY, INTVAL) if (![UDefaults objectForKey:PREFKEY]) [UDefaults setInteger:INTVAL forKey:PREFKEY];

@implementation ABSettings

+ (void)generateSystemLevelPreferences;
{
  if (![UDefaults objectForKey:kABSettingKeyRedditAccountsList])
  {
    NSMutableArray * redditAccountsList = [[NSMutableArray alloc] init];
    [UDefaults setObject:redditAccountsList forKey:kABSettingKeyRedditAccountsList];
  }

  SET_DEFAULT_IF_EMPTY_OBJECT(kABSettingKeyLastViewedAnnouncementIdent, @"none");
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowConnectionErrors, YES);
}

+ (void)generateAppearanceRelatedPreferences;
{
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyNightMode, NO);
  SET_DEFAULT_IF_EMPTY_ENUM(kABSettingKeySkinTheme, SkinThemeClassic);
  SET_DEFAULT_IF_EMPTY_INT(kABSettingKeyTextSizeIndex, 1);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowSubredditIcons, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowLegacySubredditIcons, NO);
  
  // Low contrast mode should also be disabled on launch.  Otherwise, the user may
  // not be able to see the screen at all if app is launched under bright ambient light.
  [UDefaults setBool:NO forKey:kABSettingKeyLowContrastMode];
}

+ (void)generateBehaviorRelatedPreferences;
{
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAllowRotation, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAllowSwipeNavigation, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAutoHideStatusBarWhenScrolling, YES);

  // Always disable tilt-scroll on launch.  Otherwise, the user is going to get
  // unexpected scrolling if they forgot that tilt-scroll was activated previously.
  [UDefaults setBool:NO forKey:kABSettingKeyAllowTiltScroll];
}

+ (void)generatePostsRelatedPreferences;
{
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowVoteArrowsOnPosts, [Resources isIPAD] ? YES : NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowThumbnails, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyCompactMode, NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowNSFWRibbon, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyBoldPostTitles, NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyMarkPostsAsRead, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAutoLoadPosts, NO);
  
  if (![UDefaults objectForKey:kABSettingKeyHideQueue])
  {
    NSMutableArray * hideList = [[NSMutableArray alloc] init];
    [UDefaults setObject:hideList forKey:kABSettingKeyHideQueue];
  }
  
  if(![UDefaults objectForKey:kABSettingKeyFilterList])
  {
    NSMutableArray * filterList = [[NSMutableArray alloc] init];
    [UDefaults setObject:filterList forKey:kABSettingKeyFilterList];
  }
  
  if (![UDefaults objectForKey:kABSettingKeyVisitedList])
  {
    NSMutableArray * visitedList = [[NSMutableArray alloc] init];
    [UDefaults setObject:visitedList forKey:kABSettingKeyVisitedList];
  }
}

+ (void)generateCommentsRelatedPreferences;
{
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowVoteArrowsOnComments, [Resources isIPAD] ? YES : NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowFootnotedLinksOnComments, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAutoLoadInlineImageLink, NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAlwaysShowCommentTimestamps, [Resources isIPAD] ? YES : NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowCommentFlair, NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowLinkThumbnailsInComments, YES);

  SET_DEFAULT_IF_EMPTY_INT(kABSettingKeyCommentScoreThreshold, -5);
  SET_DEFAULT_IF_EMPTY_OBJECT(kABSettingKeyCommentDefaultSortOrder, @"top");
  SET_DEFAULT_IF_EMPTY_INT(kABSettingKeyCommentFetchCount, 200);
}

+ (void)generateBackgroundNotificationRelatedPreferences;
{
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAllowBackgroundNotifications, [Resources isIPAD] ? NO : YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAlertForDirectMessages, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAlertForCommentReplies, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAlertForModeratorMail, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShowAlertPreviewsOnLockScreen, YES);  
}

+ (void)generateMessageRelatedPreferences;
{
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAutoMarkMessagesAsRead, NO);
  SET_DEFAULT_IF_EMPTY_INT(kABSettingKeyMessageCheckFrequencyIndex, 1);
}

+ (void)generatePrivacyRelatedPreferences;
{
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyShouldPasswordProtect, NO);
  SET_DEFAULT_IF_EMPTY_OBJECT(kABSettingKeyPasswordCode, @"");
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyAllowAnalytics, YES);
}

+ (void)generateImgurRelatedPreferences;
{
  if (![UDefaults objectForKey:kABSettingKeyImgurUploadsList])
  {
    NSMutableArray * imgurList = [[NSMutableArray alloc] init];
    [UDefaults setObject:imgurList forKey:kABSettingKeyImgurUploadsList];
  }
  
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyUseDirectImgurLink, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyResizeImageUploads, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyCropImageUploads, NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyUseLowResImgurImages, NO);
}

+ (void)generateIPadExclusivePreferences;
{
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyIpadUseLegacyPostPaneSize, NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyIpadCompactPortrait, YES);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyIpadHideSidePane, NO);
  SET_DEFAULT_IF_EMPTY_BOOL(kABSettingKeyIpadCompactPortraitTrainingComplete, NO);
}

+ (void)generateDefaultsIfNecessary;
{
  [self generateSystemLevelPreferences];
  [self generateAppearanceRelatedPreferences];
  [self generateBehaviorRelatedPreferences];
  [self generatePostsRelatedPreferences];
  [self generateCommentsRelatedPreferences];
  [self generateBackgroundNotificationRelatedPreferences];
  [self generatePrivacyRelatedPreferences];
  [self generateImgurRelatedPreferences];
  [self generateIPadExclusivePreferences];
  
  [UDefaults synchronize];
}

@end
