//
//  GroupSyncHandler.m
//  AlienBlue
//
//  Created by J M on 19/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "GroupSyncHandler.h"
#import "UserSubredditPreferences.h"
#import "SessionManager.h"
#import "FolderChangeTrackRecord.h"
#import "NSArray+BlocksKit.h"
#import "NavigationManager.h"
#import "RedditsViewController.h"
#import "FolderChangeTrackRecord+Sync.h"

@interface GroupSyncHandler()
- (SubredditFolder *)mergedFolder:(SubredditFolder *)leftFolder withFolder:(SubredditFolder *)rightFolder  basedOnChangeLog:(NSMutableArray *)changeLog;
@end

@implementation GroupSyncHandler

- (NSString *)keyToMonitor;
{
    return [UserSubredditPreferences prefKey];
}

- (BOOL)shouldSendToCloudOnUserDefaultsChange;
{
    return [[[SessionManager manager] subredditPrefs] shouldSyncToCloud];
}

- (void)finishedSendingToCloudAfterUserDefaultsChange;
{
    return [[[SessionManager manager] subredditPrefs] didSyncToCloud];
}

- (BOOL)requiresSyncing:(id)localObject remoteObject:(id)remoteObject;
{
    UserSubredditPreferences *local = [[SessionManager manager] subredditPrefs];
    UserSubredditPreferences *remote = [UserSubredditPreferences subredditPreferencesFromRawDefaultsData:(NSData *)remoteObject];

    FolderChangeTrackRecord *lastLocalChange = [local.changeLog last];
    FolderChangeTrackRecord *lastRemoteChange = [remote.changeLog last];
    
    BOOL requireSync = ![lastLocalChange.timestamp isSameAsDate:lastRemoteChange.timestamp];
//    if (requireSync)
//    {
//        DLog(@"[-] change logs don't match -- need to sync");
//    }
//    else 
//    {
//        DLog(@"[+] change logs match :) ");
//    }
    
    return requireSync;
}

- (BOOL)changeLog:(NSArray *)changeLog containsChangeRecord:(FolderChangeTrackRecord *)record;
{
    return [changeLog match:^BOOL(FolderChangeTrackRecord *r) {
        return ([r.timestamp isSameAsDate:record.timestamp] && 
                r.changeType == record.changeType && 
                [r.folderIdent equalsString:record.folderIdent] &&
                ((r.subredditUrl == nil && record.subredditUrl == nil) || [r.subredditUrl equalsString:record.subredditUrl])
                );
    }] != nil;
}

- (NSMutableArray *)mergedChangeLogWithLocal:(UserSubredditPreferences *)local remote:(UserSubredditPreferences *)remote;
{
    NSMutableArray *changeLog = [NSMutableArray array];
    BSELF(GroupSyncHandler);

    [local.changeLog each:^(FolderChangeTrackRecord *record) {
        if (![blockSelf changeLog:changeLog containsChangeRecord:record])
        {
            record.modifiedBy = ModifyingPartyLocal;
            [changeLog addObject:record];
        }
    }];
    
    [remote.changeLog each:^(FolderChangeTrackRecord *record) {
        if (![blockSelf changeLog:changeLog containsChangeRecord:record])
        {
            record.modifiedBy = ModifyingPartyRemote;
            [changeLog addObject:record];
        }
    }];
        
    [changeLog sortUsingComparator:^NSComparisonResult(FolderChangeTrackRecord *obj1, FolderChangeTrackRecord *obj2) {
        return [obj1.timestamp compare:obj2.timestamp];
    }];

//    NSArray *truncated = [changeLog limitToLength:100];
//    DLog(@"--- New change log ---");
//    [changeLog each:^(FolderChangeTrackRecord *item) {
//        DLog(@"Change (%d) : %@ (folder %@) :: %d", item.changeType, item.subredditUrl, item.folderIdent, item.orderedToRow);
//    }];
    return changeLog;
}

- (ModifyingParty)lastModifiedByForSubreddit:(Subreddit *)subreddit basedOnChangeLog:(NSMutableArray *)changeLog;
{
    NSArray *records = [changeLog select:^BOOL(FolderChangeTrackRecord *record) {
        return [record.subredditUrl equalsString:subreddit.url];
    }];

    if (!records || [records count] == 0)
        return ModifyingPartyLocal;
    
    FolderChangeTrackRecord *record = [records last];
    return record.modifiedBy;
}

- (ModifyingParty)lastModifiedByForFolder:(SubredditFolder *)folder basedOnChangeLog:(NSMutableArray *)changeLog;
{
    NSArray *records = [changeLog select:^BOOL(FolderChangeTrackRecord *record) {
        return ([record.folderIdent equalsString:folder.ident] && record.subredditUrl == nil);
    }];
    
    if (!records || [records count] == 0)
        return ModifyingPartyLocal;
    
    FolderChangeTrackRecord *record = [records last];
    return record.modifiedBy;
}

