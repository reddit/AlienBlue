//
//  NBaseStyledTextCell.m
//  AlienBlue
//
//  Created by J M on 19/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "NBaseStyledTextCell.h"
#import "Resources.h"
#import <QuartzCore/QuartzCore.h>
#import "ABTableCellDrawerView.h"

#define kLinkOverlayPadding 10.
#define kLinkOverlayPaddingCompact 10.

@implementation NBaseStyledTextCell


+ (CGFloat)indentForCellTextForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    return 0.;
}

+ (CGFloat)minimumHeightForCellTextForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    return 0;
}

+ (CGFloat)heightForCellHeaderForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    return 10.;
}

+ (CGFloat)heightForCellFooterForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    CGFloat height = 0.;
    if (node.selected)
    {
        height += kABTableCellDrawerHeight;
    }
    return height;
}

+ (CGSize)commentTextPadding
{
  return CGSizeMake(11. ,  7.);
}

+ (BOOL)shouldExpandTextToFullWidthWhenSelected;
{
  return YES;
}

+ (CGRect)rectForCommentBodyInNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    // This is a hack to make sure we don't get 'inf' CGRect values after the calculation
    if (bounds.size.height == 0)
        bounds.size.height = 30.;
    
    CGRect cellRect;
    if (node.selected && [[self class] shouldExpandTextToFullWidthWhenSelected])
        cellRect = bounds;
    else
    {
        cellRect = [JMOutlineCell cellInsetForNode:node constrainedToSize:CGSizeMake(bounds.size.width, bounds.size.height)];
        CGFloat textIndent = [[self class] indentForCellTextForNode:node bounds:bounds];
        cellRect.origin.x += textIndent;
        cellRect.size.width -= textIndent;
    }

    CGFloat topMargin = [[self class] heightForCellHeaderForNode:node bounds:bounds];
    CGSize commentTextPadding = [[self class] commentTextPadding];
    CGRect commentRect = CGRectInset(cellRect, commentTextPadding.width, commentTextPadding.height);
    commentRect.size.height = [node heightForBodyConstrainedToWidth:commentRect.size.width];
    commentRect.origin.y += topMargin;
    return commentRect;
}

+ (CGFloat)heightForCellBody:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    CGFloat cellHeaderHeight = [[self class] heightForCellHeaderForNode:(BaseStyledTextNode *)node bounds:tableView.bounds];
    CGFloat cellFooterHeight = [[self class] heightForCellFooterForNode:(BaseStyledTextNode *)node bounds:tableView.bounds];
    if (node.state == JMOutlineNodeStateHidden) return 0.;
    if (node.state == JMOutlineNodeStateCollapsed) return cellHeaderHeight;
    
    BaseStyledTextNode *commentNode = (BaseStyledTextNode *)node;
    CGFloat height = 0.;
    
    CGRect bodyRect = [[self class] rectForCommentBodyInNode:commentNode bounds:tableView.bounds];
    CGSize commentTextPadding = [[self class] commentTextPadding];
    height += (commentTextPadding.height * 2);
    
    height += cellHeaderHeight;
    CGFloat textHeight = [commentNode heightForBodyConstrainedToWidth:bodyRect.size.width];
    height += textHeight;
    
    if ([commentNode.thumbLinks count] > 0 && [UDefaults boolForKey:kABSettingKeyShowFootnotedLinksOnComments])
    {
        height += [LinkThumbsOverlay heightForLinkThumbsOverlayForNode:commentNode constrainedToWidth:tableView.bounds.size.width textWidth:bodyRect.size.width];
        height += 10.;
    }
    
    CGFloat minimumHeight = [[self class] minimumHeightForCellTextForNode:commentNode bounds:tableView.bounds];
    
    if (height < minimumHeight)
        height = minimumHeight;
    
    height += cellFooterHeight;
    return height;    
}

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    return [[self class] heightForCellBody:node tableView:tableView];
}

- (void)applyGestureRecognizers;
{
//    GestureActionBlock selectAction = ^(UIGestureRecognizer *gesture) {
//        if (([gesture isKindOfClass:[UISwipeGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateEnded) ||
//            ([gesture isKindOfClass:[UILongPressGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateBegan))
//            [blockSelf.node.delegate selectNode:blockSelf.node];
//    };
//    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithActionBlock:selectAction];
//    longPressGesture.delegate = self.containerView;
//    [self.containerView addGestureRecognizer:longPressGesture];
//    
//    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:selectAction];
//    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
//    rightSwipeGesture.delegate = self.containerView;
//    [self.containerView addGestureRecognizer:rightSwipeGesture];
//    
//    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:selectAction];
//    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//    leftSwipeGesture.delegate = self.containerView;
//    [self.containerView addGestureRecognizer:leftSwipeGesture];
}

