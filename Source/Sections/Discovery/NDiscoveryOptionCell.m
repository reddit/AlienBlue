//
//  NDiscoveryOptionCell.m
//  AlienBlue
//
//  Created by J M on 17/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NDiscoveryOptionCell.h"

@implementation DiscoveryOptionNode

+ (Class)cellClass;
{
    return NSClassFromString(@"NDiscoveryOptionCell");
}

@end

@interface NDiscoveryOptionCell()
@property (strong) JMViewOverlay *subtitleOverlay;
@end

@implementation NDiscoveryOptionCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    DiscoveryOptionNode *optionNode = (DiscoveryOptionNode *)node;
    if (optionNode.subtitle)
        return 50.;
    else
    {
        return [NBaseOptionCell heightForNode:node tableView:tableView];
    }
}

- (void)createSubviews;
{
    [super createSubviews];
    BSELF(NDiscoveryOptionCell);
    self.subtitleOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., self.containerView.width - 100., 20.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [[UIColor grayColor] set];
        UIFont *subtitleFont = [UIFont skinFontWithName:kBundleFontPostSubtitle];
        NSString *subtitle = [(DiscoveryOptionNode *)blockSelf.node subtitle];
        [subtitle drawInRect:bounds withFont:subtitleFont];
    }];
    [self.containerView addOverlay:self.subtitleOverlay];
    self.secondaryButtonOverlay.onTap = ^(CGPoint touchPoint)
    {
        if (blockSelf.node.onSelect)
        {
            blockSelf.node.onSelect();
        }
    };
}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];
    DiscoveryOptionNode *node = (DiscoveryOptionNode *)self.node;
    if (node.subtitle)
    {
        self.subtitleOverlay.left = self.titleOverlay.left;
        self.titleOverlay.top = 9.;
        self.subtitleOverlay.top = self.titleOverlay.bottom + 3.;
    }
    else
    {
        self.titleOverlay.top = 12.;
    }
}

@end
