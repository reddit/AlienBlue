//
//  ContentHeaderView_iPad.m
//  AlienBlue
//
//  Created by J M on 19/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "ContentHeaderView_iPad.h"

#import "ABEventLogger.h"
#import "AppDelegate_iPad.h"
#import "JMViewOverlay+NavigationButton.h"
#import "NavigationManager.h"
#import "Post+API.h"
#import "Post+Style.h"
#import "RedditAPI+Account.h"

@interface ContentHeaderView_iPad()
@property (strong) JMViewOverlay *actionButton;
@property (strong) JMViewOverlay *saveButton;
@property (strong) JMViewOverlay *hideButton;
@property (strong) JMViewOverlay *downvoteButton;
@property (strong) JMViewOverlay *upvoteButton;
@property (strong) UIBarButtonItem *actionBarButtonItemProxy;
@property (strong) UINavigationBar *navbarProxy;
@property (strong) Post *post;

- (void)toggleSave;
- (void)toggleHide;
- (void)voteUpPost;
- (void)voteDownPost;

- (void)redrawButtons;
@end

@implementation ContentHeaderView_iPad

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNavigationBarVoteStatusChanged object:nil];
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        BSELF(ContentHeaderView_iPad);
        
        CGFloat yOffset = 5.;
        CGFloat itemSpacing = 10.;
        
        self.upvoteButton = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/small/small-upvote-icon" highlightColor:[UIColor orangeColor]];
        self.upvoteButton.onTap = ^(CGPoint touchPoint){
            [blockSelf voteUpPost];
        };
        self.upvoteButton.right = self.width - 15.;
        self.upvoteButton.top = yOffset;
        self.upvoteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.upvoteButton];

        self.downvoteButton = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/small/small-downvote-icon" highlightColor:[UIColor colorForDownvote]];
        self.downvoteButton.onTap = ^(CGPoint touchPoint){
            [blockSelf voteDownPost];
        };
        self.downvoteButton.right = self.upvoteButton.left - itemSpacing;
        self.downvoteButton.top = yOffset;
        self.downvoteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.downvoteButton];

//        self.hideButton = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/navbar-hide" highlightColor:[UIColor colorForDownvote]];
//        self.hideButton.onTap = ^(CGPoint touchPoint){
//            [blockSelf toggleHide];
//        };
//        self.hideButton.right = self.downvoteButton.left - itemSpacing;
//        self.hideButton.top = yOffset;
//        self.hideButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//        [self addOverlay:self.hideButton];
        
        self.saveButton = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/small/small-save-icon" highlightColor:[UIColor colorForUpvote]];
        self.saveButton.onTap = ^(CGPoint touchPoint){
            [blockSelf toggleSave];
        };
        self.saveButton.right = self.downvoteButton.left - itemSpacing;
        self.saveButton.top = yOffset - 1.;
        self.saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.saveButton];
        
        self.actionButton = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/small/small-share-icon"];
        self.actionButton.onTap = ^(CGPoint touchPoint){

        };
        self.actionButton.right = self.saveButton.left - itemSpacing;
        self.actionButton.top = yOffset - 2;
        self.actionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.actionButton];
        
        self.navbarProxy = [[UINavigationBar alloc] initWithFrame:self.actionButton.frame];
        self.navbarProxy.left = self.actionButton.left - 13.;
        self.navbarProxy.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.actionBarButtonItemProxy = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil];
        UINavigationItem *navitem = [[UINavigationItem alloc] init];
        navitem.leftBarButtonItem = self.actionBarButtonItemProxy;
        [self.navbarProxy setItems:[NSArray arrayWithObject:navitem]];
        [self addSubview:self.navbarProxy];
        self.navbarProxy.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawButtons) name:kNavigationBarVoteStatusChanged object:nil];
    }
    return self;
}

- (void)redrawButtons;
{
    if (!self.post)
    {
        self.saveButton.hidden = YES;
        self.hideButton.hidden = YES;
        self.upvoteButton.hidden = YES;
        self.downvoteButton.hidden = YES;
        self.actionButton.right = self.upvoteButton.right;
        self.navbarProxy.left = self.actionButton.left - 13.;
    }
    else
    {
        self.saveButton.selected = self.post.saved;
        self.hideButton.selected = self.post.hidden;
        self.upvoteButton.selected = (self.post.voteState == VoteStateUpvoted);
        self.downvoteButton.selected = (self.post.voteState == VoteStateDownvoted);
    }
    [self.contentView setNeedsDisplay];
}

- (void)updateWithPost:(Post *)npost;
{
    if (!self.post && npost)
    {
        // fire off only once to let posts list know that we're focussing on a post
        [[NSNotificationCenter defaultCenter] postNotificationName:kContentPaneOpenedForPostNotification object:npost];
    }
    self.post = npost;
    [self redrawButtons];
}

- (void)toggleSave;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [self.post toggleSaved];
    [self redrawButtons];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNavigationBarVoteStatusChanged object:nil];
}

- (void)toggleHide;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [self.post toggleHide];
    [self redrawButtons];
}

- (void)voteUpPost;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [[ABEventLogger shared] logUpvoteChangeForPost:self.post
                                         container:@"ipad_detail"
                                           gesture:@"button_press"];
    [self.post upvote];
    [self.post flushCachedStyles];
    [self redrawButtons];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNavigationBarVoteStatusChanged object:nil];
}

- (void)voteDownPost;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [[ABEventLogger shared] logDownvoteChangeForPost:self.post
                                           container:@"ipad_detail"
                                             gesture:@"button_press"];
    [self.post downvote];
    [self.post flushCachedStyles];
    [self redrawButtons];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNavigationBarVoteStatusChanged object:nil];
}

@end

