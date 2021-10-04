//
//  SessionManager.m
//  AlienBlue
//
//  Created by J M on 18/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SessionManager.h"
#import "SyncManager+AlienBlue.h"
#import "UIAlertView+BlocksKit.h"
#import "NavigationManager.h"
#import "TemplatePrefs.h"

@interface SessionManager()
@property (strong) UserSubredditPreferences *subredditPrefs;
@property (strong) TemplatePrefs *templatePrefs;
- (void)switchUserSubredditPreferencesToAuthenticatedUser;
@end

@implementation SessionManager

+ (SessionManager *)manager;
{
    JM_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    if ((self = [super init]))
    {
        [self switchUserSubredditPreferencesToAuthenticatedUser];
    }
    return self;
}

- (void)switchUserSubredditPreferencesToAuthenticatedUser;
{
    self.subredditPrefs = [UserSubredditPreferences subredditPreferencesForAuthenticatedUser];
}

- (void)resetGroups;
{
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Reset Groups"];
    alert.message = @"This will also reset your groups from iCloud. Are you sure you want to proceed?";
    [alert bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [alert bk_addButtonWithTitle:@"Reset" handler:^{
        DLog(@"resetting groups");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[UserSubredditPreferences prefKey]];
        [[SyncManager manager] removeCloudObjectForKey:[UserSubredditPreferences prefKey]];
        [[NavigationManager shared] refreshUserSubreddits];
    }];
    [alert show];
}

- (TemplatePrefs *)sharedTemplatePrefs;
{
  // lazy load this as most users wont need it
  if (!self.templatePrefs)
  {
    self.templatePrefs = [TemplatePrefs templatePreferences];
  }
  return self.templatePrefs;
}

@end
