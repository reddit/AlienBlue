//
//  SessionManager.h
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserSubredditPreferences.h"
#import "TemplatePrefs.h"

@interface SessionManager : NSObject
@property (strong, readonly) UserSubredditPreferences *subredditPrefs;
@property (strong, readonly) TemplatePrefs *sharedTemplatePrefs;
@property (strong) NSDate *sessionStart;
- (void)switchUserSubredditPreferencesToAuthenticatedUser;
- (void)resetGroups;

+ (SessionManager *)manager;
@end
