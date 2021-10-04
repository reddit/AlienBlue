//
//  SyncManager+AlienBlue.h
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SyncManager.h"
#import "VisitedLinksSyncHandler.h"

@interface SyncManager (AlienBlue)

@property (strong) VisitedLinksSyncHandler *visitedSyncHandler;

- (void)addAlienBlueSyncHandlers;

@end
