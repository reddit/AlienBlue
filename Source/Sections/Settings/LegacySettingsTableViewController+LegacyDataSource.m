#import "LegacySettingsTableViewController+LegacyDataSource.h"
#import "Resources.h"
#import "OptionCell.h"
#import "MarkupEngine.h"
#import "UIApplication+ABAdditions.h"
#import "AlienBlueAppDelegate.h"
#import "SessionManager+Authentication.h"
#import "TiltManager.h"
#import "MKStoreManager.h"
#import "NavigationManager.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "RedditAPI+Account.h"

@interface LegacySettingsTableViewController()
- (void)addRedditAccount;
- (void)editAccountAtIndex:(NSUInteger)index;
- (void)removeFilterAtIndex:(NSUInteger)removeIndex;
- (void)removeRedditAccountAtIndex:(NSUInteger)removeIndex;
- (void)addFilter;
- (void)showAcknowledgements;
- (void)showEmailModalView;
- (void)openExternalWithAlertForUrl:(NSString *)url;
- (void)showUpgradeHelpPage;
+ (void)toggleNightTheme;
- (void)chooseCropImages;
- (void)chooseCommentThreshold;
- (void)chooseMessageCheckFrequency;
- (void)chooseTextSize;
- (void)chooseCommentLoadCount;
- (void)chooseResizeImages;
- (void)chooseSkinTheme;
- (void)clearCache;
- (void)showImgurUploadManager;
- (void)showScreenLockSettings;
- (void)logoutFromSharingOptions;
- (void)buyProUpgrade;
- (void)restoreProUpgrade;
- (void)toggleLowContrastMode;
- (void)exportSettingsToClipboard;
- (void)importSettingsFromClipboard;
@end

@implementation LegacySettingsTableViewController (LegacyDataSource)

#pragma mark -
#pragma mark - Reddit Accounts Section

- (void)handleRedditAccountOptionsAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count])
    [self addRedditAccount];
  else {
    [self editAccountAtIndex:indexPath.row];
  }
}

- (void)decorateOptionForRedditAccountSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyBold];
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowNextPageIndicator];
    if (![MKStoreManager isProUpgraded] && [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count] > 0)
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowProFeatureLabel];
    }
  }
  else
  {
    NSMutableDictionary * userPass = [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] objectAtIndex:indexPath.row];
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyHasSecondaryOption];
    if ([userPass objectForKey:@"username"] && [UDefaults valueForKey:@"username"] && [[userPass objectForKey:@"username"] isEqualToString:[UDefaults valueForKey:@"username"]])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowStarFilled];
    }
    else
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowStarEmpty];
    }
  }
}

#pragma mark -
#pragma mark - Comments Section

- (void)showNonRetinaWarningForHighQualityThumbnails
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non-Retina Device"
                                                  message:@"You need a device with a Retina screen for high quality thumbnails."
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
  [alert setTag:105];
  [alert show];
}

- (void)handleCommentSettingsOptionsWithCell:(OptionCell *)cell indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowVoteArrowsOnComments];
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 1)
  {
    if (![MarkupEngine doesSupportMarkdown])
      return;
    
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowFootnotedLinksOnComments];
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 2)
  {
    if (!JMIsRetina() && ![Resources isIPAD])
    {
      [self showNonRetinaWarningForHighQualityThumbnails];
      return;
    }
    REQUIRES_PRO;
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowLinkThumbnailsInComments];
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 3)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAutoLoadInlineImageLink];
  }
  else if (indexPath.row == 4)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAlwaysShowCommentTimestamps];
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 5)
  {
    [self chooseCommentThreshold];
  }
  else if (indexPath.row == 6)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowCommentFlair];
    [self postStyleChangeNotification];
  }
}

- (void)decorateOptionForCommentSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0 && [UDefaults boolForKey:kABSettingKeyShowVoteArrowsOnComments])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
  else if (indexPath.row == 1 && [[UDefaults valueForKey:kABSettingKeyShowFootnotedLinksOnComments] boolValue])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
    if (![MarkupEngine doesSupportMarkdown])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyDisabled];
    }
  }
  else if (indexPath.row == 2 && [[UDefaults valueForKey:kABSettingKeyShowLinkThumbnailsInComments] boolValue])
  {
    if (![MKStoreManager isProUpgraded])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowProFeatureLabel];
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyDisabled];
    }
    else
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
    }
    
    if (!JMIsRetina() && ![Resources isIPAD])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyDisabled];
      [option setValue:[NSNumber numberWithBool:NO] forKey:kOptionCellKeyShowTick];
    }
  }
  else if (indexPath.row == 3 && [[UDefaults valueForKey:kABSettingKeyAutoLoadInlineImageLink] boolValue])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
  else if (indexPath.row == 4 && [[UDefaults valueForKey:kABSettingKeyAlwaysShowCommentTimestamps] boolValue])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
  else if (indexPath.row == 5)
  {
    NSInteger threshold = [UDefaults integerForKey:kABSettingKeyCommentScoreThreshold];
    NSString *thresholdStr;
    if (threshold < -1000)
    {
      thresholdStr = @"Show All";
    }
    else
    {
      thresholdStr = [NSString stringWithFormat:@"%d", threshold];
    }
    [option setValue:thresholdStr forKey:kOptionCellKeyOptionValue];
  }
  else if (indexPath.row == 6 && [[UDefaults valueForKey:kABSettingKeyShowCommentFlair] boolValue])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
}