- (ModifyingParty)lastReorderActionByBasedOnChangeLog:(NSMutableArray *)changeLog;
{
    NSArray *records = [changeLog select:^BOOL(FolderChangeTrackRecord *record) {
        return (record.changeType == FolderChangeReorderSubreddit || record.changeType == FolderChangeReorderFolder);
    }];

    if (!records || [records count] == 0)
        return ModifyingPartyLocal;
    
    FolderChangeTrackRecord *record = [records last];
    return record.modifiedBy;    
}

- (BOOL)shouldRemoveSubreddit:(Subreddit *)subreddit fromFolder:(SubredditFolder *)folder basedOnChangeLog:(NSMutableArray *)changeLog;
{
    NSArray *records = [changeLog select:^BOOL(FolderChangeTrackRecord *record) {
        return ([record.folderIdent equalsString:folder.ident] && [record.subredditUrl equalsString:subreddit.url]);
    }];
    FolderChangeTrackRecord *record = [records last];
    return record.changeType == FolderChangeRemoveSubreddit;
}

- (BOOL)shouldRemoveFolder:(SubredditFolder *)folder  basedOnChangeLog:(NSMutableArray *)changeLog;
{
    NSArray *records = [changeLog select:^BOOL(FolderChangeTrackRecord *record) {
        return ([record.folderIdent equalsString:folder.ident] && record.subredditUrl == nil);
    }];
    
    if (!records || [records count] == 0)
        return NO;
    
    FolderChangeTrackRecord *record = [records last];
    return record.changeType == FolderChangeRemoveFolder;
}

- (BOOL)folderList:(NSArray *)folderList containsFolderWithIdent:(NSString *)ident;
{
    return [folderList match:^BOOL(SubredditFolder *folder) {
        return [folder.ident equalsString:ident];
    }] != nil;
}

- (BOOL)subredditList:(NSArray *)subredditList containsSubredditWithUrl:(NSString *)url;
{
    return [subredditList match:^BOOL(Subreddit *sr) {
        return [sr.url equalsString:url];
    }] != nil;
}

- (NSMutableArray *)mergedSubfolderListWithLocal:(UserSubredditPreferences *)local remote:(UserSubredditPreferences *)remote basedOnChangeLog:(NSMutableArray *)changeLog;
{
    NSUInteger step = 0;
    NSUInteger maxSteps = MAX(local.subredditFolders.count, remote.subredditFolders.count) - 1;
    NSMutableArray *merged = [NSMutableArray array];
    
    BSELF(GroupSyncHandler);
    while (step <= maxSteps)
    {
        SubredditFolder *left = [local.subredditFolders safeObjectAtIndex:step];
        SubredditFolder *right = [remote.subredditFolders safeObjectAtIndex:step];
        
        BOOL shouldAddLeft = left != nil && ![blockSelf shouldRemoveFolder:left basedOnChangeLog:changeLog] && ![blockSelf folderList:merged containsFolderWithIdent:left.ident];
        if (shouldAddLeft)
            [merged addObject:left];
        
        BOOL shouldAddRight = right != nil && ![blockSelf shouldRemoveFolder:right basedOnChangeLog:changeLog] && ![blockSelf folderList:merged containsFolderWithIdent:right.ident];
        if (shouldAddRight)
            [merged addObject:right];
        
        step++;
    }
    
    ModifyingParty lastOrderModifier = [self lastReorderActionByBasedOnChangeLog:changeLog];
    NSMutableArray *orderLookup = (lastOrderModifier == ModifyingPartyLocal) ? local.subredditFolders : remote.subredditFolders;
    [orderLookup eachWithIndex:^(SubredditFolder *folder, NSUInteger itemIndex) {
        SubredditFolder *match = [merged match:^BOOL(SubredditFolder *mFolder) {
            return [mFolder.ident equalsString:folder.ident];
        }];
        if (match)
            [merged moveObject:match toIndex:itemIndex];
    }];

    return merged;
}

- (SubredditFolder *)mergedFolderForIdent:(NSString *)ident  local:(UserSubredditPreferences *)local remote:(UserSubredditPreferences *)remote basedOnChangeLog:(NSMutableArray *)changeLog;
{
    SubredditFolder *localFolder = [local.subredditFolders match:^BOOL(SubredditFolder *f) {
        return [f.ident equalsString:ident];
    }];
    
    SubredditFolder *remoteFolder = [remote.subredditFolders match:^BOOL(SubredditFolder *f) {
        return [f.ident equalsString:ident];
    }];
    
    // Skip the merge if this folder is only on one copy
    if (localFolder && !remoteFolder)
        return localFolder;
    
    if (remoteFolder && !localFolder)
        return remoteFolder;

    return [self mergedFolder:localFolder withFolder:remoteFolder basedOnChangeLog:changeLog];
}

