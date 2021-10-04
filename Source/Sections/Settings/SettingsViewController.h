#import "ABOutlineViewController.h"
#import "LegacySettingsTableViewController+LegacyDataSource.h"

@interface SettingsViewController : ABOutlineViewController

- (id)initWithSettingsSection:(SettingsSection)settingsSection;

+ (void)toggleNightTheme;

@end
