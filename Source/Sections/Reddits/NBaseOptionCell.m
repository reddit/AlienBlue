//
//  NBaseSubredditCell.m
//  AlienBlue
//
//  Created by J M on 7/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NBaseOptionCell.h"
#import "Resources.h"

@interface OptionNode()
@property OptionDisclosureStyle i_disclosureStyle;
@end

@implementation OptionNode

+(Class)cellClass;
{
    return NSClassFromString(@"NBaseOptionCell");
}

- (void)setDisclosureStyle:(OptionDisclosureStyle)style;
{
    if (style == OptionDisclosureStyleArrow)
    {
        UIImage *disclosureIcon = [UIImage skinIcon:@"tiny-right-arrow-icon" withColor:[UIColor colorForAccessoryButtons]];
        self.secondaryIcon = disclosureIcon;
    }
    self.i_disclosureStyle = style;
}

@end

@interface NBaseOptionCell()
@end

@implementation NBaseOptionCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    if (node.hidden) return 0;
    
    return 48.;
}

- (BOOL)isEditingTable;
{
    return [(UITableView *)[self firstParentOfClass:[UITableView class]] isEditing];
}

- (void)createSubviews;
{
    [super createSubviews];

    // option title
    CGFloat titleHeight = [@"A" sizeWithFont:[UIFont skinFontWithName:kBundleFontOptionTitle]].height;
    CGRect textRect = CGRectInset(self.containerView.bounds, 14., (self.height - titleHeight) / 2.);
    textRect.size = CGSizeMake(textRect.size.width - 36., textRect.size.height);
    BSELF(NBaseOptionCell);
    self.titleOverlay = [JMViewOverlay overlayWithFrame:textRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        OptionNode *optionNode = (OptionNode *)blockSelf.node;
        
        if (!optionNode.titleColor)
        {
            UIColor *textColor = (optionNode.disabled || [blockSelf isEditingTable]) ? [UIColor grayColor] : [UIColor colorForText];
            [textColor set];
        }
        else
        {
            [optionNode.titleColor set];
        }
        
        NSString *title = [(OptionNode *)blockSelf.node title];
        BOOL bold = [(OptionNode *)blockSelf.node bold];
        CGRect titleRect = CGRectOffset(bounds, 0., 0.);
        NSString *fontKey = bold ? kBundleFontOptionTitleBold : kBundleFontOptionTitle;
        [title drawInRect:titleRect withFont:[UIFont skinFontWithName:fontKey] lineBreakMode:UILineBreakModeTailTruncation];
    }];
    self.titleOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.containerView addOverlay:self.titleOverlay];
    
    // option icon
    CGRect iconRect = CGRectCenterWithSize(self.containerView.bounds, CGSizeMake(26., 26.));
    iconRect.origin = CGPointMake(12., iconRect.origin.y);
    self.iconOverlay = [JMViewOverlay overlayWithFrame:iconRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        UIImage *icon = [(OptionNode *)blockSelf.node icon];
        [UIView startEtchedDraw];
        [icon drawInRect:bounds];
        [UIView endEtchedDraw];
    }];
    [self.containerView addOverlay:self.iconOverlay];
    self.iconOverlay.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  
    self.iconSeparatorOverlay = [JMViewOverlay overlayWithSize:CGSizeMake(2., 17.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
      [UIView jm_drawVerticalDottedLineInRect:bounds lineWidth:0.5 lineColor:[UIColor colorForDottedDivider] dashScale:0.6];
    }];
    [self.containerView addOverlay:self.iconSeparatorOverlay];
    self.iconSeparatorOverlay.autoresizingMask = JMFlexibleVerticalMarginMask;
    self.iconSeparatorOverlay.frame = CGRectCenterWithSize(self.containerView.bounds, self.iconSeparatorOverlay.size);
    self.iconSeparatorOverlay.left = 47.;
  
    
    CGRect secondaryButtonFrame = CGRectMake(self.containerView.width - 42., 2., 40., 40.);
    self.secondaryButtonOverlay = [JMViewOverlay overlayWithFrame:secondaryButtonFrame drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {        
        OptionNode *optionNode = (OptionNode *)blockSelf.node;        
        CGRect iconRect = CGRectCenterWithSize(bounds, optionNode.secondaryIcon.size);
        CGFloat opacity = highlighted ? 0.5 : 1.;
        [UIView startEtchedDraw];
        [optionNode.secondaryIcon drawInRect:iconRect blendMode:kCGBlendModeNormal alpha:opacity];
        [UIView endEtchedDraw];
        
    } onTap:^(CGPoint touchPoint) {
        OptionNode *optionNode = (OptionNode *)blockSelf.node;
        if (optionNode.secondaryAction)
        {
            optionNode.secondaryAction();
        }
    }];
    [self.containerView addOverlay:self.secondaryButtonOverlay];
    self.secondaryButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  
  CGRect valueRect = CGRectCropToRight(textRect, 140.);
  self.valueOverlay = [JMViewOverlay overlayWithFrame:valueRect drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    OptionNode *optionNode = (OptionNode *)blockSelf.node;
    UIColor *valueColor = optionNode.valueColor ?: optionNode.titleColor;
    [valueColor set];
    
    NSString *fontKey = bold ? kBundleFontOptionTitleBold : kBundleFontOptionTitle;
    [optionNode.valueTitle drawInRect:bounds withFont:[UIFont skinFontWithName:fontKey] lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentRight];
  }];
  self.valueOverlay.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
  [self.containerView addOverlay:self.valueOverlay];
}

- (void)updateWithNode:(JMOutlineNode *)node;
{
    [super updateWithNode:node];
    OptionNode *optionNode = (OptionNode *)self.node;
    self.secondaryButtonOverlay.hidden = (optionNode.secondaryIcon == nil);
    self.secondaryButtonOverlay.allowTouchPassthrough = (optionNode.secondaryAction == nil);
    self.valueOverlay.hidden = JMIsEmpty(optionNode.valueTitle);
    self.iconSeparatorOverlay.hidden = !optionNode.icon;
}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];
    OptionNode *optionNode = (OptionNode *)self.node;
    self.titleOverlay.left = (optionNode.icon == nil) ? 16. : 57.;
    self.iconOverlay.left = 13.;
    CGFloat valueRightMargin = optionNode.i_disclosureStyle == OptionDisclosureStyleNone ? 20. : 40.;
    self.valueOverlay.right = self.bounds.size.width - valueRightMargin;
}

- (void)drawDivider;
{
    [UIView startEtchedDraw];
    [[UIColor colorForSoftDivider] set];
    [[UIBezierPath bezierPathWithRect:CGRectMake(10., self.height - 1., self.width - 20., 1.)] fill];    
    [UIView endEtchedDraw];
}

- (void)decorateCellBackground;
{
    self.cellBackgroundColor = [UIColor colorForBackground];
  
    OptionNode *optionNode = (OptionNode *)self.node;

    UIColor *bgColor = (optionNode.backgroundColor != nil) ? optionNode.backgroundColor : [UIColor colorForBackground];
    [bgColor set];

    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [bgPath fill];
    
    if (self.highlighted || self.selected)
    {
        UIColor *highlightColor = [Resources isNight] ? [UIColor colorWithWhite:1. alpha:0.04] : [UIColor colorWithWhite:0. alpha:0.02];
        [highlightColor set];
        [bgPath fill];
    }
    else if (!optionNode.hidesDivider)
    {
        [self drawDivider];
    }
}

- (NSString *)accessibilityLabel;
{
  OptionNode *optionNode = (OptionNode *)self.node;
  return optionNode.title;
}

@end
