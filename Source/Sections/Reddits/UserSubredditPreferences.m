//
//  UserSubredditPreferences.m
//  AlienBlue
//
//  Created by J M on 8/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "UserSubredditPreferences.h"
#import "NSArray+BlocksKit.h"
#import "RedditAPI.h"
#import "Subreddit+API.h"
#import "NSData+Zip.h"
#import "SyncManager.h"
#import "UIAlertView+BlocksKit.h"
#import "NavigationManager.h"
#import "RedditAPI+Account.h"
#import "SubredditManager.h"

// IMPORTANT: Don't change these - otherwise it risks breaking previous installations
// as the folder title was used as the identifier, instead re-format for branding in
// subreddit folder node until the shift to using the multis API
#define kSubscribedSubredditFolderTitle @"Subscribed Reddits"
#define kCasualSubredditFolderTitle @"Casual Reddits"

@interface UserSubredditPreferences()

@property BOOL i_shouldSyncToCloud;

// used only to track the collapse state of these folders
@property (strong) SubredditFolder *i_myRedditsSectionFolder;
@property (strong) SubredditFolder *i_discoverSectionFolder;

@property (assign) UserSubredditPreferences *i_sharedSubredditPreferences;

- (void)importLegacyCasualSubreddits;
@end

@implementation UserSubredditPreferences

+ (NSString *)prefKey;
{
    return [NSString stringWithFormat:@"subreddit_preferences_%@", [[[RedditAPI shared] authenticatedUser] lowercaseString]];
}

+ (UserSubredditPreferences *)subredditPreferencesFromRawDefaultsData:(NSData *)rawData;
{
    NSData *stateArchive = [rawData zlibInflate];
    UserSubredditPreferences *srPrefs = [NSKeyedUnarchiver unarchiveObjectWithData:stateArchive];
    return  srPrefs;
}

+ (NSData *)rawDefaultsDataForSubredditPreferences:(UserSubredditPreferences *)srPrefs;
{
	NSData *stateArchive = [NSKeyedArchiver archivedDataWithRootObject:srPrefs];
	NSData *zippedArchive = [stateArchive zlibDeflate];
//    DLog(@"subreddits : (%d) - compressed archive size  : (%d) - bytes per subreddit: (%d)", srPrefs.totalSubredditCount, zippedArchive.length, zippedArchive.length / srPrefs.totalSubredditCount);
    
//	NSData *verifyArchive = [NSData dataByDecompressingData:zippedArchive];
//    DLog(@"verify archive size     : %d", verifyArchive.length);
//    UserSubredditPreferences *verifyPrefs = [UserSubredditPreferences subredditPreferencesFromRawDefaultsData:zippedArchive];
//    DLog(@"uname: %@", verifyPrefs.username);
    return zippedArchive;
}

+ (UserSubredditPreferences *)subredditPreferencesForAuthenticatedUser;
{
    NSData *rawData = [[NSUserDefaults standardUserDefaults] objectForKey:[UserSubredditPreferences prefKey]];
    UserSubredditPreferences *srPrefs = [UserSubredditPreferences subredditPreferencesFromRawDefaultsData:rawData];
    
    if (!srPrefs)
    {
        // try cloud storage
        NSData *cloudData = [[SyncManager manager] cloudObjectForKey:[UserSubredditPreferences prefKey]];
        if (cloudData)
        {
            srPrefs = [UserSubredditPreferences subredditPreferencesFromRawDefaultsData:cloudData];
        }
    }
    
    if (!srPrefs)
    {
        srPrefs = [[UserSubredditPreferences alloc] init];
        srPrefs.username = [[RedditAPI shared] authenticatedUser];
        
        srPrefs.changeLog = [NSMutableArray array];
        
        srPrefs.i_manuallySubscribedFolder = [SubredditFolder folderWithTitle:@"i_Manually_Subscribed"];
        srPrefs.i_manuallyUnsubscribedFolder = [SubredditFolder folderWithTitle:@"i_Manually_Unsubscribed"];
        srPrefs.i_myRedditsSectionFolder = [SubredditFolder folderWithTitle:@"i_MyReddits_Section"];
        srPrefs.i_discoverSectionFolder = [SubredditFolder folderWithTitle:@"i_Discover_Section"];
        
        SubredditFolder *subscribedFolder = [SubredditFolder folderWithTitle:kSubscribedSubredditFolderTitle];
        SubredditFolder *casualFolder = [SubredditFolder folderWithTitle:kCasualSubredditFolderTitle];
        
        srPrefs.subredditFolders = [NSMutableArray array];
        [srPrefs.subredditFolders addObject:subscribedFolder];
        [srPrefs.subredditFolders addObject:casualFolder];
        
        [srPrefs importLegacyCasualSubreddits];
        
        [srPrefs save];
    }
    
    return srPrefs;
};

