//
//  ThumbManager+HitProtection.h
//  AlienBlue
//
//  Created by J M on 28/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "ThumbManager.h"

@interface ThumbManager (HitProtection)
@property (strong) NSCache *requestCache; // tracks only the request urls already in progress
- (void)initialiseHitProtection;

- (void)hitProtectionRequestBeganForKey:(NSString *)key;
- (void)hitProtectionRequestCompletedForKey:(NSString *)key;
- (void)hitProtectionRequestFailedForKey:(NSString *)key;

- (BOOL)hitProtectionAllowRequestForKey:(NSString *)key;
@end

