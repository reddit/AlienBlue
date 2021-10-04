//
//  PostsHeaderView_iPad.m
//  AlienBlue
//
//  Created by J M on 15/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "PostsHeaderView_iPad.h"
#import "JMViewOverlay+NavigationButton.h"
#import "ThumbManager.h"
#import "Subreddit.h"
#import "UIViewController+JMFoldingNavigation.h"

@interface PostsHeaderView_iPad()
@property (strong) JMViewOverlay *searchButton;
@property (strong) JMViewOverlay *createPostButton;
@property (strong) JMViewOverlay *showCanvasButton;
@property (strong) JMViewOverlay *subredditIconOverlay;
@property (strong) JMViewOverlay *expandButtonOverlay;
@property (strong) Subreddit *subreddit;
@end

@implementation PostsHeaderView_iPad

- (id)initWithFrame:(CGRect)frame forSubreddit:(Subreddit *)subreddit;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.subreddit = subreddit;
        
        BSELF(PostsHeaderView_iPad);
        
        self.expandButtonOverlay = [JMViewOverlay buttonWithIcon:@"generated/ipad-expand-icon"];
        self.expandButtonOverlay.left = 13.;
        self.expandButtonOverlay.top = 6.;
        self.expandButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.expandButtonOverlay.hidden = YES;
        self.expandButtonOverlay.onTap = ^(CGPoint point){
            [blockSelf.controller toggleFullscreen];
        };
        [self.contentView addOverlay:self.expandButtonOverlay];
        
        self.searchButton = [JMViewOverlay buttonWithIcon:@"generated/ipad-search-icon"];
        self.searchButton.right = self.width - 8.;
        self.searchButton.top = 6.;
        self.searchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.searchButton];
        
        self.createPostButton = [JMViewOverlay buttonWithIcon:@"generated/ipad-add-icon"];
        self.createPostButton.right = self.searchButton.left - 8.;
        self.createPostButton.top = 6.;
        self.createPostButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.createPostButton];
        
        self.showCanvasButton = [JMViewOverlay buttonWithIcon:@"generated/ipad-canvas-icon"];
        self.showCanvasButton.right = self.createPostButton.left - 8.;
        self.showCanvasButton.top = 5.;
        self.showCanvasButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.showCanvasButton];
        
        CGRect thumbRect = CGRectMake(14., 6., 36., 36.);
        self.subredditIconOverlay = [JMViewOverlay overlayWithFrame:thumbRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {        
            UIImage *thumb = nil;            
            thumb = [[ThumbManager manager] subredditIconForSubreddit:blockSelf.subreddit.iconIdent ident:@"" onComplete:^(UIImage *image){
                [blockSelf.contentView setNeedsDisplay];
            }];
            
            if (!thumb)
                thumb = [UIImage skinImageNamed:@"section/reddits-list/subreddit-icon-placeholder"];
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            [UIView addRoundedRectToPathForContext:context rect:bounds ovalWidth:4. ovalHeight:4.];
            CGContextClip(context);
            
            [thumb drawAtPoint:CGPointMake(-1., 0.)];
            
            CGContextRestoreGState(context);
            
            CGRect shadowFrame = bounds;
            shadowFrame.size.height += 2.;
            [[UIImage skinImageNamed:@"section/reddits-list/subreddit-icon-inset"] drawInRect:shadowFrame];
            if (highlighted)
            {
                [[UIImage skinImageNamed:@"section/reddits-list/subreddit-icon-inset"] drawInRect:shadowFrame];
            }
        }];
        
        if ([self.subreddit isNativeSubreddit])
        {
            self.titleOverlay.left = 60;
            [self.contentView addOverlay:self.subredditIconOverlay];
        }

    }
    return self;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGFloat xOffset = 0;
    if ([self.controller fullScreen])
    {
        xOffset += 50.;
    }

    self.expandButtonOverlay.hidden = ![self.controller fullScreen];
    self.expandButtonOverlay.selected = self.controller.fullScreen;
    
    self.titleOverlay.left = xOffset + kNavigationHeaderPadding;
  
    self.subredditIconOverlay.left = xOffset + 14.;

    if ([self.subreddit isNativeSubreddit])
    {
        self.titleOverlay.left = xOffset + 60;
    }
    self.titleOverlay.width = self.bounds.size.width - 140 - self.titleOverlay.left;
}

- (void)layoutOverlays;
{
  [super layoutOverlays];
}

#pragma mark - Accessibility


@end
