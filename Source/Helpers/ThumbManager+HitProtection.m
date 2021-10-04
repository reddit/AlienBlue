//
//  ThumbManager+HitProtection.m
//  AlienBlue
//
//  Created by J M on 28/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "ThumbManager+HitProtection.h"

#pragma mark - Model for Thumb Requests

typedef enum {
    ThumbRequestInProgress = 0,
    ThumbRequestComplete = 1,
    ThumbRequestFailed = 2,
    ThumbRequestUnspecified = 3
} ThumbRequestStatus;

@interface ThumbRequest : NSObject
@property (strong) NSString *key;
@property ThumbRequestStatus status;
@end

@implementation ThumbRequest
@end

#pragma mark - Hit Protection

@implementation ThumbManager (HitProtection)

SYNTHESIZE_ASSOCIATED_STRONG(NSCache, requestCache, RequestCache);

- (void)initialiseHitProtection;
{
    self.requestCache = [[NSCache alloc] init];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(memoryWarningReceived) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)memoryWarningReceived;
{
    [self.requestCache removeAllObjects];
}

- (ThumbRequestStatus)statusForKey:(NSString *)key;
{
    ThumbRequest *request = [self.requestCache objectForKey:key];
    if (request)
        return request.status;
    else
        return ThumbRequestUnspecified;
}

- (void)setStatus:(ThumbRequestStatus)status forKey:(NSString *)key;
{
    ThumbRequest *request = [self.requestCache objectForKey:key];
    if (!request)
    {
        request = [[ThumbRequest alloc] init];
    }

    request.key = key;
    request.status = status;

    [self.requestCache setObject:request forKey:key];
}

- (void)hitProtectionRequestBeganForKey:(NSString *)key;
{
    [self setStatus:ThumbRequestInProgress forKey:key];    
}

- (void)hitProtectionRequestCompletedForKey:(NSString *)key;
{
    [self setStatus:ThumbRequestComplete forKey:key];
}

- (void)hitProtectionRequestFailedForKey:(NSString *)key;
{
    [self setStatus:ThumbRequestFailed forKey:key];
}

- (BOOL)hitProtectionAllowRequestForKey:(NSString *)key;
{
    BOOL allow = ([self statusForKey:key] != ThumbRequestInProgress);
    return allow;
}

@end
