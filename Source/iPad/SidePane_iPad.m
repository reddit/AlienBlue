//
//  SidePane_iPad.m
//  AlienBlue
//
//  Created by J M on 21/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SidePane_iPad.h"
#import "NavigationManager_iPad.h"
#import "ABButton.h"
#import "AppDelegate_iPad.h"
#import "SidePaneBezelButton.h"
#import "JMFNNavigationController.h"
#import "Resources.h"
#import "RedditAPI+Account.h"
#import "Announcement.h"
#import "AnnouncementViewController.h"

@interface SidePane_iPad()
@property (strong) ABButton *settingsButton;
@property (strong) ABButton *messagesButton;
@property (strong) ABButton *tipButton;
@property (strong) ABButton *backButton;
@property (strong) ABButton *collapseButton;
@property (strong) UIButton *announcementButton;
@property (strong) SidePaneBezelButton *paneButton;
@property (strong) NSString *i_paneTitle;
- (void)respondToStyleChangeNotification;
@end

@implementation SidePane_iPad

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kABAuthenticationStatusDidReceiveUpdatedUserInformation object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJMFNControllerStackChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSidePaneNeedsRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAnnouncementReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAnnouncementMarkedReadNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.settingsButton = [ABButton buttonWithImageName:@"icons/ipad-navbar/navbar-settings" onTap:^{
            [[NavigationManager shared] showSettingsScreen];
        }];
        
        self.messagesButton = [ABButton buttonWithImageName:@"icons/ipad-navbar/navbar-message" onTap:^{
            [[NavigationManager shared] showMessagesScreen];
        }];
        
        self.tipButton = [ABButton buttonWithImageName:@"icons/ipad-navbar/navbar-tip" onTap:^{
            [(NavigationManager_iPad *)[NavigationManager_iPad shared] showPortraitSelectionTip];
        }];
        
        self.collapseButton = [ABButton buttonWithImageName:@"icons/ipad-navbar/navbar-sidepane-collapse" onTap:^{
            [[NavigationManager_iPad foldingNavigation] hideSidePaneAnimated:YES showingRevealButton:YES];
        }];

        [self addSubview:self.settingsButton];
        [self addSubview:self.messagesButton];
        [self addSubview:self.tipButton];
        [self addSubview:self.collapseButton];
        
        self.settingsButton.top = 6.;
        self.settingsButton.left = 4.;

        self.messagesButton.top = 62.;
        self.messagesButton.left = 5.;

        self.tipButton.top = 125.;
        self.tipButton.left = 4.;
        
        self.collapseButton.left = 4.;
        self.collapseButton.bottom = self.height;
        self.collapseButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        self.paneButton = [SidePaneBezelButton new];
        self.paneButton.frame = CGRectCenterWithSize(self.bounds, CGSizeMake(40., 200.));
        self.paneButton.left = 5.;
        self.paneButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.paneButton addEventHandler:^(id sender) {
            [(NavigationManager_iPad *)[NavigationManager shared] goHome];
        } forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.paneButton];
        
        self.backButton = [ABButton buttonWithImageName:@"icons/ipad-navbar/navbar-sideback" onTap:^{
                [(NavigationManager_iPad *)[NavigationManager shared] goBack];
        }];
        self.backButton.left = 4.;
        self.backButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.backButton];
      
        self.announcementButton = [UIButton new];
        UIImage *announcementButtonImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
          CGRect buttonRect = CGRectInset(bounds, 0., 4.);
          [[UIColor skinColorForConstructive] setFill];
          UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:(buttonRect.size.height / 2.)];
          [path fill];
          [@"Announcement" jm_drawVerticallyCenteredInRect:buttonRect withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.] color:[UIColor whiteColor] horizontalAlignment:NSTextAlignmentCenter];
        } withSize:CGSizeMake(100., 30.)];
        self.announcementButton.size = announcementButtonImage.size;
        [self.announcementButton setImage:announcementButtonImage forState:UIControlStateNormal];
        [self addSubview:self.announcementButton];
        [self.announcementButton centerInSuperView];
        self.announcementButton.alpha = 0.;
        [self.announcementButton addTarget:self action:@selector(userDidTapAnnouncementButton) forControlEvents:UIControlEventTouchUpInside];
        self.announcementButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.announcementButton.top = self.messagesButton.bottom + 18;
      
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOrangeredStatus) name:kABAuthenticationStatusDidReceiveUpdatedUserInformation object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToStyleChangeNotification) name:kNightModeSwitchNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationStackChanged) name:kJMFNControllerStackChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationStackChanged) name:kSidePaneNeedsRefreshNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(announcementReceived) name:kAnnouncementReceivedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(announcementMarkedAsRead) name:kAnnouncementMarkedReadNotification object:nil];

        [self respondToStyleChangeNotification];
    }
    return self;
}

