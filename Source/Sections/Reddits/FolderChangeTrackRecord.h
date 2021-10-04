//
//  FolderChangeTrackRecord.h
//  AlienBlue
//
//  Created by J M on 19/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubredditFolder.h"
#import "Subreddit.h"

typedef enum {
    FolderChangeAddSubreddit = 0,
    FolderChangeRemoveSubreddit,
    FolderChangeReorderSubreddit,
    FolderChangeAddFolder,
    FolderChangeRemoveFolder,
    FolderChangeReorderFolder,
    FolderChangeRenameFolder
} FolderChangeType;

@interface FolderChangeTrackRecord : NSObject <NSCoding>
@property (strong) NSDate *timestamp;
@property (strong) NSString *subredditUrl;
@property (strong) NSString *folderIdent;
@property NSUInteger orderedToRow;
@property FolderChangeType changeType;

+ (FolderChangeTrackRecord *)recordForChangeType:(FolderChangeType)changeType affectingSubreddit:(Subreddit *)subreddit inFolder:(SubredditFolder *)folder;
@end