#pragma mark -
#pragma mark - Notifications Section

- (void)handleNotificationOptionsWithCell:(OptionCell *)cell indexPath:(NSIndexPath *)indexPath
{
  BOOL backgroundNotificationsEnabled = JMIsIOS7() && [UDefaults boolForKey:kABSettingKeyAllowBackgroundNotifications];
  if (indexPath.row == 0)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAllowBackgroundNotifications];
  else if (indexPath.row == 1 && backgroundNotificationsEnabled)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAlertForDirectMessages];
  else if (indexPath.row == 2 && backgroundNotificationsEnabled)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAlertForCommentReplies];
  else if (indexPath.row == 3 && backgroundNotificationsEnabled)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAlertForModeratorMail];
  else if (indexPath.row == 4 && backgroundNotificationsEnabled)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowAlertPreviewsOnLockScreen];
}

- (void)decorateOptionForNotificationSection:(BOOL)backgroundNotificationsEnabled option:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    if (backgroundNotificationsEnabled)
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
    }
    if (!JMIsIOS7())
    {
      [option setValue:@"Requires iOS 7" forKey:kOptionCellKeyOptionValue];
    }
  }
  else if (indexPath.row == 1)
  {
    if ([[UDefaults valueForKey:kABSettingKeyAlertForDirectMessages] boolValue])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
    }
    [option setValue:[NSNumber numberWithBool:!backgroundNotificationsEnabled] forKey:kOptionCellKeyDisabled];
  }
  else if (indexPath.row == 2)
  {
    if ([[UDefaults valueForKey:kABSettingKeyAlertForCommentReplies] boolValue])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
    }
    [option setValue:[NSNumber numberWithBool:!backgroundNotificationsEnabled] forKey:kOptionCellKeyDisabled];
  }
  else if (indexPath.row == 3)
  {
    if ([[UDefaults valueForKey:kABSettingKeyAlertForModeratorMail] boolValue])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
    }
    [option setValue:[NSNumber numberWithBool:!backgroundNotificationsEnabled] forKey:kOptionCellKeyDisabled];
  }
  else if (indexPath.row == 4)
  {
    if ([[UDefaults valueForKey:kABSettingKeyShowAlertPreviewsOnLockScreen] boolValue])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
    }
    [option setValue:[NSNumber numberWithBool:!backgroundNotificationsEnabled] forKey:kOptionCellKeyDisabled];
  }
}

#pragma mark -
#pragma mark - Messages Section

- (void)handleMessageOptionsWithCell:(OptionCell *)cell indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
    [self chooseMessageCheckFrequency];
  else if (indexPath.row == 1)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAutoMarkMessagesAsRead];
}

- (void)decorateOptionForMessageSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    int fetchFrequency = [[UDefaults valueForKey:kABSettingKeyMessageCheckFrequencyIndex] intValue];
    if (fetchFrequency == 0)
      [option setValue:@"Manually" forKey:kOptionCellKeyOptionValue];
    else if (fetchFrequency == 1)
      [option setValue:@"Every 5 Minutes" forKey:kOptionCellKeyOptionValue];
    else if (fetchFrequency == 2)
      [option setValue:@"Every 10 Mins" forKey:kOptionCellKeyOptionValue];
    else if (fetchFrequency == 3)
      [option setValue:@"Every 20 Mins" forKey:kOptionCellKeyOptionValue];
  }
  else if (indexPath.row == 1)
  {
    if ([[UDefaults valueForKey:kABSettingKeyAutoMarkMessagesAsRead] boolValue])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
    }
  }
}

#pragma mark -
#pragma mark - Behavior Section

- (void)handleBehaviorOptionsWithCell:(OptionCell *)cell indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAutoLoadPosts];
  }
  else if (indexPath.row == 1)
  {
    REQUIRES_PRO;
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAllowTiltScroll];
    if (![cell isTicked])
    {
      [[TiltManager shared] activateTiltCalibrationMode];
    }
  }
  else if (indexPath.row == 2)
  {
    if ([UDefaults boolForKey:kABSettingKeyAllowTiltScroll])
    {
      [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyTiltScrollReverseAxis];
    }
  }
  else if (indexPath.row == 3)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAllowRotation];
  }
  else if (indexPath.row == 4)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAllowSwipeNavigation];
  }
  else if (indexPath.row == 5)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAutoHideStatusBarWhenScrolling];
  }
}

- (void)decorateOptionForBehaviorSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (
      (indexPath.row == 0 && [[UDefaults valueForKey:kABSettingKeyAutoLoadPosts] boolValue]) ||
      (indexPath.row == 1 && [[UDefaults valueForKey:kABSettingKeyAllowTiltScroll] boolValue]) ||
      (indexPath.row == 2 && [[UDefaults valueForKey:kABSettingKeyTiltScrollReverseAxis] boolValue]) ||
      (indexPath.row == 3 && [[UDefaults valueForKey:kABSettingKeyAllowRotation] boolValue]) ||
      (indexPath.row == 4 && [[UDefaults valueForKey:kABSettingKeyAllowSwipeNavigation] boolValue]) ||
      (indexPath.row == 5 && [[UDefaults valueForKey:kABSettingKeyAutoHideStatusBarWhenScrolling] boolValue])
      )
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
  
  if (indexPath.row == 2 && ![[UDefaults valueForKey:kABSettingKeyAllowTiltScroll] boolValue])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyDisabled];
  }
}


