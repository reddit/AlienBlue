//
//  BrowserHeaderView_iPad.m
//  AlienBlue
//
//  Created by J M on 20/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "BrowserHeaderView_iPad.h"
#import "JMViewOverlay+NavigationButton.h"
#import "NavigationManager.h"

@implementation BrowserHeaderView_iPad
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
        
        self.commentsButton = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/small/small-comments-icon"];
        self.commentsButton.onTap = ^(CGPoint touchPoint){
            [[NavigationManager shared] switchToComments];
        };
        self.commentsButton.right = self.width - 218.;
        self.commentsButton.top = 4.;
        self.commentsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.commentsButton];
    }
    return self;
}

- (void)updateWithPost:(Post *)post;
{
    [super updateWithPost:post];
    self.commentsButton.hidden = (post == nil);
}

@end
