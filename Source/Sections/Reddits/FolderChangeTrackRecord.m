//
//  FolderChangeTrackRecord.m
//  AlienBlue
//
//  Created by J M on 19/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "FolderChangeTrackRecord.h"

@implementation FolderChangeTrackRecord

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
    [aCoder encodeObject:self.subredditUrl forKey:@"subredditUrl"];
    [aCoder encodeObject:self.folderIdent forKey:@"folderIdent"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.changeType] forKey:@"changeType"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.orderedToRow] forKey:@"orderedToRow"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    FolderChangeTrackRecord *record = nil;
    
    NSDate *timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
    NSString *subredditUrl = [aDecoder decodeObjectForKey:@"subredditUrl"];
    NSString *folderIdent = [aDecoder decodeObjectForKey:@"folderIdent"];
    NSNumber *changeType = [aDecoder decodeObjectForKey:@"changeType"];
    NSNumber *orderedToRow = [aDecoder decodeObjectForKey:@"orderedToRow"];
    
    // subredditUrl can be nil for these records
    
    if (timestamp && folderIdent && changeType)
    {
        record = [[FolderChangeTrackRecord alloc] init];
        record.timestamp = timestamp;
        record.subredditUrl = subredditUrl;
        record.folderIdent = folderIdent;
        record.changeType = [changeType integerValue];
        if (orderedToRow)
        {
            record.orderedToRow = [orderedToRow unsignedIntegerValue];
        }
    }    
    return record;
}

+ (FolderChangeTrackRecord *)recordForChangeType:(FolderChangeType)changeType affectingSubreddit:(Subreddit *)subreddit inFolder:(SubredditFolder *)folder;
{
    FolderChangeTrackRecord *record = [[FolderChangeTrackRecord alloc] init];
    record.timestamp = [NSDate date];
    record.changeType = changeType;
    record.subredditUrl = subreddit.url;
    record.folderIdent = folder.ident;
    return record;
}

@end
