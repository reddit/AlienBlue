//
//  NSubredditFolderCell.m
//  AlienBlue
//
//  Created by J M on 9/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NSubredditFolderCell.h"
#import "UIBezierPath+Shapes.h"
#import "Resources.h"

@implementation SubredditFolderNode

- (id)initWithFolder:(SubredditFolder *)folder secondaryIcon:(UIImage *)secondaryIcon secondaryAction:(ABAction)secondaryAction;
{
    self = [super init];
    if (self)
    {
        self.subredditFolder = folder;
      
        NSMutableString *folderTitle = [[NSMutableString alloc] initWithString:folder.title];
        [folderTitle jm_mutableReplaceString:@"Subscribed Reddits" withString:@"Subscriptions"];
        [folderTitle jm_mutableReplaceString:@"Casual Reddits" withString:@"Casual Subreddits"];
        self.title = folderTitle;
        self.bold = YES;
        self.hidesDivider = YES;
        self.titleColor = [UIColor colorForSectionTitle];
        self.secondaryIcon = secondaryIcon;
        self.secondaryAction = secondaryAction;
    }
    return self;
}

+ (SubredditFolderNode *)folderNodeForFolder:(SubredditFolder *)folder;
{
    SubredditFolderNode *node = [[SubredditFolderNode alloc] initWithFolder:folder secondaryIcon:nil secondaryAction:nil];
    //        [blockSelf.node.delegate performSelector:@selector(showRedditEntryViewForFolder:) withObject:[(SubredditFolderNode *)blockSelf.node subredditFolder] afterDelay:0.05];
    return node;
}

+ (Class)cellClass;
{
    return NSClassFromString(@"NSubredditFolderCell");
}

@end

@interface NSubredditFolderCell()
- (void)doubleTapped;
@end

@implementation NSubredditFolderCell

- (void)applyGestureRecognizers;
{
    self.containerView.alwaysAllowOverlayGestureRecognizers = YES;
    
    BSELF(NSubredditFolderCell);    
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *gesture) {
        [blockSelf doubleTapped];
    }];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    doubleTapGesture.delaysTouchesEnded = NO;
    doubleTapGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:doubleTapGesture];
}

- (void)createSubviews;
{
    [super createSubviews];
    [self applyGestureRecognizers];
}

- (void)doubleTapped;
{
    SubredditFolderNode *folderNode = (SubredditFolderNode *)self.node;
    if (folderNode.onDoubleTap)
    {
        folderNode.onDoubleTap();
    }
}

@end
