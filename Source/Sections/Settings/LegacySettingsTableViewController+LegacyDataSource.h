#import "LegacySettingsTableViewController.h"

typedef enum : NSUInteger {
  SettingsSectionUpgradePro,
  SettingsSectionRedditAccounts,
  SettingsSectionDisplay,
  SettingsSectionBehavior,
  SettingsSectionPosts,
  SettingsSectionComments,
  SettingsSectionNotifications,
  SettingsSectionMessages,
  SettingsSectionImgur,
  SettingsSectionFilter,
  SettingsSectionPrivacy,
  SettingsSectionMediaDisplay,
  SettingsSectionAdvanced,
  SettingsSectionContact,
  SettingsSectionHome,
} SettingsSection;

// todo: need to unroll the insane amount of if/switch statements
// that have been monkey patched and accumulated over the past few years
// This screen needs to be re-written from scratch to extend JMOutlineViewController
// rather than OptionTableViewController

@interface LegacySettingsTableViewController (LegacyDataSource)
@property (readonly) NSUInteger legacy_numberOfSettingsSections;
@property (readonly) NSUInteger legacy_sectionIndexForRedditAccounts;
@property (readonly) NSUInteger legacy_sectionIndexForFilter;
- (NSString *)legacy_titleForSection:(NSUInteger)section;
- (NSUInteger)legacy_numberOfRowsForSection:(NSUInteger)section;
- (NSString *)legacy_labelForIndexPath:(NSIndexPath *)indexPath;
- (void)legacy_decorateForIndexPath:(NSIndexPath *)indexPath forOption:(NSMutableDictionary *)option;
- (void)legacy_didChoosePrimaryOptionAtIndexPath:(NSIndexPath *)indexPath;
- (void)legacy_didChooseSecondaryOptionAtIndexPath:(NSIndexPath *)indexPath;
- (void)legacy_commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)legacy_canEditRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)relatedSubsectionsForSettingSection:(SettingsSection)sectionIndex;
- (NSString *)iconNameForSettingSection:(SettingsSection)section;

@end