#pragma mark -
#pragma mark - Appearance Section

- (void)handleAppearanceOptionsWithCell:(OptionCell *)cell indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
    [self chooseSkinTheme];
  else if (indexPath.row == 1)
  {
    [[self class] toggleNightTheme];
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 2)
  {
    [self toggleLowContrastMode];
  }
  else if (indexPath.row == 3)
    [self chooseTextSize];
  else if (indexPath.row == 4)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowSubredditIcons];
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 5 && JMIsIpad())
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyIpadCompactPortrait];
    if (JMPortrait())
    {
      [self postStyleChangeNotification];
    }
  }
  else if (indexPath.row == 5 && JMIsIphone())
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyUseClassicPhoneUI];
    
    if ([UDefaults boolForKey:kABSettingKeyUseClassicPhoneUI])
    {
      [[NavigationManager shared].postsNavigation popToRootViewControllerAnimated:NO];
      [NavigationManager shared].postsNavigation.navigationBarHidden = NO;
      [NavigationManager shared].postsNavigation.toolbarHidden = NO;
      JMOutlineViewController *topController = JMCastOrNil([NavigationManager shared].postsNavigation.topViewController, JMOutlineViewController);
      [topController detachCustomNavigationBarView];
      [[NavigationManager shared].postsNavigation.topViewController setNavbarTitle:@"reddit"];
      [UIApplication sharedApplication].statusBarHidden = NO;
    }
    else
    {
      [[NavigationManager shared].postsNavigation popToRootViewControllerAnimated:NO];
      [NavigationManager shared].postsNavigation.navigationBarHidden = YES;
      [NavigationManager shared].postsNavigation.toolbarHidden = YES;
    }
    
    [[NavigationManager shared] interactionIconsNeedUpdate];
    [self postStyleChangeNotification];
  }
}

- (void)decorateOptionForAppearanceSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowThemePalette];
  }
  else if (
           (indexPath.row == 1 && [[UDefaults valueForKey:kABSettingKeyNightMode] boolValue]) ||
           (indexPath.row == 2 && [[UDefaults valueForKey:kABSettingKeyLowContrastMode] boolValue]) ||
           (indexPath.row == 4 && [[UDefaults valueForKey:kABSettingKeyShowSubredditIcons] boolValue])
           )
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  else if (indexPath.row == 3)
  {
    int fontSize = [[UDefaults valueForKey:kABSettingKeyTextSizeIndex] intValue];
    if (fontSize == 0)
      [option setValue:@"Tiny" forKey:kOptionCellKeyOptionValue];
    else if (fontSize == 1)
      [option setValue:@"Small" forKey:kOptionCellKeyOptionValue];
    else if (fontSize == 2)
      [option setValue:@"Medium" forKey:kOptionCellKeyOptionValue];
    else if (fontSize == 3)
      [option setValue:@"Large" forKey:kOptionCellKeyOptionValue];
    else if (fontSize == 4)
      [option setValue:@"Extra Large" forKey:kOptionCellKeyOptionValue];
  }
  else if (indexPath.row == 5 && JMIsIpad() && [[UDefaults valueForKey:kABSettingKeyIpadCompactPortrait] boolValue])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
  else if (indexPath.row == 5 && JMIsIphone() && [[UDefaults valueForKey:kABSettingKeyUseClassicPhoneUI] boolValue])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
}
//
#pragma mark -
#pragma mark - Posts Section

- (void)handlePostOptionsWithCell:(OptionCell *)cell indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowVoteArrowsOnPosts];
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 1)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowThumbnails];
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 2)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyBoldPostTitles];
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 3)
  {
    if ([Resources isIPAD])
    {
      [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyIpadUseLegacyPostPaneSize];
    }
    else
    {
      [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyCompactMode];
      [MarkupEngine refreshCoreTextStyles];
    }
    [self postStyleChangeNotification];
  }
  else if (indexPath.row == 4)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowPostFlair];
    [self postStyleChangeNotification];
  }

}

- (void)decorateOptionForPostsSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (
      (indexPath.row == 0 && [[UDefaults valueForKey:kABSettingKeyShowVoteArrowsOnPosts] boolValue]) ||
      (indexPath.row == 1 && [[UDefaults valueForKey:kABSettingKeyShowThumbnails] boolValue]) ||
      (indexPath.row == 2 && [[UDefaults valueForKey:kABSettingKeyBoldPostTitles] boolValue]) ||
      (indexPath.row == 3 &&
       ((![Resources isIPAD]  && [[UDefaults valueForKey:kABSettingKeyCompactMode] boolValue]) ||
        ([Resources isIPAD]  && [[UDefaults valueForKey:kABSettingKeyIpadUseLegacyPostPaneSize] boolValue]))
      ) ||
      (indexPath.row == 4 && [[UDefaults valueForKey:kABSettingKeyShowPostFlair] boolValue])
      )
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
}