- (void)importLegacyCasualSubreddits;
{
    BSELF(UserSubredditPreferences);
    
    NSArray *legacyCasualList = [[NSUserDefaults standardUserDefaults] objectForKey:@"casualList"];
    if (!legacyCasualList || [legacyCasualList count] == 0)
        return;

    NSArray *casualSubreddits = [legacyCasualList map:^id(NSString *casualURL) {
        return [Subreddit subredditWithUrl:casualURL name:@""];
    }];
    
    [casualSubreddits each:^(Subreddit *subreddit) {
        [blockSelf.folderForCasualReddits addSubreddit:subreddit];
    }];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"casualList"];
}

+ (SubredditFolder *)defaultSubredditsFolder;
{
    NSMutableArray *defaultSubreddits = [NSMutableArray array];

    NSArray *defaultSubredditNames = [[SubredditManager sharedSubredditManager] defaultSubreddits];
    [defaultSubredditNames bk_each:^(NSString *subredditName) {
      NSString *subredditUrl = [NSString stringWithFormat:@"/r/%@", subredditName];
      [defaultSubreddits addObject:[Subreddit subredditWithUrl:subredditUrl name:@""]];
    }];
    
    SubredditFolder *folder = [SubredditFolder folderWithTitle:@"Default Subreddits"];
    [folder.subreddits addObjectsFromArray:defaultSubreddits];
    return folder;
}

- (SubredditFolder *)folderForMyRedditsSection;
{
    return self.i_myRedditsSectionFolder;
}

- (SubredditFolder *)folderForDiscoverSection;
{
    return self.i_discoverSectionFolder;
}

- (SubredditFolder *)folderMatchingIdent:(NSString *)folderIdent;
{
    return [self.subredditFolders match:^BOOL(SubredditFolder *folder) {
        return [folder.ident equalsString:folderIdent];
    }];
}

- (NSUInteger)totalSubredditCount;
{
    NSNumber *totalSubreddits = [self.subredditFolders reduce:[NSNumber numberWithInteger:0] withBlock:^id(NSNumber *total, SubredditFolder *obj) {
        NSUInteger numSubreddits = [obj.subreddits count];
        return [NSNumber numberWithUnsignedInteger:(total.integerValue + numSubreddits)];
    }];
    return totalSubreddits.integerValue;
}

