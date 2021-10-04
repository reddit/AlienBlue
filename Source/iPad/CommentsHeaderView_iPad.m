//
//  CommentsHeaderView_iPad.m
//  AlienBlue
//
//  Created by J M on 19/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "CommentsHeaderView_iPad.h"
#import "JMViewOverlay+NavigationButton.h"
#import "JMFNNavigationController.h"
#import "NavigationManager.h"

@interface CommentsHeaderView_iPad()
@property (strong) JMViewOverlay *subredditLinkOverlay;
@property (strong) JMViewOverlay *authorLinkOverlay;
@property (strong) JMViewOverlay *articleButton;
@end


@implementation CommentsHeaderView_iPad

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.expandButtonOverlay = [JMViewOverlay buttonWithIcon:@"generated/ipad-expand-icon"];
        self.expandButtonOverlay.left = 17.;
        self.expandButtonOverlay.top = 6.;
        self.expandButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addOverlay:self.expandButtonOverlay];
    }
    return self;
}

- (void)updateWithPost:(Post *)post;
{
    [super updateWithPost:post];
  
    BSELF(CommentsHeaderView_iPad);
    [UIView jm_transition:self.contentView animations:^{
        [blockSelf layoutOverlays];
    } completion:nil animated:YES];

}

- (void)layoutOverlays;
{
//  self.expandButtonOverlay.hidden = ![self.controller fullScreen];
  self.expandButtonOverlay.selected = self.controller.fullScreen;
  
//    [super layoutOverlays];
//    
//    [self.subredditLinkOverlay removeFromParentView];
//    [self.authorLinkOverlay removeFromParentView];
//    
//    Post *post = self.post;
//    NSString *subredditTitle = [post.subreddit convertToSubredditTitle];
//    NSString *authorTitle = post.author;
//    
//    CGFloat xOffset = 8.;
//    
//    self.expandButtonOverlay.hidden = !JMPortrait();
//    
//    if (!self.expandButtonOverlay.hidden)
//    {
//        xOffset += 57.;
//    }
//    
//    self.subredditLinkOverlay = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/navbar-subreddit" title:subredditTitle]; 
//    self.subredditLinkOverlay.left = xOffset;
//    self.subredditLinkOverlay.top = 5.;
//    self.subredditLinkOverlay.onTap = ^(CGPoint touchPoint) {
//        [[NavigationManager shared] showPostsForSubreddit:post.subreddit title:nil animated:YES];
//    };
//    
//    [self.contentView addOverlay:self.subredditLinkOverlay];
//    
//    self.authorLinkOverlay = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/navbar-author" title:authorTitle];
//    self.authorLinkOverlay.left = self.subredditLinkOverlay.right + 8.;
//    self.authorLinkOverlay.top = 5.;
//    self.authorLinkOverlay.onTap = ^(CGPoint touchPoint) {
//        [[NavigationManager shared] showUserDetails:post.author];
//    };
//    [self.contentView addOverlay:self.authorLinkOverlay];
//    
//    self.subredditLinkOverlay.hidden = (self.width < 500.);
//    self.authorLinkOverlay.hidden = (self.width < 500.);
}



@end
