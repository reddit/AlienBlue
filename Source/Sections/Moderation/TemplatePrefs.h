#import "TemplateGroup.h"

#define kTemplatePrefsPrefKey @"kTemplatePrefsPrefKey"

#define kTemplatePrefsGroupIdentApproval @"Approval"
#define kTemplatePrefsGroupIdentRemoval @"Removal"

@interface TemplatePrefs : NSObject

@property (readonly) TemplateGroup *approvalGroup;
@property (readonly) TemplateGroup *removalGroup;
@property (readonly) NSMutableArray *groups;

@property (strong) NSDate *lastSyncedDate;
@property (strong) NSDate *lastModifiedDate;

- (TemplateGroup *)templateGroupMatchingIdent:(NSString *)groupIdent;

- (void)addTemplate:(Template *)tplate toGroup:(TemplateGroup *)group atIndex:(NSUInteger)ind;
- (void)addTemplate:(Template *)tplate toGroup:(TemplateGroup *)group;
- (void)removeTemplate:(Template *)tplate fromGroup:(TemplateGroup *)group;

+ (TemplatePrefs *)templatePreferences;
- (void)save;

// syncing to icloud
+ (TemplatePrefs *)templatePreferencesFromRawDefaultsData:(NSData *)rawData;
+ (NSData *)rawDefaultsDataForTemplatePreferences:(TemplatePrefs *)tPrefs;
- (void)recommendSyncToCloud;
- (BOOL)shouldSyncToCloud;
- (void)didSyncToCloud;

- (NSUInteger)totalTemplatesCount;
- (NSUInteger)totalUserCreatedTemplatesCount;

@end
