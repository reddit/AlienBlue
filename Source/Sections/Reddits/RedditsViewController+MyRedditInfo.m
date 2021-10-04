//
//  RedditsViewController+MyRedditInfo.m
//  AlienBlue
//
//  Created by J M on 13/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsViewController+MyRedditInfo.h"
#import "RedditsViewController+Subscriptions.h"
#import "NavigationManager.h"

#import "NMyRedditInfoCell.h"
#import "NSectionSpacerCell.h"
#import "NSubredditFolderCell.h"
#import "NBaseOptionCell.h"

#import "RedditAPI.h"
#import "RedditAPI+Account.h"

@implementation RedditsViewController (MyRedditInfo)

- (MyRedditInfoNode *)addInfoNodeWithTitle:(NSString *)title icon:(UIImage *)icon onSelect:(ABAction)action;
{
    MyRedditInfoNode *node = [[MyRedditInfoNode alloc] init];
    node.title = title;
    node.icon = icon;
    node.onSelect = action;
    [node setDisclosureStyle:OptionDisclosureStyleArrow];
    
    [self addNode:node];
    return node;
}

- (NSString *)titleForUserProfileSection;
{
    RedditAPI *redAPI = [RedditAPI shared];
    if (!redAPI.authenticated || !redAPI.authenticatedUser)
        return @"My Profile";

    NSMutableString *userInfo = [NSMutableString string];
    [userInfo appendString:redAPI.authenticatedUser];
  
    NSString *linkKarmaStr = [NSString shortFormattedStringFromNumber:redAPI.karmaLink shouldDecimilaze:YES];
    NSString *commentKarmaStr = [NSString shortFormattedStringFromNumber:redAPI.karmaComment shouldDecimilaze:YES];
    NSString *karmaStr = [NSString stringWithFormat:@" (%@ : %@)", linkKarmaStr, commentKarmaStr];
    [userInfo appendString:karmaStr];
  
  
//    NSUInteger linkKarma = (redAPI.karmaLink > kKarmaTruncationThreshold) ? (redAPI.karmaLink / 1000) : redAPI.karmaLink;
//    [userInfo appendFormat:@"%d", linkKarma];
//    if (redAPI.karmaLink > kKarmaTruncationThreshold)
//        [userInfo appendString:@"k"];
//    
//    [userInfo appendString:@" : "];
//    
//    NSUInteger commentKarma = (redAPI.karmaComment > kKarmaTruncationThreshold) ? (redAPI.karmaComment / 1000) : redAPI.karmaComment;
//    [userInfo appendFormat:@"%d", commentKarma];
//    if (redAPI.karmaComment > kKarmaTruncationThreshold)
//        [userInfo appendString:@"k"];
//  
//    [userInfo appendString:@")"];
    return userInfo;
}

- (void)showMyProfile;
{
    REQUIRES_REDDIT_AUTHENTICATION;
    [[NavigationManager shared].postsNavigation popToViewController:self animated:NO];
    [[NavigationManager shared] showUserDetails:[[RedditAPI shared] authenticatedUser]];
}

- (void)addInfoSection;
{
  UIColor *defaultIconColor = [[UIColor colorForHighlightedText] colorWithAlphaComponent:0.5];
  UIImage *myRedditIcon = [UIImage skinIcon:@"self-icon" withColor:defaultIconColor];
  UIImage *savedIcon = [UIImage skinIcon:@"small-save-icon" withColor:defaultIconColor];
  UIImage *hiddenIcon = [UIImage skinIcon:@"small-hide-icon" withColor:defaultIconColor];
  UIImage *likedIcon = [UIImage skinIcon:@"small-upvote-icon" withColor:defaultIconColor];
  UIImage *submittedIcon = [UIImage skinIcon:@"small-add-comment-icon" withColor:defaultIconColor];
  
    BSELF(RedditsViewController);
    SubredditFolderNode *titleNode = [SubredditFolderNode folderNodeForFolder:self.subredditPrefs.folderForMyRedditsSection];
    titleNode.title = @"My Account";
    titleNode.collapsable = YES;
    titleNode.onSelect = ^{
        [blockSelf showMyProfile];
    };    
    [self addNode:titleNode];

    NSString *username = [[RedditAPI shared] authenticatedUser];

    OptionNode *karmaOption = [self addInfoNodeWithTitle:[self titleForUserProfileSection] icon:myRedditIcon onSelect:^{
        [blockSelf showMyProfile];
    }];
    karmaOption.bold = YES;

    OptionNode *savedOption = [self addInfoNodeWithTitle:@"Saved" icon:savedIcon onSelect:^{
        REQUIRES_REDDIT_AUTHENTICATION;
        NSString *url = [NSString stringWithFormat:@"/user/%@/saved/", username];
        [blockSelf showPostsForSubreddit:url withTitle:@"Saved"];
    }];

    OptionNode *likedOption = [self addInfoNodeWithTitle:@"Liked" icon:likedIcon onSelect:^{
        REQUIRES_REDDIT_AUTHENTICATION;
        NSString *url = [NSString stringWithFormat:@"/user/%@/liked/", username];
        [blockSelf showPostsForSubreddit:url withTitle:@"Liked"];
    }];
    
    OptionNode *submittedOption = [self addInfoNodeWithTitle:@"Submitted" icon:submittedIcon onSelect:^{
        REQUIRES_REDDIT_AUTHENTICATION;
        NSString *url = [NSString stringWithFormat:@"/user/%@/submitted/", username];
        [blockSelf showPostsForSubreddit:url withTitle:@"Submitted"];
    }];
    
    OptionNode *hiddenOption = [self addInfoNodeWithTitle:@"Hidden" icon:hiddenIcon onSelect:^{
        REQUIRES_REDDIT_AUTHENTICATION;
        NSString *url = [NSString stringWithFormat:@"/user/%@/hidden/", username];
        [blockSelf showPostsForSubreddit:url withTitle:@"Hidden"];
    }];
  
    NSArray *options = [NSArray arrayWithObjects:karmaOption, savedOption, likedOption, submittedOption, hiddenOption, nil];
    [options each:^(OptionNode *option) {
        [titleNode addChildNode:option];
    }];
    
    SectionSpacerNode *spacerNode = [self addSpacerNode];
    [titleNode addChildNode:spacerNode];
    
    if (titleNode.subredditFolder.collapsed)
    {
        [titleNode collapseNode];
    }
}

@end
