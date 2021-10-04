//
//  NInlineImageCell.m
//  AlienBlue
//
//  Created by J M on 1/01/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NInlineImageCell.h"
#import "InlineImageOverlay.h"

@implementation InlineImageNode

+ (Class)cellClass;
{
    return NSClassFromString(@"NInlineImageCell");
}

@end

@interface NInlineImageCell()
@property (strong) InlineImageOverlay *imagePreviewOverlay;
@end

@implementation NInlineImageCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    CGFloat height = 0.;
    InlineImageNode *inlineNode = (InlineImageNode *)node;
    height += [InlineImageOverlay heightForInlinePreviewForNode:inlineNode constrainedToWidth:tableView.width];
    return height;
}

- (void)createSubviews;
{
    [self setCellBackgroundColor:[UIColor colorForBackground]];
    self.imagePreviewOverlay = [[InlineImageOverlay alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.imagePreviewOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.containerView addOverlay:self.imagePreviewOverlay];
}

- (void)updateSubviews;
{
    [self.imagePreviewOverlay updateForNode:(InlineImageNode *)self.node];
}

- (void)decorateCell;
{
}

- (void)decorateCellBackground;
{
    [[UIColor blackColor] set];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
}

@end

