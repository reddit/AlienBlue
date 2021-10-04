//
//  DiscoveryAddController_iPad.m
//  AlienBlue
//
//  Created by J M on 17/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "DiscoveryAddController_iPad.h"
#import "SessionManager.h"
#import "NavigationManager_iPad.h"

@implementation DiscoveryAddController_iPad

- (CGSize)recommendedViewSize;
{
    UserSubredditPreferences *subredditPrefs = [[SessionManager manager] subredditPrefs];
    CGFloat height = subredditPrefs.subredditFolders.count * 42;

    height += 150.; // spacer
    
    if (self.shouldShowFrontPageOption)
    {
        height += 42.;
    }

    if (!self.excludeDontShowOption)
    {
        height += 50.; // "don't ask again" option
    }
    
    BOOL showRemoveAllOption = [subredditPrefs folderContainingSubreddit:self.subreddit] != nil;
    if (!self.excludeRemoveOption && showRemoveAllOption)
    {
        height += 50.;
    }
    
    
    return CGSizeMake(270., height);
}

- (CGSize)contentSizeForViewInPopover;
{
    return [self recommendedViewSize];
}

- (CGSize)preferredContentSize;
{
  return self.contentSizeForViewInPopover;
}

- (void)toggleSelectionForFolder:(SubredditFolder *)folder;
{
    [super toggleSelectionForFolder:folder];
    self.ab_contentSizeForViewInPopover =  [self recommendedViewSize];
}

- (void)dismissAddController;
{
    [[NavigationManager_iPad shared] dismissPopoverIfNecessary];
}


@end
