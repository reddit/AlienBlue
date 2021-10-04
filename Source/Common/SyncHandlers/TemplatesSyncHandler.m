#import "TemplatesSyncHandler.h"
#import "TemplatePrefs.h"
#import "NavigationManager.h"
#import "TemplatesViewController.h"
#import "SessionManager.h"

@implementation TemplatesSyncHandler

- (NSString *)keyToMonitor;
{
  return kTemplatePrefsPrefKey;
}

- (BOOL)shouldSendToCloudOnUserDefaultsChange;
{
  return [[SessionManager manager].sharedTemplatePrefs shouldSyncToCloud];
}

- (void)finishedSendingToCloudAfterUserDefaultsChange;
{
  return [[SessionManager manager].sharedTemplatePrefs didSyncToCloud];
}

- (BOOL)requiresSyncing:(id)localObject remoteObject:(id)remoteObject;
{
  TemplatePrefs *local = [SessionManager manager].sharedTemplatePrefs;
  TemplatePrefs *remote = [TemplatePrefs templatePreferencesFromRawDefaultsData:(NSData *)remoteObject];
 
  BOOL requiresSync = (local.totalUserCreatedTemplatesCount < remote.totalUserCreatedTemplatesCount);
//  DLog(@"[TPREFS] :: Remote changes found... require sync");
  return requiresSync;
}

- (TemplateGroup *)mergedTemplateGroupWithLeftGroup:(TemplateGroup *)leftGroup rightGroup:(TemplateGroup *)rightGroup;
{
//  DLog(@"[TPREFS] :: Merging gropus");
  if (leftGroup.userCreatedTemplates.count == 0)
    return rightGroup;
  
  if (rightGroup.userCreatedTemplates.count == 0)
    return leftGroup;
  
  TemplateGroup *mergedGroup = leftGroup;
  [rightGroup.userCreatedTemplates each:^(Template *tPlate) {
    [mergedGroup i_addTemplate:tPlate];
  }];
  
//  DLog(@"[TPREFS] :: Merge complete");
  
  return mergedGroup;
}

- (id)mergeChangeFromLocalObject:(id)localObject remoteObject:(id)remoteObject;
{
  TemplatePrefs *local = [SessionManager manager].sharedTemplatePrefs;
  TemplatePrefs *remote = [TemplatePrefs templatePreferencesFromRawDefaultsData:(NSData *)remoteObject];
  
  TemplateGroup *mergedApprovalGroup = [self mergedTemplateGroupWithLeftGroup:local.approvalGroup rightGroup:remote.approvalGroup];
  TemplateGroup *mergedRemovalGroup = [self mergedTemplateGroupWithLeftGroup:local.removalGroup rightGroup:remote.removalGroup];
  
  TemplatePrefs *merged = local;
  merged.approvalGroup.templates = mergedApprovalGroup.templates;
  merged.removalGroup.templates = mergedRemovalGroup.templates;
  merged.lastSyncedDate = [NSDate new];
  merged.lastModifiedDate = [NSDate latestOfDate:local.lastModifiedDate date:remote.lastModifiedDate];
  
  NSData *mergedArchive = [TemplatePrefs rawDefaultsDataForTemplatePreferences:merged];
  return mergedArchive;
}

- (void)finishedProcessingRemoteMerge;
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UINavigationController *tPlateNav = JMIsKindClassOrNil([NavigationManager shared].postsNavigation.presentedViewController, UINavigationController);
    if (tPlateNav)
    {
      TemplatesViewController *controller = [tPlateNav.viewControllers match:^BOOL(UIViewController *c) {
        return [c isKindOfClass:[TemplatesViewController class]];
      }];
      if (controller)
      {
        [controller performSelector:@selector(reloadTemplatePreferences)];
      }
    }
  });
}

@end
