#import "TemplatePrefs.h"
#import "NSData+Zip.h"
#import "SyncManager+AlienBlue.h"
#import "TemplateGroup+SampleTemplates.h"
#import "SessionManager.h"

static BOOL s_shouldSyncToCloud;

@interface TemplatePrefs()
@property (strong) NSMutableArray *groups;
@property (readonly) NSUInteger totalTemplatesCount;
@end

@implementation TemplatePrefs

+ (TemplatePrefs *)templatePreferences;
{
  NSData *rawData = [UDefaults objectForKey:kTemplatePrefsPrefKey];
  TemplatePrefs *tPrefs = [[self class] templatePreferencesFromRawDefaultsData:rawData];
  
  if (!tPrefs)
  {
    // try cloud storage
    NSData *cloudData = [[SyncManager manager] cloudObjectForKey:kTemplatePrefsPrefKey];
    if (cloudData)
    {
      tPrefs = [TemplatePrefs templatePreferencesFromRawDefaultsData:cloudData];
    }
  }
  
  if (!tPrefs)
  {
    tPrefs = [TemplatePrefs new];
    tPrefs.groups = [NSMutableArray array];
    
    TemplateGroup *approvalGroup = [TemplateGroup groupWithTitle:kTemplatePrefsGroupIdentApproval];
    [approvalGroup addApprovalSampleTemplates];
    
    TemplateGroup *removalGroup = [TemplateGroup groupWithTitle:kTemplatePrefsGroupIdentRemoval];
    [removalGroup addRemovalSampleTemplates];
    
    [tPrefs.groups addObject:approvalGroup];
    [tPrefs.groups addObject:removalGroup];
    
    [tPrefs save];
  }
  
  return tPrefs;
};

- (NSUInteger)totalTemplatesCount;
{
  NSNumber *totalTemplates = [self.groups reduce:[NSNumber numberWithInteger:0] withBlock:^id(NSNumber *total, TemplateGroup *obj) {
    NSUInteger numTemplates = [obj.templates count];
    return [NSNumber numberWithUnsignedInteger:(total.integerValue + numTemplates)];
  }];
  return totalTemplates.integerValue;
}

- (NSUInteger)totalUserCreatedTemplatesCount;
{
  NSNumber *totalTemplates = [self.groups reduce:[NSNumber numberWithInteger:0] withBlock:^id(NSNumber *total, TemplateGroup *obj) {
    NSUInteger numTemplates = [obj.userCreatedTemplates count];
    return [NSNumber numberWithUnsignedInteger:(total.integerValue + numTemplates)];
  }];
  return totalTemplates.integerValue;  
}

- (void)save;
{
  self.lastModifiedDate = [NSDate date];
  
  DLog(@"total templates : %d", self.totalTemplatesCount);

  NSData *rawData = [[self class] rawDefaultsDataForTemplatePreferences:self];
  [UDefaults setObject:rawData forKey:kTemplatePrefsPrefKey];
  [UDefaults synchronize];
}

#pragma mark - Archiving

+ (TemplatePrefs *)templatePreferencesFromRawDefaultsData:(NSData *)rawData;
{
  NSData *stateArchive = [rawData zlibInflate];
  TemplatePrefs *tPrefs = [NSKeyedUnarchiver unarchiveObjectWithData:stateArchive];
  return tPrefs;
}

+ (NSData *)rawDefaultsDataForTemplatePreferences:(TemplatePrefs *)tPrefs;
{
	NSData *stateArchive = [NSKeyedArchiver archivedDataWithRootObject:tPrefs];
	NSData *zippedArchive = [stateArchive zlibDeflate];
  return zippedArchive;
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
  [aCoder encodeObject:self.groups forKey:@"groups"];
  [aCoder encodeObject:self.lastModifiedDate forKey:@"lastModifiedDate"];
  [aCoder encodeObject:self.lastSyncedDate forKey:@"lastSyncedDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
  TemplatePrefs *tPrefs = nil;
  NSArray *groups = [aDecoder decodeObjectForKey:@"groups"];
  NSDate *lastModifiedDate = [aDecoder decodeObjectForKey:@"lastModifiedDate"];
  NSDate *lastSyncedDate = [aDecoder decodeObjectForKey:@"lastSyncedDate"];
  if (groups)
  {
    tPrefs = [TemplatePrefs new];
    tPrefs.groups = [NSMutableArray arrayWithArray:groups];
    tPrefs.lastModifiedDate = lastModifiedDate;
    tPrefs.lastSyncedDate = lastSyncedDate;
  }
  
  return tPrefs;
}

#pragma mark -
#pragma mark Group Management

- (TemplateGroup *)templateGroupMatchingIdent:(NSString *)groupIdent;
{
  return [self.groups match:^BOOL(TemplateGroup *group) {
    return [group.ident equalsString:groupIdent];
  }];
}

- (TemplateGroup *)approvalGroup;
{
  return [self templateGroupMatchingIdent:kTemplatePrefsGroupIdentApproval];
}

- (TemplateGroup *)removalGroup;
{
  return [self templateGroupMatchingIdent:kTemplatePrefsGroupIdentRemoval];
}

#pragma mark -
#pragma mark Template Management

- (void)addTemplate:(Template *)template toGroup:(TemplateGroup *)group atIndex:(NSUInteger)ind;
{
  [group i_insertTemplate:template atIndex:ind];
  [self save];
}

- (void)addTemplate:(Template *)template toGroup:(TemplateGroup *)group;
{
  [self addTemplate:template toGroup:group atIndex:group.templates.count];
}

- (void)removeTemplate:(Template *)template fromGroup:(TemplateGroup *)group;
{
  [group i_removeTemplate:template];
  [self save];
}

#pragma mark -
#pragma mark Syncing

- (void)recommendSyncToCloud;
{
  s_shouldSyncToCloud = YES;
  self.lastModifiedDate = [NSDate new];
  [self save];
}

- (BOOL)shouldSyncToCloud;
{
  return s_shouldSyncToCloud;
}

- (void)didSyncToCloud;
{
  s_shouldSyncToCloud = NO;
}

@end
