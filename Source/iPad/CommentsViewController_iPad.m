//
//  CommentsViewController_iPad.m
//  AlienBlue
//
//  Created by J M on 19/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "CommentsViewController_iPad.h"
#import "CommentsHeaderView_iPad.h"
#import "BrowserViewController_iPad.h"
#import "CommentsViewController+PopoverOptions.h"
#import "CommentsViewController+LinkHandling.h"
#import "CommentAddSeparatorCell_iPad.h"
#import "UIViewController+JMFoldingNavigation.h"
#import "CommentsViewController+Interaction.h"
#import "NCommentCell_iPad.h"
#import "NavigationManager_iPad.h"
#import "Resources.h"
#import "CommentPostHeaderToolbar.h"

@interface CommentsViewController_iPad()
@property (strong) CommentsHeaderView_iPad *headerView;
- (void)updateNavigationHeader;
@end

@implementation CommentsViewController_iPad

- (void)loadView
{
    [super loadView];

    self.headerView = [[CommentsHeaderView_iPad alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 55.)];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.headerView];
  
    self.tableView.top = self.headerView.height - 5.;
    self.tableView.height -= self.tableView.top;
    self.topShadowView.hidden = YES;
    self.headerView.shadowTriggerOffset = kCommentPostHeaderToolbarHeight;
  
    BSELF(CommentsViewController_iPad);
    self.headerView.actionButton.onTap = ^(CGPoint touchPoint){
        [blockSelf popupExtraOptionsActionSheet:blockSelf.headerView.actionBarButtonItemProxy];
    };

    self.headerView.expandButtonOverlay.onTap = ^(CGPoint touchPoint){
        blockSelf.headerView.expandButtonOverlay.selected = !blockSelf.fullScreen;
        [blockSelf toggleFullscreen];
    };
    
    UISwipeGestureRecognizer *twoFingerLeftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(collapseGestureReceived:)];
    twoFingerLeftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    twoFingerLeftSwipeGesture.numberOfTouchesRequired = 2;
    [self.tableView addGestureRecognizer:twoFingerLeftSwipeGesture];

    UISwipeGestureRecognizer *twoFingerRightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(focusOnCommentGestureReceived:)];
    twoFingerRightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    twoFingerRightSwipeGesture.numberOfTouchesRequired = 2;
    [self.tableView addGestureRecognizer:twoFingerRightSwipeGesture];
    
    [self updateNavigationHeader];
}

- (void)viewWillLayoutSubviews;
{
    [super viewWillLayoutSubviews];
    self.headerView.expandButtonOverlay.selected = self.fullScreen;
}

- (CommentNode *)commentNodeAtSwipeGesture:(UISwipeGestureRecognizer *)gesture;
{
    if ([gesture numberOfTouches] != 2)
        return nil;
    
    CGPoint tp1 = [gesture locationOfTouch:0 inView:self.tableView];
    CGPoint tp2 = [gesture locationOfTouch:1 inView:self.tableView];
    
    // average the touch points to guess where the user intends to collapse
    CGPoint tp = CGPointMake((tp1.x + tp2.x) / 2., (tp1.y + tp2.y) / 2.);
    NSIndexPath *ip = [self.tableView indexPathForRowAtPoint:tp];
    CommentNode *node = (CommentNode *)[self nodeForRow:ip.row];

    if (![node isKindOfClass:[CommentNode class]])
        return nil;
    
    return node;
}

- (void)collapseGestureReceived:(UISwipeGestureRecognizer *)gesture;
{
    CommentNode *node = [self commentNodeAtSwipeGesture:gesture];
    if (node && !node.collapsed && !node.hidden)
    {
        [self collapseToRootCommentNode:node];
    }
}

- (void)focusOnCommentGestureReceived:(UISwipeGestureRecognizer *)gesture;
{
    CommentNode *node = [self commentNodeAtSwipeGesture:gesture];
    if (node)
    {
        [self focusContextCommentNode:node];
    }
}

- (CGFloat)pageWidth;
{
    CGFloat width = JMPortrait() ? 640. : 540.;
    
    if ([Resources compactPortrait])
    {
        width = 396.;
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:kABSettingKeyIpadUseLegacyPostPaneSize] && JMLandscape())
    {
        width += 70.;
    }
    
    if (![NavigationManager_iPad foldingNavigation].showingSidePane)
        width += kSidePaneWidth;

    return width;
}

- (void)respondToStyleChange;
{
    [super respondToStyleChange];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorForBackground];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [super scrollViewDidScroll:scrollView];
    [self.headerView updateWithContentOffset:scrollView.contentOffset];
}

- (void)updateNavigationHeader;
{
    [self.headerView updateWithPost:self.post];
}

- (id)initWithPost:(Post *)post contextId:(NSString *)contextId;
{
    self = [super initWithPost:post contextId:contextId];
    if (self)
    {
        [self updateNavigationHeader];
    }
    return self;
}

- (void)addPreCommentNodes;
{
    [super addPreCommentNodes];
    
    CommentAddSeparatorNode *separatorNode = [CommentAddSeparatorNode new];
    [self addNode:separatorNode];
}

- (void)commentsDidFinishLoading;
{
    [super commentsDidFinishLoading];
    [self updateNavigationHeader];
}

@end