- (SubredditFolder *)mergedFolder:(SubredditFolder *)leftFolder withFolder:(SubredditFolder *)rightFolder  basedOnChangeLog:(NSMutableArray *)changeLog;
{
    if ([leftFolder.subreddits count] == 0)
        return rightFolder;
    
    if ([rightFolder.subreddits count] == 0)
        return leftFolder;
    
    ModifyingParty lastModifedBy = [self lastModifiedByForFolder:leftFolder basedOnChangeLog:changeLog];
    // this will handle things like renaming
    SubredditFolder *mergedFolder = (lastModifedBy == ModifyingPartyLocal) ? leftFolder : rightFolder;
    
    NSUInteger step = 0;
    NSUInteger maxSteps = MAX(leftFolder.subreddits.count, rightFolder.subreddits.count) - 1;
    NSMutableArray *mergedSubreddits = [NSMutableArray array];
    
    BSELF(GroupSyncHandler);
    while (step <= maxSteps)
    {
        Subreddit *left = [leftFolder.subreddits safeObjectAtIndex:step];
        Subreddit *right = [rightFolder.subreddits safeObjectAtIndex:step];
        
        BOOL shouldAddLeft = left != nil && ![blockSelf shouldRemoveSubreddit:left fromFolder:leftFolder basedOnChangeLog:changeLog] && ![blockSelf subredditList:mergedSubreddits containsSubredditWithUrl:left.url];
        if (shouldAddLeft)
            [mergedSubreddits addObject:left];

        BOOL shouldAddRight = right != nil && ![blockSelf shouldRemoveSubreddit:right fromFolder:rightFolder basedOnChangeLog:changeLog] && ![blockSelf subredditList:mergedSubreddits containsSubredditWithUrl:right.url];
        if (shouldAddRight)
            [mergedSubreddits addObject:right];
        
        step++;
    }

    ModifyingParty lastOrderModifier = [self lastReorderActionByBasedOnChangeLog:changeLog];
    NSMutableArray *orderLookup = (lastOrderModifier == ModifyingPartyLocal) ? leftFolder.subreddits : rightFolder.subreddits;
    [orderLookup eachWithIndex:^(Subreddit *subreddit, NSUInteger itemIndex) {
        Subreddit *match = [mergedSubreddits match:^BOOL(Subreddit *mSubreddit) {
            return [mSubreddit.url equalsString:subreddit.url];
        }];
        if (match)
            [mergedSubreddits moveObject:match toIndex:itemIndex];
    }];
    
    mergedFolder.subreddits = mergedSubreddits;
    return mergedFolder;
}

- (id)mergeChangeFromLocalObject:(id)localObject remoteObject:(id)remoteObject;
{
    UserSubredditPreferences *local = [[SessionManager manager] subredditPrefs];
    UserSubredditPreferences *remote = [UserSubredditPreferences subredditPreferencesFromRawDefaultsData:(NSData *)remoteObject];
    
    NSMutableArray *mergedChangeLog = [self mergedChangeLogWithLocal:local remote:remote];
    NSMutableArray *mergedSubredditFolders = [self mergedSubfolderListWithLocal:local remote:remote basedOnChangeLog:mergedChangeLog];

    BSELF(GroupSyncHandler);
    
    //iterate through each folder and merge the subreddits
    mergedSubredditFolders = [NSMutableArray arrayWithArray:[mergedSubredditFolders map:^id(SubredditFolder *mFolder) {
        return [blockSelf mergedFolderForIdent:mFolder.ident local:local remote:remote basedOnChangeLog:mergedChangeLog];
    }]];
        
    SubredditFolder *m_manuallySubscribedFolder = [blockSelf mergedFolder:local.i_manuallySubscribedFolder withFolder:remote.i_manuallySubscribedFolder basedOnChangeLog:mergedChangeLog];
    SubredditFolder *m_manuallyUnsubscribedFolder = [blockSelf mergedFolder:local.i_manuallyUnsubscribedFolder withFolder:remote.i_manuallyUnsubscribedFolder basedOnChangeLog:mergedChangeLog];
    
    NSDate *m_lastSyncedDate = [NSDate date];
    NSDate *m_lastModificationDate = [NSDate date];
    
    UserSubredditPreferences *merged = local;
    [mergedChangeLog reduceToLast:kChangeLogTruncateLimit];
    
    merged.changeLog = mergedChangeLog;
    merged.subredditFolders = mergedSubredditFolders;
    merged.i_manuallySubscribedFolder = m_manuallySubscribedFolder;
    merged.i_manuallyUnsubscribedFolder = m_manuallyUnsubscribedFolder;
    merged.lastSyncedDate = m_lastSyncedDate;
    merged.lastModifiedDate = m_lastModificationDate;
    
    NSData *mergedArchive = [UserSubredditPreferences rawDefaultsDataForSubredditPreferences:merged];

    return mergedArchive;
}

- (void)finishedProcessingRemoteMerge;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SessionManager manager] switchUserSubredditPreferencesToAuthenticatedUser];
        
        UIViewController *rController = [[NavigationManager shared].postsNavigation.viewControllers match:^BOOL(UIViewController *controller) {
            return [controller isKindOfClass:[RedditsViewController class]];
        }];
        [rController performSelector:@selector(animateNodeChanges)];
    });
}

@end
