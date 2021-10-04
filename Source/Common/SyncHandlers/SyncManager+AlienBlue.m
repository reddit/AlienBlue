//
//  SyncManager+AlienBlue.m
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SyncManager+AlienBlue.h"
#import "VisitedLinksSyncHandler.h"
#import "GroupSyncHandler.h"
#import "TemplatesSyncHandler.h"

@implementation SyncManager (AlienBlue)

SYNTHESIZE_ASSOCIATED_STRONG(VisitedLinksSyncHandler, visitedSyncHandler, VisitedSyncHandler);

- (void)addAlienBlueSyncHandlers;
{
    self.visitedSyncHandler = [VisitedLinksSyncHandler new];
    [self addSyncHandler:self.visitedSyncHandler];
    
    [self addSyncHandler:[GroupSyncHandler new]];
    [self addSyncHandler:[TemplatesSyncHandler new]];
}

@end