- (void)save;
{
    self.lastModifiedDate = [NSDate date];
    
//    DLog(@"total subreddits : %d", [self totalSubredditCount]);
//    
    NSData *rawData = [UserSubredditPreferences rawDefaultsDataForSubredditPreferences:self];
    [[NSUserDefaults standardUserDefaults] setObject:rawData forKey:[UserSubredditPreferences prefKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)appendToChangeLog:(FolderChangeTrackRecord *)record;
{
    [self.changeLog addObject:record];
    [self.changeLog reduceToLast:kChangeLogTruncateLimit];    
}

- (void)recordReorderOfSubreddit:(Subreddit *)subreddit folder:(SubredditFolder *)folder rowIndex:(NSUInteger)rowIndex;
{
    BSELF(UserSubredditPreferences);
    if (subreddit == nil)
    {
        // record the position of all groups
        [self.subredditFolders eachWithIndex:^(SubredditFolder *folder, NSUInteger itemIndex) {
            FolderChangeTrackRecord *record = [FolderChangeTrackRecord recordForChangeType:FolderChangeReorderFolder affectingSubreddit:nil inFolder:folder];
            record.orderedToRow = itemIndex;
            [blockSelf appendToChangeLog:record];
        }];
    }
    else
    {
        FolderChangeTrackRecord *record = [FolderChangeTrackRecord recordForChangeType:FolderChangeReorderSubreddit affectingSubreddit:subreddit inFolder:folder];
        record.orderedToRow = rowIndex;
        [self appendToChangeLog:record];
    }
    
//    FolderChangeTrackRecord *record = [FolderChangeTrackRecord recordForChangeType:FolderChangeReorderSubreddit affectingSubreddit:subreddit inFolder:folder];
//    record.changeType = (subreddit == nil) ? FolderChangeReorderFolder : FolderChangeReorderSubreddit;
//    record.orderedToRow = rowIndex;
//    [self appendToChangeLog:record];
}

- (void)recordChange:(FolderChangeType)changeType subreddit:(Subreddit *)subreddit folder:(SubredditFolder *)folder;
{
    FolderChangeTrackRecord *record = [FolderChangeTrackRecord recordForChangeType:changeType affectingSubreddit:subreddit inFolder:folder];
    [self appendToChangeLog:record];
}

- (SubredditFolder *)folderForSubscribedReddits;
{
    SubredditFolder *match = [self.subredditFolders match:^BOOL(SubredditFolder *folder) {
        return [folder.title equalsString:kSubscribedSubredditFolderTitle];
    }];
    return match;
}

- (SubredditFolder *)folderForCasualReddits;
{
    SubredditFolder *match = [self.subredditFolders match:^BOOL(SubredditFolder *folder) {
        return [folder.title equalsString:kCasualSubredditFolderTitle];
    }];
    return match;
}

- (void)addSubreddit:(Subreddit *)subreddit toFolder:(SubredditFolder *)folder atIndex:(NSUInteger)ind;
{
    if (folder == self.folderForSubscribedReddits)
    {
//        subreddit.subscribed = YES;
        [self.i_manuallySubscribedFolder addSubreddit:subreddit];
        [self.i_manuallyUnsubscribedFolder removeSubreddit:subreddit];
    }
    
    [folder insertSubreddit:subreddit atIndex:ind];
    
    [self recordChange:FolderChangeAddSubreddit subreddit:subreddit folder:folder];
    
    [self save];    
}

- (void)addSubreddit:(Subreddit *)subreddit toFolder:(SubredditFolder *)folder;
{
    [self addSubreddit:subreddit toFolder:folder atIndex:folder.subreddits.count];
}

- (void)removeSubreddit:(Subreddit *)subreddit fromFolder:(SubredditFolder *)folder;
{
    if (folder == self.folderForSubscribedReddits)
    {
        [self.i_manuallySubscribedFolder removeSubreddit:subreddit];
        [self.i_manuallyUnsubscribedFolder addSubreddit:subreddit];
    }
    [folder removeSubreddit:subreddit];
    
    [self recordChange:FolderChangeRemoveSubreddit subreddit:subreddit folder:folder];
    [self save];
}

- (void)removeSubredditFromAllFolders:(Subreddit *)subreddit
{
    if ([self.folderForSubscribedReddits containsSubreddit:subreddit])
    {
        [Subreddit unsubscribeToSubredditWithUrl:subreddit.url];
        [self removeSubreddit:subreddit fromFolder:self.folderForSubscribedReddits];
        DLog(@"unsubscribing...");
    }
    
    [self.subredditFolders each:^(SubredditFolder *folder){
        [folder removeSubreddit:subreddit];
    }];
    
    [self save];
}

- (void)sortAllFolders;
{
    [self.subredditFolders each:^(SubredditFolder *folder){
      [folder sortAlphabetically];
    }];
    [self save];
}

- (NSArray *)foldersContainingSubreddit:(Subreddit *)subreddit;
{
    return [self.subredditFolders select:^BOOL(SubredditFolder *folder) {
        return [folder containsSubreddit:subreddit];
    }];
}

- (SubredditFolder *)folderContainingSubreddit:(Subreddit *)subreddit;
{
    return [self.subredditFolders match:^BOOL(SubredditFolder *folder) {
        return [folder containsSubreddit:subreddit];
    }];    
}

- (void)syncServerRetrievedSubredditsToSubscribed:(NSArray *)serverSubreddits;
{    
    BOOL needToSort = [self.folderForSubscribedReddits.subreddits count] == 0;
    
    BSELF(UserSubredditPreferences);
    [serverSubreddits each:^(Subreddit *serverSubreddit){

        // check to see if the new subreddit already exists in one of the
        // other folders and skip
        
//        BOOL alreadyInFolder = [blockSelf folderContainingSubreddit:serverSubreddit] != nil;
        
//        if (!alreadyInFolder && ![blockSelf.i_manuallyUnsubscribedFolder containsSubreddit:serverSubreddit])
        if (![blockSelf.i_manuallyUnsubscribedFolder containsSubreddit:serverSubreddit])
        {
//            serverSubreddit.subscribed = YES;
            [blockSelf.folderForSubscribedReddits addSubreddit:serverSubreddit];
        }
    }];
    
    [self.i_manuallySubscribedFolder.subreddits each:^(Subreddit *manuallySubscribedSubreddit) {
        [blockSelf.folderForSubscribedReddits addSubreddit:manuallySubscribedSubreddit];
    }];
    
    if (needToSort)
    {
        [self.folderForSubscribedReddits sortAlphabetically];
        [self recommendSyncToCloud];
    }
    
    [self save];
}

- (void)addSubredditFolder:(SubredditFolder *)folder atIndex:(NSUInteger)folderIndex;
{
    [self.subredditFolders insertObject:folder atIndex:folderIndex];
    
    [self recordChange:FolderChangeAddFolder subreddit:nil folder:folder];
    [self save];
}

- (SubredditFolder *)createSubredditFolderWithTitle:(NSString *)title;
{
    SubredditFolder *folder = [SubredditFolder folderWithTitle:title];
    [self addSubredditFolder:folder atIndex:0];
    [self recordReorderOfSubreddit:nil folder:folder rowIndex:0];
    return folder;
}

- (void)renameSubredditFolder:(SubredditFolder *)folder toTitle:(NSString *)toTitle;
{
    if (folder == self.folderForCasualReddits || folder == self.folderForSubscribedReddits)
    {
        DLog(@"attempted to rename subscribed or casual list... ignoring request");
        return;
    }

    folder.title = toTitle;
    [self recordChange:FolderChangeRenameFolder subreddit:nil folder:folder];
    [self save];
}

- (void)removeSubredditFolder:(SubredditFolder *)folder;
{
    if (folder == self.folderForCasualReddits || folder == self.folderForSubscribedReddits)
    {
        DLog(@"attempted to delete subscribed or casual list... ignoring request");
        return;
    }
    [self.subredditFolders removeObject:folder];

    [self recordChange:FolderChangeRemoveFolder subreddit:nil folder:folder];
    [self save];
}

//- (NSUInteger)numberOfSubscribedSubredditsInOtherFolders;
//{
//    NSUInteger numSubscribed = 0;
//    BSELF(UserSubredditPreferences);
//    NSArray *foldersToConsider = [self.subredditFolders reject:^BOOL(SubredditFolder *folder) {
//        return folder == blockSelf.folderForCasualReddits || folder == blockSelf.folderForSubscribedReddits;
//    }];
//    [foldersToConsider each:^(SubredditFolder *folder) {
//        NSArray *matching = [folder.subreddits select:^BOOL(Subreddit *subreddit) {
//            return [blockSelf.i_manuallySubscribedFolder containsSubreddit:subreddit];
//        }];
//    }];
//}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.changeLog forKey:@"changeLog"];
    [aCoder encodeObject:self.subredditFolders forKey:@"subredditFolders"];
    [aCoder encodeObject:self.i_manuallySubscribedFolder forKey:@"manuallySubscribedFolder"];
    [aCoder encodeObject:self.i_manuallyUnsubscribedFolder forKey:@"manuallyUnsubscribedFolder"];
    [aCoder encodeObject:self.i_myRedditsSectionFolder forKey:@"myRedditsSectionFolder"];
    [aCoder encodeObject:self.i_discoverSectionFolder forKey:@"discoverSectionFolder"];
    [aCoder encodeObject:self.lastModifiedDate forKey:@"lastModifiedDate"];
    [aCoder encodeObject:self.lastSyncedDate forKey:@"lastSyncedDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    UserSubredditPreferences *subredditPrefs = nil;
    NSString *username = [aDecoder decodeObjectForKey:@"username"];
    NSArray *changeLog = [aDecoder decodeObjectForKey:@"changeLog"];
    NSArray *subredditFolders = [aDecoder decodeObjectForKey:@"subredditFolders"];
    SubredditFolder *manuallySubscribedFolder = [aDecoder decodeObjectForKey:@"manuallySubscribedFolder"];
    SubredditFolder *manuallyUnsubscribedFolder = [aDecoder decodeObjectForKey:@"manuallyUnsubscribedFolder"];
    SubredditFolder *myRedditsSectionFolder = [aDecoder decodeObjectForKey:@"myRedditsSectionFolder"];
    SubredditFolder *discoverSectionFolder = [aDecoder decodeObjectForKey:@"discoverSectionFolder"];
    NSDate *lastModifiedDate = [aDecoder decodeObjectForKey:@"lastModifiedDate"];
    NSDate *lastSyncedDate = [aDecoder decodeObjectForKey:@"lastSyncedDate"];
    
    if (username && subredditFolders && manuallySubscribedFolder && manuallyUnsubscribedFolder && myRedditsSectionFolder && discoverSectionFolder)
    {
        subredditPrefs = [[UserSubredditPreferences alloc] init];
        subredditPrefs.username = username;
        subredditPrefs.changeLog = [NSMutableArray arrayWithArray:changeLog];
        subredditPrefs.subredditFolders = [NSMutableArray arrayWithArray:subredditFolders];
        subredditPrefs.i_manuallySubscribedFolder = manuallySubscribedFolder;
        subredditPrefs.i_manuallyUnsubscribedFolder = manuallyUnsubscribedFolder;
        subredditPrefs.i_myRedditsSectionFolder = myRedditsSectionFolder;
        subredditPrefs.i_discoverSectionFolder = discoverSectionFolder;
        subredditPrefs.lastModifiedDate = lastModifiedDate;
        subredditPrefs.lastSyncedDate = lastSyncedDate;
    }
    
    return subredditPrefs;
}

- (void)recommendSyncToCloud;
{
    self.i_shouldSyncToCloud = YES;
    [self save];
}

- (BOOL)shouldSyncToCloud;
{
    if (self.totalSubredditCount > kSubredditCloudSyncThreshold)
        return NO;
    
    return self.i_shouldSyncToCloud;
}

- (void)didSyncToCloud;
{
    self.i_shouldSyncToCloud = NO;
}

- (void)checkSyncThreshold;
{
    if (self.totalSubredditCount == kSubredditCloudSyncThreshold)
    {
        NSString *message = @"If you add any more subreddits, you may lose the ability to sync your groups via iCloud.";
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"iCloud Sync Warning" message:message];
        [alert bk_addButtonWithTitle:@"OK" handler:nil];
        [alert show];
    }
}


@end
