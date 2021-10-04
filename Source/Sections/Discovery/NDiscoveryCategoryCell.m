//
//  NDiscoveryGategoryCell.m
//  AlienBlue
//
//  Created by J M on 17/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NDiscoveryCategoryCell.h"
#import "ThumbManager.h"

@implementation DiscoveryCategoryNode
+ (DiscoveryCategoryNode *)categoryNodeForCategory:(DiscoveryCategory *)category;
{
    DiscoveryCategoryNode *node = [[DiscoveryCategoryNode alloc] init];
    node.category = category;
    node.title = category.title;
    node.stickyHighlight = YES;
    [node setDisclosureStyle:OptionDisclosureStyleArrow];
    return node;
}

+ (Class)cellClass;
{
    return NSClassFromString(@"NDiscoveryCategoryCell");
}
@end

@interface NDiscoveryCategoryCell()
@property (strong) JMViewOverlay *thumbOverlay;
@end

@implementation NDiscoveryCategoryCell

- (void)createSubviews;
{
    [super createSubviews];
    
    CGRect thumbRect = CGRectMake(14., 4., 36., 36.);
    BSELF(NDiscoveryCategoryCell);
    self.thumbOverlay = [JMViewOverlay overlayWithFrame:thumbRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {        
        DiscoveryCategoryNode *categoryNode = (DiscoveryCategoryNode *)blockSelf.node;
        NSString *iconIdent = categoryNode.category.iconIdent;
        SET_IF_EMPTY(iconIdent, @"reddit");
        UIImage *thumb = nil;

        thumb = [[ThumbManager manager] subredditIconForSubreddit:iconIdent ident:@"" onComplete:^(UIImage *image){
            [blockSelf.containerView setNeedsDisplay];
        }];
                
        if (!thumb)
        {
            thumb = [UIImage skinImageNamed:@"section/reddits-list/subreddit-icon-placeholder"];
        }
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        [UIView addRoundedRectToPathForContext:context rect:bounds ovalWidth:4. ovalHeight:4.];
        CGContextClip(context);
        
        [thumb drawAtPoint:CGPointMake(-1., 0.)];
        
        CGContextRestoreGState(context);
    }];
    [self.containerView addOverlay:self.thumbOverlay];
    self.thumbOverlay.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];
    self.titleOverlay.left = 60.;
}


@end