- (void)respondToStyleChangeNotification;
{
    self.backgroundColor = [Resources isNight] ? [UIColor colorWithWhite:0.5 alpha:0.15] : [UIColor clearColor];
}

- (void)navigationStackChanged;
{
    BSELF(SidePane_iPad);
    [UIView transitionWithView:blockSelf.backButton duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        if (JMLandscape() || [[NavigationManager shared].postsNavigation.viewControllers count] <= 2 || [[NSUserDefaults standardUserDefaults] boolForKey:kABSettingKeyIpadCompactPortraitTrainingComplete])
            blockSelf.tipButton.alpha = 0.;
        else
            blockSelf.tipButton.alpha = 1.;
        blockSelf.backButton.alpha = ([[NavigationManager shared].postsNavigation.viewControllers count] <= 2) ? 0.3 : 1.;
    } completion:nil];
}

- (void)setPaneTitle:(NSString *)paneTitle;
{
    BSELF(SidePane_iPad);
    [UIView transitionWithView:blockSelf.paneButton duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [blockSelf.paneButton setPaneTitle:paneTitle];
    } completion:^(BOOL finished) {
    }];
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    [self navigationStackChanged];
    self.backButton.bottom = self.paneButton.top - 6.;
}

- (void)refreshOrangeredStatus;
{
    BSELF(SidePane_iPad);

    if ([RedditAPI shared].hasMail)
        self.messagesButton.imageSelected = [UIImage skinImageNamed:@"icons/ipad-navbar/navbar-orangered"];
    else if ([RedditAPI shared].hasModMail)
        self.messagesButton.imageSelected = [UIImage skinImageNamed:@"icons/ipad-navbar/navbar-modmail"];
    else
        self.messagesButton.imageSelected = nil;
    
    [UIView transitionWithView:blockSelf.messagesButton duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        blockSelf.messagesButton.selected = (blockSelf.messagesButton.imageSelected != nil);
        [blockSelf.messagesButton setNeedsDisplay];
    } completion:nil];    
}

+ (BOOL)shouldDisplayAnnouncementBanner;
{
  Announcement *latestAnnouncement = [Announcement latestAnnouncement];
  return latestAnnouncement && latestAnnouncement.shouldShow && latestAnnouncement.showsBanner;
}

- (void)updateAnnouncementButtonAnimated:(BOOL)animated;
{
  BOOL showAnnouncementBanner = [[self class] shouldDisplayAnnouncementBanner];
  
  BSELF(SidePane_iPad);
  [UIView jm_transition:self animations:^{
    blockSelf.announcementButton.alpha = showAnnouncementBanner ? 1. : 0.;
  } completion:nil animated:animated];
}

- (void)announcementReceived;
{
  [self updateAnnouncementButtonAnimated:YES];
}

- (void)announcementMarkedAsRead
{
  [self updateAnnouncementButtonAnimated:YES];
}

- (void)userDidTapAnnouncementButton;
{
  [AnnouncementViewController showLatest];
}

@end