#pragma mark -
#pragma mark - Pro Upgrade Section

- (void)handleProUpgradeOptionsAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0 && ![MKStoreManager isProUpgraded])
  {
    [self buyProUpgrade];
  }
  else if (indexPath.row == 1 && ![MKStoreManager isProUpgraded])
  {
    [self restoreProUpgrade];
  }
}

- (void)decorateOptionForProUpgradeSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
#ifdef ENABLE_TESTFLIGHT
  [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyBold];
  [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowNextPageIndicator];
#endif
  
  if (indexPath.row == 0)
  {
    if(![MKStoreManager isProUpgraded] && !isUpgradeInProgress)
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyBold];
//      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyHighlight];
//      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowHelpIcon];
//      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyHasSecondaryOption];
    }
  } else if (indexPath.row == 1)
  {
    if (isUpgradeInProgress)
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyBold];
    }
  }
}

#pragma mark -
#pragma mark - Advanced Section

- (void)handleAdvancedOptionsWithCell:(OptionCell *)cell indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyUseLowResImgurImages];
  else if (indexPath.row == 1)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyUseDirectImgurLink];
  else if (indexPath.row == 2)
    [self chooseCommentLoadCount];
  else if (indexPath.row == 3)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowConnectionErrors];
  else if (indexPath.row == 4)
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowNSFWRibbon];
  else if (indexPath.row == 5)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyShowLegacySubredditIcons];
    [self postStyleChangeNotification];
  }
}

- (void)decorateOptionForAdvancedSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (
      (indexPath.row == 0 && [[UDefaults valueForKey:kABSettingKeyUseLowResImgurImages] boolValue]) ||
      (indexPath.row == 1 && [[UDefaults valueForKey:kABSettingKeyUseDirectImgurLink] boolValue]) ||
      (indexPath.row == 3 && [[UDefaults valueForKey:kABSettingKeyShowConnectionErrors] boolValue]) ||
      (indexPath.row == 4 && [[UDefaults valueForKey:kABSettingKeyShowNSFWRibbon] boolValue]) ||
      (indexPath.row == 5 && [[UDefaults valueForKey:kABSettingKeyShowLegacySubredditIcons] boolValue])
      )
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  else if (indexPath.row == 2)
    [option setValue:[[UDefaults stringForKey:kABSettingKeyCommentFetchCount] capitalizedString]
              forKey:kOptionCellKeyOptionValue];
}

#pragma mark -
#pragma mark - Privacy Section

- (void)handlePrivacyOptionsWithCell:(OptionCell *)cell indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    REQUIRES_PRO;
    [self showScreenLockSettings];
  }
  else if (indexPath.row == 1)
  {
    [self clearCache];
  }
  else if (indexPath.row == 2)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyMarkPostsAsRead];
  }
  else if (indexPath.row == 3)
  {
    [self logoutFromSharingOptions];
  }
  else if (indexPath.row == 4)
  {
    [[SessionManager manager] resetGroups];
  }
  else if (indexPath.row == 5)
  {
    [self exportSettingsToClipboard];
  }
  else if (indexPath.row == 6)
  {
    [self importSettingsFromClipboard];
  }
  else if (indexPath.row == 7)
  {
    [UDefaults setBool:![cell isTicked] forKey:kABSettingKeyAllowAnalytics];
  }
}

- (void)decorateOptionForPrivacySection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    if (![MKStoreManager isProUpgraded])
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowProFeatureLabel];
    
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowNextPageIndicator];
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyBold];
  }
  else if (indexPath.row == 2 && [UDefaults boolForKey:kABSettingKeyMarkPostsAsRead])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
  else if (indexPath.row == 7 && [UDefaults boolForKey:kABSettingKeyAllowAnalytics])
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowTick];
  }
}

#pragma mark -
#pragma mark - Media Display Section

- (void)handleMediaDisplayOptionsWithCell:(OptionCell *)cell indexPath:(NSIndexPath *)indexPath
{
  NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:0];
  NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:0];

  NSString *prefKey = [self userDefaultsKeyForMediaDisplayIndex:indexPath];
  NSString *title = [self legacy_labelForIndexPath:indexPath];
  OptionActionSheetValueType typeId = OptionActionSheetValueTypeInteger;

  for (int i = 0; i < 3; i++) {
    [labels addObject:[self labelForMediaDisplaySettingValue:i]];
    [values addObject:[NSNumber numberWithInt:i]];
  }

  [self presentOptionsWithTitle:title labels:labels values:values forKey:prefKey ofType:typeId doAfterChangingSetting:nil];
}

- (NSString *)userDefaultsKeyForMediaDisplayIndex:(NSIndexPath *)indexPath
{
  switch (indexPath.row) {
    case 0:
      return kABSettingKeyMediaDisplayImages;
    case 1:
      return kABSettingKeyMediaDisplayVideos;
    case 2:
      return kABSettingKeyMediaDisplayAlbums;
    case 3:
      return kABSettingKeyMediaDisplayWebsites;
    case 4:
      return kABSettingKeyMediaDisplaySoundCloud;
    default:
      NSAssert(NO, @"Bad indexPath in userDefaultsKeyForMediaDisplayModeIndex:indexPath:.");
      return nil;
  }
}