- (void)createSubviews;
{
    self.cellBackgroundColor = [UIColor colorForBackground];
  
    self.containerView.forceOverlayRedrawOnTouchAndRelease = NO;
    [self applyGestureRecognizers];
    
    BSELF(NBaseStyledTextCell);
    
    self.linkThumbsOverlay = [[LinkThumbsOverlay alloc] initWithFrame:CGRectMake(0, 0, self.width, 10.)];
    self.linkThumbsOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.containerView addOverlay:self.linkThumbsOverlay];    
    
    self.bodyOverlay = [[StyledTextOverlay alloc] init];
    self.bodyOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bodyOverlay.linkTapped = ^(NSString *tappedLink, CGPoint touchPoint)
    {
        CGPoint localisedPoint = CGPointMake(touchPoint.x + blockSelf.bodyOverlay.frame.origin.x, touchPoint.y + blockSelf.bodyOverlay.frame.origin.y);
        if (tappedLink)
        {
            [blockSelf didTapUrl:tappedLink atLocalisedPoint:localisedPoint];
        }
        else
        {
            [blockSelf didTapContents];
        }
    };
    
    self.bodyOverlay.linkPressed = ^(NSString *pressedLink, CGPoint touchPoint)
    {
      CGPoint localisedPoint = CGPointMake(touchPoint.x + blockSelf.bodyOverlay.frame.origin.x, touchPoint.y + blockSelf.bodyOverlay.frame.origin.y);
      if (!JMIsEmpty(pressedLink))
      {
        [blockSelf didPressUrl:pressedLink atLocalisedPoint:localisedPoint];
      }
    };
    
    [self.containerView addOverlay:self.bodyOverlay];
}

- (void)didTapContents;
{
  [self.node.delegate selectNode:self.node];
}

- (void)didTapUrl:(NSString *)url atLocalisedPoint:(CGPoint)localisedPoint;
{
  [self.node.delegate performSelector:@selector(coreTextURLPressed:) withObject:url];
}

- (void)didPressUrl:(NSString *)url atLocalisedPoint:(CGPoint)localisedPoint;
{
}

- (void)updateSubviews;
{
    BaseStyledTextNode *styledNode = (BaseStyledTextNode *)self.node;
    
    [self.bodyOverlay updateWithAttributedString:styledNode.styledText];
    
    [self.linkThumbsOverlay updateForNode:styledNode];
    
    // update drawer
    BSELF(NBaseStyledTextCell);
    [UIView jm_excludeFromAnimation:^{
      [blockSelf attachOptionsDrawerIfNecessary];
    }];
}

- (void)attachOptionsDrawerIfNecessary;
{
  [self.drawerView removeFromSuperview];
  if (self.node.selected)
  {
    self.drawerView = [[CommentOptionsDrawerView alloc] initWithNode:self.node];
    self.drawerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.drawerView.top = self.containerView.height - kABTableCellDrawerHeight;
    self.drawerView.width = self.containerView.width;
    self.drawerView.delegate = self.node.delegate;
    [self.containerView addSubview:self.drawerView];
  }
  else
  {
    self.drawerView = nil;
  }
  
  [self layoutCellOverlays];
}

- (void)layoutCellOverlays;
{
    self.bodyOverlay.hidden = !(self.node.state == JMOutlineNodeStateNormal);
    self.bodyOverlay.frame = [[self class] rectForCommentBodyInNode:(BaseStyledTextNode *)self.node bounds:self.bounds];
    
    BOOL hideThumbs = !([UDefaults boolForKey:kABSettingKeyShowFootnotedLinksOnComments]);
    
    self.linkThumbsOverlay.hidden = (hideThumbs || self.node.hidden || self.node.collapsed || [[(BaseStyledTextNode *)self.node thumbLinks] count] == 0);
    if (!self.linkThumbsOverlay.hidden)
    {
        self.linkThumbsOverlay.commentTextRect = self.bodyOverlay.frame;
        CGFloat linkOverlayPadding = [Resources compact] ? kLinkOverlayPaddingCompact : kLinkOverlayPadding;
        self.linkThumbsOverlay.top = CGRectGetMaxY(self.bodyOverlay.frame) + linkOverlayPadding;
        self.linkThumbsOverlay.height = [LinkThumbsOverlay heightForLinkThumbsOverlayForNode:(BaseStyledTextNode *)self.node constrainedToWidth:self.width textWidth:self.bodyOverlay.width];
    }
    
    self.drawerView.hidden = !(self.node.state == JMOutlineNodeStateNormal);
}

- (void)decorateCellBackground;
{
    UIColor *backgroundColor = [UIColor colorForBackground];
    [backgroundColor set];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    
    if (self.highlighted || self.node.selected)
    {
        [[UIColor colorForRowHighlight] set];
        CGRect bgBounds = CGRectInsetTop(self.bounds, [[self class] heightForCellHeaderForNode:(BaseStyledTextNode *)self.node bounds:self.bounds]);
        [[UIBezierPath bezierPathWithRect:bgBounds] fill];
    }
}

- (void)decorateCell;
{
}

@end
