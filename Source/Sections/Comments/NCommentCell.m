//
//  NCommentCell.m
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "NCommentCell.h"
#import "CommentHeaderBarOverlay.h"
#import "Resources.h"
#import "CommentSeparatorBar.h"
#import "VoteOverlay.h"
#import "ABHoverPreviewView.h"

#define kFirstCommentHeaderOffset 4.
#define kVoteIconsHeight 92.

@interface NCommentCell()
@property (strong) CommentHeaderBarOverlay *headerBar;
@property (strong) ThreadLinesOverlay *threadLinesOverlay;
@property (strong) CommentSeparatorBar *separatorBar;
@property (strong) VoteOverlay *voteOverlay;
@property (strong) JMViewOverlay *dottedLineSeparatorOverlay;
@end

@implementation NCommentCell

+ (CGFloat)indentForCellTextForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    return [Resources showCommentVotingIcons] ? 23. : 0.;
}

+ (CGFloat)heightForCellHeaderForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    CGFloat height = kCommentHeaderBarOverlayHeight;
    if ([(CommentNode *)node firstComment])
        height += kFirstCommentHeaderOffset;
    return height;
}

+ (CGFloat)minimumHeightForCellTextForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
{
    if ([Resources showCommentVotingIcons] && !node.selected && node.state == JMOutlineNodeStateNormal)
    {
        CGFloat minHeight = kVoteIconsHeight;
        CommentNode *commentNode = (CommentNode *)node; 
        if (commentNode.firstComment)
            minHeight += kFirstCommentHeaderOffset;
        return minHeight;
    }
    else
    {
        return [NBaseStyledTextCell minimumHeightForCellTextForNode:node bounds:bounds];
    }
}

- (Comment *)comment
{
    CommentNode *node = (CommentNode *)self.node;
    return node.comment;
}

- (void)applyGestureRecognizers;
{
    [super applyGestureRecognizers];
    self.containerView.alwaysAllowOverlayGestureRecognizers = YES;
    
    BSELF(NCommentCell);    
    
    UITapGestureRecognizer *downvoteGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *gesture) {
        [blockSelf.node.delegate performSelector:@selector(voteDownCommentNode:) withObject:blockSelf.node];
    }];
    downvoteGesture.numberOfTapsRequired = 1;
    downvoteGesture.numberOfTouchesRequired = 3;
    downvoteGesture.delaysTouchesEnded = NO;
    downvoteGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:downvoteGesture];

    
    UITapGestureRecognizer *upvoteGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *gesture) {
        [blockSelf.node.delegate performSelector:@selector(voteUpCommentNode:) withObject:blockSelf.node];
    }];
    upvoteGesture.numberOfTapsRequired = 1;
    upvoteGesture.numberOfTouchesRequired = 2;
//    [upvoteGesture requireGestureRecognizerToFail:downvoteGesture];
    upvoteGesture.delaysTouchesEnded = NO;
    upvoteGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:upvoteGesture];

    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:^(UISwipeGestureRecognizer *gesture) {
        CGPoint touchPoint = [gesture locationInView:blockSelf.containerView];
        if (touchPoint.x > (blockSelf.containerView.width / 2.))
        {
            [blockSelf.node.delegate performSelector:@selector(collapseToRootCommentNode:) withObject:blockSelf.node];
        }
    }];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:leftSwipeGesture];

    

    if (![Resources isIPAD])
    {
        UISwipeGestureRecognizer *oneFingerRightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:^(UISwipeGestureRecognizer *gesture) {
            [blockSelf.node.delegate selectNode:blockSelf.node];
        }];
        oneFingerRightSwipeGesture.numberOfTouchesRequired = 1;
        oneFingerRightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        oneFingerRightSwipeGesture.delegate = self.containerView;
        [self.containerView addGestureRecognizer:oneFingerRightSwipeGesture];
        
        UISwipeGestureRecognizer *twoFingerRightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:^(UISwipeGestureRecognizer *gesture) {
            [blockSelf.node.delegate performSelector:@selector(focusContextCommentNode:) withObject:blockSelf.node];
        }];
        twoFingerRightSwipeGesture.numberOfTouchesRequired = 2;
        twoFingerRightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        twoFingerRightSwipeGesture.delegate = self.containerView;
        [self.containerView addGestureRecognizer:twoFingerRightSwipeGesture];
        
        UISwipeGestureRecognizer *twoFingerLeftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:^(UISwipeGestureRecognizer *gesture) {
            [blockSelf.node.delegate performSelector:@selector(focusContextCommentNode:) withObject:blockSelf.node];
        }];
        twoFingerLeftSwipeGesture.numberOfTouchesRequired = 2;
        twoFingerLeftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        twoFingerLeftSwipeGesture.delegate = self.containerView;
        [self.containerView addGestureRecognizer:twoFingerLeftSwipeGesture];

    }
    
    //    GestureActionBlock selectAction = ^(UIGestureRecognizer *gesture) {
    //        if (([gesture isKindOfClass:[UISwipeGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateEnded) ||
    //            ([gesture isKindOfClass:[UILongPressGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateBegan))
    //            [blockSelf.node.delegate selectNode:blockSelf.node];
    //    };
    //    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithActionBlock:selectAction];
    //    longPressGesture.delegate = self.containerView;
    //    [self.containerView addGestureRecognizer:longPressGesture];

}