- (void)decorateOptionForMediaDisplaySection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  NSInteger value = [UDefaults integerForKey:[self userDefaultsKeyForMediaDisplayIndex:indexPath]];
  [option setValue:[self labelForMediaDisplaySettingValue:value] forKey:kOptionCellKeyOptionValue];
}

- (NSString *)labelForMediaDisplaySettingValue:(NSInteger)value {
  switch (value) {
    case kABSettingValueMediaDisplayBestGuess:
      return @"Best Guess";
    case kABSettingValueMediaDisplayOptimal:
      return @"Optimal";
    case kABSettingValueMediaDisplayStandard:
      return @"Standard";
    default:
      NSAssert(NO, @"Bad value in labelForContentModeSettingValue.");
      return nil;
  }
}

#pragma mark -
#pragma mark - Imgur Section

- (void)handleImgurOptionsAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
    [self showImgurUploadManager];
  else if (indexPath.row == 1)
    [self chooseResizeImages];
  else if (indexPath.row == 2)
    [self chooseCropImages];
}

- (void)decorateOptionForImgurSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowNextPageIndicator];
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyBold];
  }
  else if (indexPath.row == 1)
  {
    if ([UDefaults boolForKey:kABSettingKeyResizeImageUploads])
      [option setValue:@"Resize" forKey:kOptionCellKeyOptionValue];
    else
      [option setValue:@"Full Resolution" forKey:kOptionCellKeyOptionValue];
  }
  else if (indexPath.row == 2)
  {
    if ([UDefaults boolForKey:kABSettingKeyCropImageUploads])
      [option setValue:@"Crop First" forKey:kOptionCellKeyOptionValue];
    else
      [option setValue:@"Don't Crop" forKey:kOptionCellKeyOptionValue];
  }
}

#pragma mark -
#pragma mark - Filter Section

- (void)handleFilterOptionsAtIndexPath:(NSIndexPath *)indexPath
{
  REQUIRES_PRO;
  if (indexPath.row == [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyFilterList] count])
    [self addFilter];
}

- (void)decorateOptionForFilterSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyFilterList] count])
  {
    if (![MKStoreManager isProUpgraded])
    {
      [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowProFeatureLabel];
    }
    
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowNextPageIndicator];
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyBold];
  }
}

#pragma mark -
#pragma mark - Contact Section

- (void)handleContactOptionsAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0)
  {
    [self showEmailModalView];
  }
  else if (indexPath.row == 1)
  {
    [self openExternalWithAlertForUrl:@"http://alienblue.org"];
  }
  else if (indexPath.row == 2)
  {
    [self showAcknowledgements];
  }
  else if (indexPath.row == 3)
  {
    [self openExternalWithAlertForUrl:@"http://www.reddit.com/wiki/useragreement.compact"];
  }
  else if (indexPath.row == 4)
  {
    [self openExternalWithAlertForUrl:@"http://www.reddit.com/wiki/privacypolicy.compact"];
  }
}

- (void)decorateOptionForContactSection:(NSMutableDictionary *)option indexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row <= 4)
  {
    [option setValue:[NSNumber numberWithBool:YES] forKey:kOptionCellKeyShowNextPageIndicator];
  }
}

#pragma mark -
#pragma mark - Primary Cell Tap Handling

