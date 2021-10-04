//
//  PostsNavigationTitleView.m
//  AlienBlue
//
//  Created by J M on 2/06/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "PostsNavigationTitleView.h"
#import "ThumbManager.h"

@interface PostsNavigationTitleView()
@property (strong) JMViewOverlay *subredditIconOverlay;
@property (strong) JMViewOverlay *titleOverlay;
@property (strong) Subreddit *subreddit;
@property (strong) NSString *title;
@end

@implementation PostsNavigationTitleView

- (id)initWithFrame:(CGRect)frame forSubreddit:(Subreddit *)subreddit;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor redColor];
        self.subreddit = subreddit;
        
        BSELF(PostsNavigationTitleView);

        self.title = @"Test title";
        self.titleOverlay = [JMViewOverlay overlayWithFrame:self.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
            UIFont *titleFont = [UIFont skinFontWithName:kBundleNavbarTitle];
            [[UIColor whiteColor] set];
            [blockSelf.title drawInRect:CGRectMake(0., 0., bounds.size.width, 25.) withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation];
        }];
        [self addOverlay:self.titleOverlay];
        
        CGRect thumbRect = CGRectMake(14., 6., 36., 36.);
        self.subredditIconOverlay = [JMViewOverlay overlayWithFrame:thumbRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {        
            UIImage *thumb = nil;            
            thumb = [[ThumbManager manager] subredditIconForSubreddit:blockSelf.subreddit.iconIdent ident:@"" onComplete:^(UIImage *image){
                [blockSelf setNeedsDisplay];
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
            [self addOverlay:self.subredditIconOverlay];
        }
        
    }
    return self;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGFloat xOffset = 0;
    self.subredditIconOverlay.left = xOffset + 14.;
    
    if ([self.subreddit isNativeSubreddit])
    {
        self.titleOverlay.left = xOffset + 60;
    }
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    return CGSizeMake(200., 40.);
}

//self.title = title;
//CGRect labelRect = CGRectMake(0, 0, 10., 44.);
//UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
//label.text = title;
//label.backgroundColor = [UIColor clearColor];
//label.font = [UIFont skinFontWithName:kBundleNavbarTitle];
//label.textAlignment = UITextAlignmentCenter;
//label.textColor = [UIColor whiteColor];
//label.shadowColor = [UIColor colorWithWhite:0. alpha:0.5];
//label.shadowOffset = CGSizeMake(0, -1);
//[label sizeToFit];
//self.navigationItem.titleView = label;


@end
