//
//  VisitedLinksSyncHandler.m
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "VisitedLinksSyncHandler.h"
#import "NavigationManager.h"
#import "NSArray+BlocksKit.h"
#import "PostsViewController.h"

@interface VisitedLinksSyncHandler();
@property (strong) NSString *lastSyncedPostName;
@end

@implementation VisitedLinksSyncHandler

- (NSString *)keyToMonitor;
{
    return kABSettingKeyVisitedList;
}

- (BOOL)shouldSendToCloudOnUserDefaultsChange;
{
    NSArray *visitedList = [[NSUserDefaults standardUserDefaults] objectForKey:self.keyToMonitor];

    if (!visitedList || [visitedList count] == 0)
    {
        return NO;
    }

    if (self.lastSyncedPostName && [[visitedList first] equalsString:self.lastSyncedPostName])
    {
        return NO;
    }
    
    return YES;
}

- (void)finishedSendingToCloudAfterUserDefaultsChange;
{
    NSArray *visitedList = [[NSUserDefaults standardUserDefaults] objectForKey:self.keyToMonitor];
    if (visitedList && [visitedList count] > 0)
    {
        self.lastSyncedPostName = [visitedList first];
    }
    
//    self.allowSyncToCloud = NO;
}

- (BOOL)requiresSyncing:(id)localObject remoteObject:(id)remoteObject;
{
    SYNC_HANDLER_REQUIRE_SYNC_CLASS_CHECKS;
    
    NSMutableArray *alphabeticallySortedLocal = [NSMutableArray array];
    [alphabeticallySortedLocal addUniqueStringObjectsFromArray:localObject];
    [alphabeticallySortedLocal sortDescending];

    NSMutableArray *alphabeticallySortedRemote = [NSMutableArray array];
    [alphabeticallySortedRemote addUniqueStringObjectsFromArray:remoteObject];
    [alphabeticallySortedRemote sortDescending];
    
//    DLog(@"remote: %d local: %d", alphabeticallySortedRemote.count, alphabeticallySortedLocal.count);
    
    if (alphabeticallySortedLocal.count > 15 && [alphabeticallySortedRemote count] < [alphabeticallySortedLocal count] - 3)
    {
//        DLog(@"skipping sync to avoid recursion")
        // backward compatibilty with pre-patch ipad version
        return NO;
    }
    
    BOOL requiresSync = ![[(NSArray *)alphabeticallySortedLocal limitToLength:50] matchesStringContentsInArray:[(NSArray *)alphabeticallySortedRemote limitToLength:50]];
    
//    if (requiresSync)
//    {
//        DLog(@"need to sync remote changes");
//    }
//    else
//    {
//        DLog(@"nope, nothing changed remotely");
//    }
    
    return requiresSync;
}

- (id)mergeChangeFromLocalObject:(id)localObject remoteObject:(id)remoteObject;
{
    SYNC_HANDLER_MERGE_DEFAULT_TO_NONNIL_OBJECT;
  
//    DLog(@"merging...");
    
    NSArray *localVisited = (NSArray *)localObject;
    NSArray *remoteVisited = (NSArray *)remoteObject;

    NSMutableArray *merged = [NSMutableArray array];

    NSUInteger step = 0;
    NSUInteger maxSteps = MAX(localVisited.count, remoteVisited.count) - 1;
    
    while (step <= maxSteps)
    {
        NSString *left = [localVisited safeObjectAtIndex:step];
        NSString *right = [remoteVisited safeObjectAtIndex:step];
        
        BOOL shouldAddLeft = left != nil && [left isKindOfClass:[NSString class]];
        if (shouldAddLeft)
            [merged addUniqueStringObject:left];
        
        BOOL shouldAddRight = right != nil  && [right isKindOfClass:[NSString class]];
        if (shouldAddRight)
            [merged addUniqueStringObject:right];
        
        step++;
    }
    
    NSArray *cropped = [merged limitToLength:500];
    
//    NSArray *localToMerge = [[localVisited limitToLength:100] select:^BOOL(id obj) {
//        return [obj isKindOfClass:[NSString class]];
//    }];
//    
//    NSArray *remoteToMerge = [[remoteVisited limitToLength:100] select:^BOOL(id obj) {
//        return [obj isKindOfClass:[NSString class]];
//    }];
//        
//    [merged addUniqueStringObjectsFromArray:localToMerge];
//    [merged addUniqueStringObjectsFromArray:remoteToMerge];
//    [merged sortAlphabetically];

    return cropped;
}

- (void)finishedProcessingRemoteMerge;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *postsViewController = [[NavigationManager shared].postsNavigation.viewControllers match:^BOOL(UIViewController *controller) {
            return [controller isKindOfClass:[PostsViewController class]];
        }];
        [postsViewController performSelector:@selector(respondToStyleChange)];
    });
}

@end
