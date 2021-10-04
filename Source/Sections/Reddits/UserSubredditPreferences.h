//
//  UserSubredditPreferences.h
//  AlienBlue
//
//  Created by J M on 8/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubredditFolder.h"
#import "Subreddit.h"
#import "FolderChangeTrackRecord.h"

#define kChangeLogTruncateLimit 50
#define kSubredditCloudSyncThreshold 350

@interface UserSubredditPreferences : NSObject <NSCoding>

@property (strong) NSMutableArray *subredditFolders;
@property (strong) NSString *username;

@property (strong) NSDate *lastModifiedDate;
@property (strong) NSDate *lastSyncedDate;

@property (strong) NSMutableArray *changeLog;

@property (strong) SubredditFolder *i_manuallySubscribedFolder;
@property (strong) SubredditFolder *i_manuallyUnsubscribedFolder;

@property (readonly) NSUInteger totalSubredditCount;

+ (NSString *)prefKey;

+ (UserSubredditPreferences *)subredditPreferencesForAuthenticatedUser;

+ (SubredditFolder *)defaultSubredditsFolder;

- (SubredditFolder *)folderForSubscribedReddits;
- (SubredditFolder *)folderForCasualReddits;

- (SubredditFolder *)folderForMyRedditsSection;
- (SubredditFolder *)folderForDiscoverSection;

- (void)addSubreddit:(Subreddit *)subreddit toFolder:(SubredditFolder *)folder;
- (void)addSubreddit:(Subreddit *)subreddit toFolder:(SubredditFolder *)folder atIndex:(NSUInteger)ind;
- (void)removeSubreddit:(Subreddit *)subreddit fromFolder:(SubredditFolder *)folder;

- (SubredditFolder *)createSubredditFolderWithTitle:(NSString *)title;

- (void)addSubredditFolder:(SubredditFolder *)folder atIndex:(NSUInteger)folderIndex;
- (void)removeSubredditFolder:(SubredditFolder *)folder;
- (void)renameSubredditFolder:(SubredditFolder *)folder toTitle:(NSString *)toTitle;

- (void)removeSubredditFromAllFolders:(Subreddit *)subreddit;

- (void)syncServerRetrievedSubredditsToSubscribed:(NSArray *)serverSubreddits;

- (void)sortAllFolders;

- (SubredditFolder *)folderContainingSubreddit:(Subreddit *)subreddit;
- (NSArray *)foldersContainingSubreddit:(Subreddit *)subreddit;
- (SubredditFolder *)folderMatchingIdent:(NSString *)folderIdent;

- (void)save;
- (void)recommendSyncToCloud;

- (BOOL)shouldSyncToCloud;
- (void)didSyncToCloud;

// change tracking
- (void)recordChange:(FolderChangeType)changeType subreddit:(Subreddit *)subreddit folder:(SubredditFolder *)folder;
- (void)recordReorderOfSubreddit:(Subreddit *)subreddit folder:(SubredditFolder *)folder rowIndex:(NSUInteger)rowIndex;

+ (UserSubredditPreferences *)subredditPreferencesFromRawDefaultsData:(NSData *)rawData;
+ (NSData *)rawDefaultsDataForSubredditPreferences:(UserSubredditPreferences *)srPrefs;

- (void)checkSyncThreshold;
@end
