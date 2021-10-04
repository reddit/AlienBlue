//
//  RedditsViewController+Announcement.m
//  AlienBlue
//
//  Created by J M on 13/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsViewController+Announcement.h"
#import "NBaseOptionCell.h"
#import "UIImage+Resize.h"
#import "NavigationManager.h"
#import "RedditAPI.h"
#import "RedditAPI+Announcements.h"
#import "Post.h"
#import "NSString+HTML.h"

@interface RedditsViewController (Announcement_)
@property (strong) NSDictionary *announcementDictionary;
@property BOOL announcementNodesAreAdded;
- (void)markAnnouncementsAsRead;
@end;

@implementation RedditsViewController (Announcement)

SYNTHESIZE_ASSOCIATED_STRONG(NSDictionary, announcementDictionary, AnnouncementDictionary)
SYNTHESIZE_ASSOCIATED_BOOL(announcementNodesAreAdded, AnnouncementNodesAreAdded);

- (void)showAnnouncement;
{
    [[NavigationManager shared] showCommentsForPost:[Post postFromDictionary:self.announcementDictionary] contextId:nil fromController:self];
}

- (void)addAnnouncementSection;
{
    if (!self.announcementDictionary)
        return;
    
    BSELF(RedditsViewController);
    [self addSectionTitleNodeWithTitle:@"News & Updates"];
    OptionNode *announcementNode = [[OptionNode alloc] init];
    announcementNode.titleColor = [UIColor colorForHighlightedOptions];
    announcementNode.bold = YES;
  
    NSString *title = [self.announcementDictionary valueForKey:@"title"];
    announcementNode.title = [title stringByDecodingHTMLEntities];
    announcementNode.onSelect = ^{
        [blockSelf showAnnouncement];
    };
    
    UIImage *closeIcon = [UIImage skinImageNamed:@"icons/close-button-rounded" withColor:[UIColor colorForAccessoryButtons]];
    announcementNode.secondaryIcon = closeIcon;
    announcementNode.secondaryAction = ^{
        [blockSelf markAnnouncementsAsRead];
    };
    
    [self addNode:announcementNode];
    [self addSpacerNode];
  
    self.announcementNodesAreAdded = YES;
}

- (void)apiAnnouncementCheckResponse:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary * latestAnnouncement = (NSDictionary *) sender;
    if (latestAnnouncement)
    {
        if (![[latestAnnouncement valueForKey:@"name"] isEqualToString:[prefs valueForKey:kABSettingKeyLastViewedAnnouncementIdent]])
        {
            self.announcementDictionary = [[NSMutableDictionary alloc] initWithDictionary:latestAnnouncement];
            [self updateNodesWithAnnouncement];
        }
        else
        {
            self.announcementDictionary = nil;            
        }
    }
}

- (void)updateNodesWithAnnouncement;
{
  // need to manually offset the table so that it doesn't
  // cause the rows beneath to shift when the user is about
  // to select a subreddit
  
  if (self.tableView.contentOffset.y < 10 || self.announcementNodesAreAdded)
  {
    [self animateNodeChanges];
    return;
  }
  
  if (!self.tableView.isDragging && !self.tableView.isDecelerating)
  {
    CGPoint preUpdateOffset = self.tableView.contentOffset;
    CGFloat offsetAmount = 48. + 42. + 10.; // title + announcement item + spacer
    CGPoint postUpdateOffset = CGPointMake(preUpdateOffset.x, preUpdateOffset.y + offsetAmount);
    self.savedScrollPosition = CGPointMake(self.savedScrollPosition.x, self.savedScrollPosition.y + offsetAmount);
    self.tableView.contentOffset = postUpdateOffset;
    [self generateNodes];
  }
}

- (void)markAnnouncementsAsRead
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (self.announcementDictionary)
    {
        [prefs setValue:[self.announcementDictionary valueForKey:@"name"] forKey:kABSettingKeyLastViewedAnnouncementIdent];
        [prefs synchronize];
    }
    self.announcementDictionary = nil;
    
    [self animateNodeChanges];
}

- (void)checkAnnouncements;
{
  if (![NSThread isMainThread])
    return;
  
  BSELF(RedditsViewController);
  DO_AFTER_WAITING(1, ^{
    [[RedditAPI shared] checkLatestAnnouncementsIfAllowedWithCallBackTarget:blockSelf];
  });
}


@end
