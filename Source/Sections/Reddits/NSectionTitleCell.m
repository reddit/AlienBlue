//
//  NRedditTitleCell.m
//  AlienBlue
//
//  Created by J M on 7/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NSectionTitleCell.h"
#import "Resources.h"

@implementation SectionTitleNode

+ (SectionTitleNode *)nodeForTitle:(NSString *)title;
{
  SectionTitleNode *node = [[SectionTitleNode alloc] init];
  node.title = title;
  node.bold = YES;
  node.hidesDivider = YES;
  return node;
}

+ (Class)cellClass;
{
  return NSClassFromString(@"NSectionTitleCell");
}

@end

@interface NSectionTitleCell()
@property (strong) JMViewOverlay *collapseOverlay;
@end

@implementation NSectionTitleCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
  return (node.hidden) ? 0. : 48.;
}

- (void)createSubviews;
{
  [super createSubviews];
  CGRect collapseRect = CGRectMake(7., 2., 40., 40.);
  
  BSELF(NSectionTitleCell);
  
  self.collapseOverlay = [JMViewOverlay overlayWithFrame:collapseRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
      
//    UIBezierPath *buttonPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 8., 8.) cornerRadius:4.];
    UIBezierPath *buttonPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(bounds, 9., 9.)];
    
    [[UIColor colorForBackground] set];
    [buttonPath fill];

    [UIView startEtchedDraw];

    UIColor *borderColor = [[UIColor colorForHighlightedText] colorWithAlphaComponent:0.5];
    [borderColor set];
    buttonPath.lineWidth = 0.5;
    [buttonPath stroke];
    
    if (highlighted)
    {
        [[UIColor colorWithWhite:0. alpha:0.1] set];
        [buttonPath fill];
    }
    
    [borderColor setFill];
    
    BOOL collapsed = [(SectionTitleNode *)blockSelf.node collapsed];
    
    CGFloat angle = collapsed ? 90. : 180.;
    CGSize centerOffset = collapsed ? CGSizeMake(2., 0.5) : CGSizeMake(2., 2.);
    CGPoint center = CGPointCenterOfRect(bounds);
    center = CGPointMake(center.x + centerOffset.width, center.y + centerOffset.height);
    
    [[UIBezierPath bezierPathWithTriangleCenter:center sideLength:8. angle:angle] fill];
    
    [UIView endEtchedDraw];
      
  } onTap:^(CGPoint touchPoint) {
      [blockSelf.node.delegate performSelector:@selector(toggleSubredditFolderCollapseForNode:) withObject:blockSelf.node afterDelay:0.05];
  }];
  [self.containerView addOverlay:self.collapseOverlay];
  self.collapseOverlay.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)layoutCellOverlays;
{
  [super layoutCellOverlays];
  SectionTitleNode *node = (SectionTitleNode *)self.node;
  self.titleOverlay.left = (node.collapsable) ? 54. : 14.;
  self.titleOverlay.top = 15;
}

- (void)updateWithNode:(JMOutlineNode *)node;
{
  [super updateWithNode:node];
  
  SectionTitleNode *titleNode = (SectionTitleNode *)node;
  titleNode.titleColor = [UIColor colorForSectionTitle];
  self.collapseOverlay.hidden = !titleNode.collapsable;
}

- (void)drawTitleBackground_iPhone;
{
  CGRect underlineRect = CGRectInset(CGRectCropToBottom(self.bounds, 1.), 12., 0.);
  [UIView jm_drawHorizontalDottedLineInRect:underlineRect lineWidth:0.5 lineColor:[UIColor colorForDottedDivider]];
}

- (void)decorateCellBackground;
{
  [super decorateCellBackground];
  
  if (![Resources isIPAD] && !self.editing)
  {
      [self drawTitleBackground_iPhone];
  }
  
  SectionTitleNode *node = (SectionTitleNode *)self.node;
  
  CGFloat dividerOffset = node.collapsable ? 54. : 12.;
  if (!self.highlighted && [Resources isIPAD])
  {
    if (!node.collapsed)
    {
      // draw a custom divider to the right hand side of the collapse button
      [UIView startEtchedDraw];
      [[UIColor colorForDivider] set];
      [[UIBezierPath bezierPathWithRect:CGRectMake(dividerOffset, self.height - 8., self.width - 12. - dividerOffset, 1.)] fill];
      [UIView endEtchedDraw];
    }
    else
    {
      [self drawDivider];
    }
  }
}

@end
