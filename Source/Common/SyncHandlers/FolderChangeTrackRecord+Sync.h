//
//  FolderChangeTrackRecord+Sync.h
//  AlienBlue
//
//  Created by J M on 19/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "FolderChangeTrackRecord.h"

typedef enum {
    ModifyingPartyLocal = 0,
    ModifyingPartyRemote,
} ModifyingParty;

@interface FolderChangeTrackRecord (Sync)
@property NSUInteger modifiedBy;
@end
