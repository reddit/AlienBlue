//
//  NDiscoverySubredditCell.m
//  AlienBlue
//
//  Created by J M on 16/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NDiscoverySubredditCell.h"
#import "Subreddit+Discovery.h"
#import "Resources.h"

@interface DiscoverySubredditNode()
@end

@implementation DiscoverySubredditNode

+ (Class)cellClass;
{
    return NSClassFromString(@"NDiscoverySubredditCell");
}

@end

@interface NDiscoverySubredditCell()
@property (strong) JMViewOverlay *subtitleOverlay;
@end

@implementation NDiscoverySubredditCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    return 50.;
}

- (void)createSubviews;
{
    [super createSubviews];
    BSELF(NDiscoverySubredditCell);
    self.subtitleOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., self.containerView.width - 100., 20.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        Subreddit *sr = [(DiscoverySubredditNode *)blockSelf.node subreddit];
        CGFloat opacity = MAX(sr.popularityRating,0.3);
        CGFloat white = [Resources isNight] ? 1. : 0.;
        
        [[UIColor colorWithWhite:white alpha:opacity] set];

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *formattedNumber = [formatter stringFromNumber:[NSNumber numberWithUnsignedInteger:sr.numSubscribers]];
        
        NSString *numSubscribersStr = [NSString stringWithFormat:@"%@ subscribers", formattedNumber];
        UIFont *subtitleFont = [UIFont skinFontWithName:kBundleFontPostSubtitle];
        [numSubscribersStr drawInRect:bounds withFont:subtitleFont];
    }];
    [self.containerView addOverlay:self.subtitleOverlay];

    self.thumbOverlay.onTap = ^(CGPoint touchPoint){
        DiscoverySubredditNode *srNode = (DiscoverySubredditNode *)blockSelf.node;
        if (srNode.onThumbnailTap)
        {
            srNode.onThumbnailTap();
        }
    };
    self.thumbOverlay.allowTouchPassthrough = NO;
    self.containerView.allowsOverlayTouchHandling = YES;
    
    self.titleOverlay.top -= 9.;
}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];
    self.subtitleOverlay.left = self.titleOverlay.left;
    self.subtitleOverlay.top = self.titleOverlay.bottom + 3.;
}

@end