- (void)legacy_didChoosePrimaryOptionAtIndexPath:(NSIndexPath *)indexPath;
{
  OptionCell * cell = (OptionCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
  
  if (indexPath.section == SettingsSectionRedditAccounts)
  {
    [self handleRedditAccountOptionsAtIndexPath:indexPath];
  }

  if (indexPath.section == SettingsSectionComments)
  {
    [self handleCommentSettingsOptionsWithCell:cell indexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionNotifications)
  {
    [self handleNotificationOptionsWithCell:cell indexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionMessages)
  {
    [self handleMessageOptionsWithCell:cell indexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionBehavior)
  {
    [self handleBehaviorOptionsWithCell:cell indexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionDisplay)
  {
    [self handleAppearanceOptionsWithCell:cell indexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionPosts)
  {
    [self handlePostOptionsWithCell:cell indexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionUpgradePro)
  {
    [self handleProUpgradeOptionsAtIndexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionAdvanced)
  {
    [self handleAdvancedOptionsWithCell:cell indexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionPrivacy)
  {
    [self handlePrivacyOptionsWithCell:cell indexPath:indexPath];
  }

  if (indexPath.section == SettingsSectionMediaDisplay)
  {
    [self handleMediaDisplayOptionsWithCell:cell indexPath:indexPath];
  }

  if (indexPath.section == SettingsSectionImgur)
  {
    [self handleImgurOptionsAtIndexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionFilter)
  {
    [self handleFilterOptionsAtIndexPath:indexPath];
  }
  
  if (indexPath.section == SettingsSectionContact)
  {
    [self handleContactOptionsAtIndexPath:indexPath];
  }
  
  [UDefaults synchronize];
  [self refreshTable];
}

#pragma mark -
#pragma mark - Secondary (Right-Edge) Tap Handling

- (void)legacy_didChooseSecondaryOptionAtIndexPath:(NSIndexPath *)indexPath;
{
  if (indexPath.section == SettingsSectionRedditAccounts)
  {
    if (indexPath.row < [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count])
    {
      [[SessionManager manager] switchToRedditAccountAtIndex:indexPath.row withCallBackTarget:self];
    }
  }
  
  if (indexPath.section == SettingsSectionUpgradePro)
  {
    if (indexPath.row == 0)
    {
      [self showUpgradeHelpPage];
    }
  }
  
  [UDefaults synchronize];
  [self refreshTable];
}

#pragma mark -
#pragma mark - Swipe-to-delete handlers

- (void)legacy_commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    if (indexPath.section == SettingsSectionRedditAccounts &&
        indexPath.row < [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count])
      [self removeRedditAccountAtIndex:indexPath.row];
    
    if (indexPath.section == SettingsSectionFilter &&
        indexPath.row < [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyFilterList] count])
      [self removeFilterAtIndex:indexPath.row];
  }
}

- (BOOL)legacy_canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
  if (indexPath.section == SettingsSectionRedditAccounts &&
      indexPath.row < [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count])
    return YES;
  
  if (indexPath.section == SettingsSectionFilter &&
      indexPath.row < [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyFilterList] count])
    return YES;
  
  return NO;
}

#pragma mark -
#pragma mark - Table Data Source

- (NSUInteger)legacy_sectionIndexForRedditAccounts;
{
  return SettingsSectionRedditAccounts;
}

- (NSUInteger)legacy_sectionIndexForFilter;
{
  return SettingsSectionFilter;
}

- (NSUInteger)legacy_numberOfSettingsSections;
{
  return 14;
}

- (NSString *)legacy_labelForIndexPath:(NSIndexPath *)indexPath;
{
  NSString *label = @"";
  switch (indexPath.section)
  {
    case SettingsSectionRedditAccounts:
      if (indexPath.row < [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count])
      {
        NSMutableDictionary * userPass = [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] objectAtIndex:indexPath.row];
        label = [userPass objectForKey:@"username"];
      }
      else
      {
        if ([[UDefaults objectForKey:kABSettingKeyRedditAccountsList] count] > 0)
          label = @"Add another account...";
        else
          label = @"Add your reddit account...";
      }
      break;
      
    case SettingsSectionComments:
      if (indexPath.row == 0)
        label = @"Show Voting Arrows";
      else if (indexPath.row == 1)
        label = @"Show Link Footnotes";
      else if (indexPath.row == 2)
        label = @"Link Previews";
      else if (indexPath.row == 3)
        label = @"Auto load image for image links";
      else if (indexPath.row == 4)
        label = @"Show Timestamps";
      else if (indexPath.row == 5)
        label = @"Hide Comments Below Score";
      else if (indexPath.row == 6)
        label = @"Show Author Flair";
      break;
      
    case SettingsSectionNotifications:
      if (indexPath.row == 0)
        label = @"Allow Background Notifications";
      else if (indexPath.row == 1)
        label = @"Alert for Direct Messages";
      else if (indexPath.row == 2)
        label = @"Alert for Comment Replies";
      else if (indexPath.row == 3)
        label = @"Alert for Moderator Mail";
      else if (indexPath.row == 4)
        label = @"Show Previews on Lock Screen";
      break;
      
    case SettingsSectionMessages:
      if (indexPath.row == 0)
        label = @"Check New Messages";
      else if (indexPath.row == 1)
        label = @"Auto Mark As Read";
      break;
      
    case SettingsSectionDisplay:
      if (indexPath.row == 0)
        label = @"Theme";
      else if (indexPath.row == 1)
        label = @"Night Mode";
      else if (indexPath.row == 2)
        label = @"Ultra-Low Contrast";
      else if (indexPath.row == 3)
        label = @"Text Size";
      else if (indexPath.row == 4)
        label = @"Show Subreddit Logos";
      else if (indexPath.row == 5)
        label = [Resources isIPAD] ? @"Compact Panes (in Portrait)" : @"Use Classic UI";
      break;
      
    case SettingsSectionPosts:
      if (indexPath.row == 0)
        label = @"Show Voting Arrows";
      else if (indexPath.row == 1)
        label = @"Show Thumbnails";
      else if (indexPath.row == 2)
        label = @"Bold Post Titles";
      else if (indexPath.row == 3)
        label = [Resources isIPAD] ? @"Resize Pane to Fit (Legacy Behavior)" : @"Compact";
      else if (indexPath.row == 4)
        label = @"Show Post Flair";
      break;
      
    case SettingsSectionBehavior:
      if (indexPath.row == 0)
        label = @"Auto-Load Posts While Scrolling";
      else if (indexPath.row == 1)
        label = @"Enable Tilt-Scrolling";
      else if (indexPath.row == 2)
        label = @"Reverse Tilt-Scroll Direction";
      else if (indexPath.row == 3)
        label = @"Allow Rotation";
      else if (indexPath.row == 4)
        label = @"Use Screen Edges to Navigate";
      else if (indexPath.row == 5)
        label = @"Hide Status Bar When Scrolling";
      break;
      
    case SettingsSectionUpgradePro:
      if (indexPath.row == 0)
      {
        #ifdef ENABLE_TESTFLIGHT
        return @"Send Beta Testing Feedback";
        #endif
        
        if (isUpgradeInProgress)
          label = @"Connecting to iTunes. Please wait...";
        else if ([[MKStoreManager proUpgradePriceInfo] length] > 0)
          label = [NSString stringWithFormat:@"Upgrade Now (%@)",[MKStoreManager proUpgradePriceInfo]];
        else
          label = @"Upgrade Now";
      } else if (indexPath.row == 1)
      {
        if (isUpgradeInProgress)
          label = @"Cancel";
        else
          label = @"Restore PRO Upgrade";
      }
      break;
      
    case SettingsSectionAdvanced:
      if (indexPath.row == 0)
        label = @"Use Low Resolution Images (Imgur)";
      else if (indexPath.row == 1)
        label = @"Deeplink Imgur Images";
      else if (indexPath.row == 2)
        label = @"Comments to Fetch";
      else if (indexPath.row == 3)
        label = @"Show Connection Errors";
      else if (indexPath.row == 4)
        label = @"Show NSFW Indicators";
      else if (indexPath.row == 5)
        label = @"Use Original Subreddit Icons (non-retina)";
      break;
      
    case SettingsSectionPrivacy:
      if (indexPath.row == 0)
        label = @"Password Protect Alien Blue";
      else if (indexPath.row == 1)
        label = @"Clear Cache";
      else if (indexPath.row == 2)
        label = @"Mark Visited Posts";
      else if (indexPath.row == 3)
        label = @"Clear Sharing Logins";
      else if (indexPath.row == 4)
        label = @"Reset Subreddit Groups";
      else if (indexPath.row == 5)
        label = @"Export Settings to Clipboard";
      else if (indexPath.row == 6)
        label = @"Import Settings from Clipboard";
      else if (indexPath.row == 7)
        label = @"Help reddit by Sharing App Usage";
      break;

    case SettingsSectionMediaDisplay:
      if (indexPath.row == 0)
        label = @"Images & GIFs";
      else if (indexPath.row == 1)
        label = @"Video";
      else if (indexPath.row == 2)
        label = @"Albums";
      else if (indexPath.row == 3)
        label = @"Websites";
      else if (indexPath.row == 4)
        label = @"SoundCloud";
      break;

    case SettingsSectionImgur:
      if (indexPath.row == 0)
        label = @"Manage my photo uploads...";
      else if (indexPath.row == 1)
        label = @"Resize Before Uploading";
      else if (indexPath.row == 2)
        label = @"Crop Images Before Uploading";
      break;
      
    case SettingsSectionContact:
      if (indexPath.row == 0)
        label = @"Report a Bug";
      else if (indexPath.row == 1)
        label = @"Visit Online";
      else if (indexPath.row == 2)
        label = @"Acknowledgments";
      else if (indexPath.row == 3)
        label = @"User Agreement";
      else if (indexPath.row == 4)
        label = @"Privacy Policy";
      else if (indexPath.row == 5)
        label = [NSString stringWithFormat:@"You are using %@", [self appVersion]];
      break;
      
    case SettingsSectionFilter:
      if (indexPath.row < [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyFilterList] count])
        label = [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyFilterList] objectAtIndex:indexPath.row];
      else
        label = @"Add a filter...";
      break;
      
    default:
      break;
  }
  return label;
}

- (NSUInteger)legacy_numberOfRowsForSection:(NSUInteger)section;
{
  switch (section) {
    case SettingsSectionRedditAccounts:
      return [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count] + 1;
      break;
    case SettingsSectionNotifications:
      return 5;
      break;
    case SettingsSectionMessages:
      return 2;
      break;
    case SettingsSectionComments:
      return 7;
      break;
    case SettingsSectionDisplay:
      return 6;
      break;
    case SettingsSectionPosts:
      return 5;
      break;
    case SettingsSectionBehavior:
      return 6;
      break;
    case SettingsSectionUpgradePro:
      #ifdef ENABLE_TESTFLIGHT
      return 1;
      #endif
      // if the user has upgraded, hide the upgrade section
      if([MKStoreManager isProUpgraded])
        return 0;
      else
        return 2;
      break;
    case SettingsSectionFilter:
      return [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyFilterList] count] + 1;
      break;
    case SettingsSectionAdvanced:
      return 6;
      break;
    case SettingsSectionPrivacy:
      return 8;
    case SettingsSectionMediaDisplay:
      return 5;
    case SettingsSectionImgur:
      return 2;
      break;
    case SettingsSectionContact:
      return 6;
      break;
    default:
      return 0;
      break;
  }
}

- (NSString *)legacy_titleForSection:(NSUInteger)section;
{
  NSUInteger numberOfRedditAccounts = [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count];
  switch (section) {
    case SettingsSectionRedditAccounts:
      return numberOfRedditAccounts == 0 ? @"Log in / Sign up" : @"Accounts";
      break;
    case SettingsSectionPosts:
      return @"Posts";
      break;
    case SettingsSectionComments:
      return @"Comments";
      break;
    case SettingsSectionNotifications:
      return @"Notifications";
      break;
    case SettingsSectionMessages:
      return @"Messages";
      break;
    case SettingsSectionDisplay:
      return @"Appearance";
      break;
    case SettingsSectionBehavior:
      return @"Behavior";
      break;
    case SettingsSectionUpgradePro:
#ifdef ENABLE_TESTFLIGHT
      return @"Beta Testing";
#endif
      if(![MKStoreManager isProUpgraded])
        return @"Upgrade to Pro";
      else
        return nil;
      break;
    case SettingsSectionFilter:
      return @"Content Filter";
      break;
    case SettingsSectionAdvanced:
      return @"Advanced Settings";
      break;
    case SettingsSectionPrivacy:
      return @"Privacy Settings";
      break;
    case SettingsSectionMediaDisplay:
      return @"Media Display Settings";
      break;
    case SettingsSectionImgur:
      return @"Imgur Uploads";
      break;
    case SettingsSectionContact:
      return @"About Alien Blue";
      break;
    case SettingsSectionHome:
      return @"Settings";
      break;
    default:
      return nil;
      break;
  }
}

- (void)legacy_decorateForIndexPath:(NSIndexPath *)indexPath forOption:(NSMutableDictionary *)option;
{
  BOOL backgroundNotificationsEnabled = JMIsIOS7() && [[UDefaults valueForKey:kABSettingKeyAllowBackgroundNotifications] boolValue];
  
  switch (indexPath.section) {
      
    case SettingsSectionRedditAccounts:
      [self decorateOptionForRedditAccountSection:option indexPath:indexPath];
      break;
    case SettingsSectionContact:
      [self decorateOptionForContactSection:option indexPath:indexPath];
      break;
    case SettingsSectionComments:
      [self decorateOptionForCommentSection:option indexPath:indexPath];
      break;
    case SettingsSectionNotifications:
      [self decorateOptionForNotificationSection:backgroundNotificationsEnabled option:option indexPath:indexPath];
      break;
    case SettingsSectionMessages:
      [self decorateOptionForMessageSection:option indexPath:indexPath];
      break;
    case SettingsSectionDisplay:
      [self decorateOptionForAppearanceSection:option indexPath:indexPath];
      break;
    case SettingsSectionPosts:
      [self decorateOptionForPostsSection:option indexPath:indexPath];
      break;
    case SettingsSectionBehavior:
      [self decorateOptionForBehaviorSection:option indexPath:indexPath];
      break;
    case SettingsSectionUpgradePro:
      [self decorateOptionForProUpgradeSection:option indexPath:indexPath];
      break;
    case SettingsSectionAdvanced:
      [self decorateOptionForAdvancedSection:option indexPath:indexPath];
      break;
    case SettingsSectionPrivacy:
      [self decorateOptionForPrivacySection:option indexPath:indexPath];
      break;
    case SettingsSectionMediaDisplay:
      [self decorateOptionForMediaDisplaySection:option indexPath:indexPath];
      break;
    case SettingsSectionImgur:
      [self decorateOptionForImgurSection:option indexPath:indexPath];
      break;
    case SettingsSectionFilter:
      [self decorateOptionForFilterSection:option indexPath:indexPath];
      break;
    default:
      break;
  }
}

- (NSArray *)relatedSubsectionsForSettingSection:(SettingsSection)sectionIndex;
{
  NSArray *relatedSections = nil;
  switch (sectionIndex) {
    case SettingsSectionMessages:
      relatedSections = @[ @(SettingsSectionNotifications) ];
      break;
    case SettingsSectionPosts:
      relatedSections = @[ @(SettingsSectionFilter) ];
      break;
    case SettingsSectionAdvanced:
      relatedSections = @[ @(SettingsSectionPrivacy), @(SettingsSectionMediaDisplay) ];
      break;
    default:
      break;
  }
  return relatedSections;
};


- (NSString *)iconNameForSettingSection:(SettingsSection)section;
{
  switch (section) {
    case SettingsSectionRedditAccounts:
      return @"settings-reddit-accounts-icon";
      break;
    case SettingsSectionPosts:
      return @"settings-post-icon";
      break;
    case SettingsSectionComments:
      return @"settings-comments-icon";
      break;
    case SettingsSectionNotifications:
      return @"settings-notifications-icon";
      break;
    case SettingsSectionMessages:
      return @"settings-messages-icon";
      break;
    case SettingsSectionDisplay:
      return @"settings-appearance-icon";
      break;
    case SettingsSectionBehavior:
      return @"settings-behavior-icon";
      break;
    case SettingsSectionUpgradePro:
      return @"settings-pro-upgrade-icon";
      break;
    case SettingsSectionFilter:
      return @"settings-filter-icon";
      break;
    case SettingsSectionAdvanced:
      return @"settings-advanced-icon";
      break;
    case SettingsSectionPrivacy:
      return @"settings-privacy-icon";
      break;
    case SettingsSectionMediaDisplay:
      return @"photo-icon";
      break;
    case SettingsSectionImgur:
      return @"settings-imgur-icon";
      break;
    case SettingsSectionContact:
      return @"settings-about-icon";
      break;
    default:
      return nil;
      break;
  }
}

@end
