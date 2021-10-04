#import <Foundation/Foundation.h>

// system level
#define kABSettingKeyRedditAccountsList @"redditAccountsList"
#define kABSettingKeyLastViewedAnnouncementIdent @"last_viewed_announcement_id"
#define kABSettingKeyShowConnectionErrors @"show_connection_errors"

// appearance
#define kABSettingKeyNightMode @"night_mode"
#define kABSettingKeySkinTheme @"skin_theme"
#define kABSettingKeyLowContrastMode @"low_contrast_mode"
#define kABSettingKeyTextSizeIndex @"textsize"
#define kABSettingKeyShowSubredditIcons @"show_subreddit_logos"
#define kABSettingKeyShowLegacySubredditIcons @"show_legacy_subreddit_icons"
#define kABSettingKeyUseClassicPhoneUI @"use_classic_iphone_ui"

// behavior
#define kABSettingKeyAllowRotation @"allow_rotation"
#define kABSettingKeyAllowTiltScroll @"allow_tilt_scroll"
#define kABSettingKeyTiltScrollReverseAxis @"reverse_tilt_axis"
#define kABSettingKeyAllowSwipeNavigation @"allow_iphone_swipe_navigation"
#define kABSettingKeyAutoHideStatusBarWhenScrolling @"kABSettingKeyAutoHideStatusBarWhenScrolling"

// posts
#define kABSettingKeyShowVoteArrowsOnPosts @"show_vote_arrows_on_posts"
#define kABSettingKeyCompactMode @"compact_mode"
#define kABSettingKeyShowNSFWRibbon @"show_nsfw_ribbon"
#define kABSettingKeyBoldPostTitles @"bold_post_titles"
#define kABSettingKeyShowThumbnails @"show_thumbs"
#define kABSettingKeyHideQueue @"hideQueue"
#define kABSettingKeyFilterList @"filterList"
#define kABSettingKeyVisitedList @"visitedList"
#define kABSettingKeyMarkPostsAsRead @"mark_posts_as_read"
#define kABSettingKeyAutoLoadPosts @"auto_load_posts"
#define kABSettingKeyShowPostFlair @"show_post_flair"

// comments
#define kABSettingKeyShowVoteArrowsOnComments @"show_vote_arrows_on_comments"
#define kABSettingKeyShowFootnotedLinksOnComments @"show_footnoted_links_on_comments"
#define kABSettingKeyShowLinkThumbnailsInComments @"show_link_thumbnails_in_comments"
#define kABSettingKeyShowCommentFlair @"show_comment_flair"
#define kABSettingKeyAutoLoadInlineImageLink @"auto_load_inline_image_link"
#define kABSettingKeyAlwaysShowCommentTimestamps @"always_show_comment_timestamps"
#define kABSettingKeyCommentScoreThreshold @"comment_score_threshold"
#define kABSettingKeyCommentDefaultSortOrder @"comment_default_sort_order"
#define kABSettingKeyCommentFetchCount @"comment_fetch_count"

// alerts & background notifications
#define kABSettingKeyAllowBackgroundNotifications @"allow_background_notifications"
#define kABSettingKeyAlertForDirectMessages @"alert_for_direct_messages"
#define kABSettingKeyAlertForCommentReplies @"alert_for_comment_replies"
#define kABSettingKeyAlertForModeratorMail @"alert_for_moderator_mail"
#define kABSettingKeyShowAlertPreviewsOnLockScreen @"show_alert_previews_on_lock_screen"

// messages
#define kABSettingKeyAutoMarkMessagesAsRead @"auto_mark_as_read"
#define kABSettingKeyMessageCheckFrequencyIndex @"fetch_message_frequency"

// privacy
#define kABSettingKeyShouldPasswordProtect @"password_protect"
#define kABSettingKeyPasswordCode @"password_code"
#define kABSettingKeyAllowAnalytics @"allow_analytics"

// media display
#define kABSettingKeyMediaDisplayImages @"media_display_images"
#define kABSettingKeyMediaDisplayVideos @"media_display_videos"
#define kABSettingKeyMediaDisplayAlbums @"media_display_albums"
#define kABSettingKeyMediaDisplayWebsites @"media_display_websites"
#define kABSettingKeyMediaDisplaySoundCloud @"media_display_sound_cloud"

#define kABSettingValueMediaDisplayBestGuess 0
#define kABSettingValueMediaDisplayOptimal 1
#define kABSettingValueMediaDisplayStandard 2

// imgur
#define kABSettingKeyImgurUploadsList @"imgurList"
#define kABSettingKeyResizeImageUploads @"resize_image_uploads"
#define kABSettingKeyCropImageUploads @"crop_image_uploads"
#define kABSettingKeyUseLowResImgurImages @"use_lowres_imgur"
#define kABSettingKeyUseDirectImgurLink @"use_direct_imgur_link"

// ipad specific
#define kABSettingKeyIpadUseLegacyPostPaneSize @"legacy_post_panesize"
#define kABSettingKeyIpadCompactPortrait @"compact_portrait"
#define kABSettingKeyIpadHideSidePane @"ipad_hide_side_pane"
#define kABSettingKeyIpadCompactPortraitTrainingComplete @"compact_portrait_training_complete"
#define kABSettingKeyIpadLionThemeShowsLinen @"lion_show_linen"

@interface ABSettings : NSObject
+ (void)generateDefaultsIfNecessary;
@end