- (void)createSubviews;
{
    self.threadLinesOverlay = [[ThreadLinesOverlay alloc] initWithFrame:self.containerView.bounds];
    self.threadLinesOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addOverlay:self.threadLinesOverlay];

    [super createSubviews];
    
    BSELF(NCommentCell);
    
    self.headerBar = [[CommentHeaderBarOverlay alloc] initWithFrame:CGRectMake(0, 0, self.containerView.width, kCommentHeaderBarOverlayHeight)];
    self.headerBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerBar.horizontalPadding = 2.;
    self.headerBar.onTap = ^(CGPoint touchPoint) {
        [blockSelf.node.delegate toggleNode:blockSelf.node];
    };
    [self.containerView addOverlay:self.headerBar];
        
    // draw the arrow tip of the comment/post header separator to make it look continuous between cells
    self.separatorBar = [[CommentSeparatorBar alloc] initWithFrame:CGRectMake(0., 0., self.width, kCommentSeparatorBarHeight)];
    self.separatorBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.containerView addOverlay:self.separatorBar];
    
    self.voteOverlay = [[VoteOverlay alloc] init];
    [self.containerView addOverlay:self.voteOverlay atIndex:0];
  
    self.dottedLineSeparatorOverlay = [JMViewOverlay overlayWithSize:CGSizeMake(0., 2.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
      [UIView jm_drawHorizontalDottedLineInRect:bounds lineWidth:1 lineColor:[UIColor colorForDivider]];
    }];
    [self.containerView addOverlay:self.dottedLineSeparatorOverlay];
}

- (void)updateSubviews;
{
    [super updateSubviews];    

    [self.headerBar updateForCommentNode:(CommentNode *)self.node];

    [self.threadLinesOverlay updateWithLevel:self.node.level];
    [self.voteOverlay updateWithVotableElement:[(CommentNode *)self.node comment]];
  
    self.separatorBar.hidden = ![(CommentNode *)self.node firstComment];
    if (!self.separatorBar.hidden)
    {
      Comment *comment = [(CommentNode *)self.node comment];
      NSString *flair = comment.flairText;
      BOOL commentDrawsFlair = flair && ![flair isEmpty] && [UDefaults boolForKey:kABSettingKeyShowCommentFlair];
      [self.separatorBar setShouldDrawLineWithoutArrow:commentDrawsFlair];
    }
  
    self.dottedLineSeparatorOverlay.hidden = [(CommentNode *)self.node firstComment];
}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];
    CommentNode *commentNode = (CommentNode *)self.node;
    self.headerBar.top = commentNode.firstComment ? kFirstCommentHeaderOffset : 2.;
    
    self.threadLinesOverlay.hidden = (self.node.hidden || self.node.collapsed || self.node.selected);
    self.voteOverlay.hidden = (![Resources showCommentVotingIcons] || self.node.hidden || self.node.collapsed || self.node.selected);
    
    self.voteOverlay.top = CGRectGetMaxY(self.headerBar.frame) + 4.;
    self.voteOverlay.left = self.bodyOverlay.left - 44.;
  
    self.dottedLineSeparatorOverlay.left = self.bodyOverlay.left;
    self.dottedLineSeparatorOverlay.width = self.bodyOverlay.width;
    self.dottedLineSeparatorOverlay.top = 0.;
}

- (void)didTapUrl:(NSString *)url atLocalisedPoint:(CGPoint)localisedPoint;
{
  if ([ABHoverPreviewView hasRecentlyDismissedPreview])
    return;
  
  [ABHoverPreviewView cancelVisiblePreviewAnimated:NO];
  [self.node.delegate performSelector:@selector(coreTextURLPressed:) withObject:url];
}

- (void)didPressUrl:(NSString *)url atLocalisedPoint:(CGPoint)localisedPoint;
{
  NSURL *URLToPreview = url.URL;
  if (![ABHoverPreviewView canShowPreviewForURL:URLToPreview])
    return;
  
  CGRect localContainerRect = [self.containerView jm_globalFrame];
  CGRect showFromRect = CGRectMake(localContainerRect.origin.x + localisedPoint.x, localContainerRect.origin.y + localisedPoint.y, 1., 1.);
  showFromRect = CGRectInset(showFromRect, -10., -10.);
  [ABHoverPreviewView showPreviewForURL:URLToPreview fromRect:showFromRect onSuccessfulPresentation:nil];
}

@end
