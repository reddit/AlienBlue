//
//  CommentHeaderBarOverlay.m
//  AlienBlue
//
//  Created by J M on 17/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentHeaderBarOverlay.h"
#import "Comment+Style.h"
#import "JMOutlineCell.h"
#import "Resources.h"
#import "ModButtonOverlay.h"

@interface CommentHeaderBarOverlay()
@property (ab_weak) CommentNode *commentNode;
@property (readonly) BOOL collapsed;
@end

@implementation CommentHeaderBarOverlay

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.allowTouchPassthrough = NO;
    }
    return self;
}

- (void)updateForCommentNode:(CommentNode *)commentNode;
{
    self.commentNode = commentNode;
    [self setNeedsDisplay];
}

- (BOOL)collapsed
{
    return !(self.commentNode.state == JMOutlineNodeStateNormal);
}

- (void)drawModerationIndicatorIfNecessary;
{
  Comment *comment = self.commentNode.comment;
  if (!comment.isModdable)
    return;
  
  CGFloat rightHandMargin = JMIsIpad() ? 9. : 15.;
  UIColor *indicatorColor = [ModButtonOverlay indicatorColorForModState:comment.moderationState];
  CGRect indicatorRect = CGRectMake(self.bounds.size.width - self.horizontalPadding - rightHandMargin, 12., 7., 7.);
  [ModButtonOverlay drawModLightIndicatorWithColor:indicatorColor inRect:indicatorRect];
}

- (void)drawRect:(CGRect)rect;
{
    CGRect bounds = self.bounds;
    Comment *comment = self.commentNode.comment;

    if (self.highlighted)
    {
        UIColor *bgColor = [Resources isNight] ? [UIColor colorWithWhite:0. alpha:0.08] : [UIColor colorWithWhite:0. alpha:0.03];
        [bgColor set];
        CGContextFillRect(UIGraphicsGetCurrentContext(), bounds);
    }
    
//    if (![Resources compact])
//    {
//        //inset
//        UIColor *insetTopColor = [Resources isNight] ? [UIColor colorWithWhite:0. alpha:0.15] : [UIColor colorWithWhite:0. alpha:0.02];
//        UIColor *insetBottomColor = [Resources isNight] ? [UIColor colorWithWhite:1. alpha:0.03] : [UIColor colorWithWhite:1. alpha:0.35];
//        
//        [insetTopColor set];
//        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, bounds.size.width, 1.));
//
//        if (self.commentNode.state == JMOutlineNodeStateNormal)
//        {
//            [insetBottomColor set];
//            CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, bounds.size.height - 1., bounds.size.width, 1.));
//        }
//    }
  
    NSUInteger level = MIN([Resources maxThreadLevel], self.commentNode.level);
//    // indent the first comment triangle at the same level as the root comment
//    if (level > 0) level--;
    CGFloat levelOffset = level * kThreadIndentSize;
    
    levelOffset += self.horizontalPadding;
    
    if ([Resources isIPAD] && ![Resources showCommentVotingIcons])
    {
        levelOffset -= 4.;
    }

    
    NSMutableString *barTitle = [NSMutableString stringWithString:@""];
    for (NSUInteger dotLevel = [Resources maxThreadLevel]; dotLevel < self.commentNode.level; dotLevel++)
    {
        [barTitle appendString:@"• "];
    }
    [barTitle appendFormat:@"%@", comment.author];
  
    UIColor *foregroundColor = self.collapsed ? [UIColor lightGrayColor] : [UIColor colorForHighlightedText];
    if (self.commentNode.isContext)
    {
      foregroundColor = JMHexColor(b76aff);
    }
  
    if ([self.commentNode.comment isMine])
    {
      foregroundColor = [UIColor colorForHighlightedOptions];
    }
    else if ([self.commentNode.comment isFromModerator])
    {
      foregroundColor = [UIColor skinColorForConstructive];
      [barTitle appendString:@" ┊m"];
    }
    else if ([self.commentNode.comment isFromAdmin])
    {
      foregroundColor = JMHexColor(ff222d);
      [barTitle appendString:@" ┊a"];
    }
    else if ([self.commentNode.comment ownershipToUser:self.commentNode.post.author] == OwnershipOperator)
    {
      foregroundColor = [UIColor colorForOpHighlight];
      [barTitle appendString:@" ┊op"];
    }

    [foregroundColor set];
    
    CGFloat yOffset = 7.;

    CGFloat triangleAngle = self.collapsed ? 90. : 180.;
    CGPoint triangleCenter = self.collapsed ? CGPointMake(levelOffset + 16., yOffset + 8.) : CGPointMake(levelOffset + 16., yOffset + 8.);
        
    [[UIBezierPath bezierPathWithTriangleCenter:triangleCenter sideLength:8. angle:triangleAngle] fill];
    
//    NSString *fontKey = [self.commentNode.comment isMine] ? kBundleFontCommentSubdetailsBold: kBundleFontCommentSubdetails;
    UIFont *authorFont = [[ABBundleManager sharedManager] fontForKey:kBundleFontCommentSubdetails];
  
    CGFloat authorHorizontalOffset = [Resources showCommentVotingIcons] ? 33. : 28.;

    [barTitle drawAtPoint:CGPointMake(levelOffset + authorHorizontalOffset, yOffset) withFont:authorFont];
    
    NSString *flair = self.commentNode.comment.flairText;
    
    if (flair && ![flair isEmpty] && [UDefaults boolForKey:kABSettingKeyShowCommentFlair])
    {
        UIColor *flairBgColor = self.collapsed ? [UIColor colorForSoftDivider] : [UIColor colorWithWhite:0.5 alpha:0.1];
        UIColor *flairTextColor = [Resources isNight] ? [UIColor colorWithWhite:0.7 alpha:1.] : [UIColor colorWithWhite:0.6 alpha:1.];
        flairTextColor = self.collapsed ? foregroundColor : flairTextColor;
        CGFloat offset = levelOffset + [barTitle widthWithFont:authorFont] + 40.;
        CGFloat flairWidth = [flair widthWithFont:authorFont] + 14.;
        [flairBgColor set];
        CGRect flairRect = CGRectMake(offset, 6, flairWidth, 18.);
        flairRect.size.width = MIN(flairWidth, self.bounds.size.width - 84. - flairRect.origin.x);
      
        if (flairRect.size.width > 30.)
        {
          [[UIBezierPath bezierPathWithRoundedRect:flairRect cornerRadius:4.] fill];
          [flairTextColor set];
          [flair drawInRect:CGRectOffset(flairRect,0,1.) withFont:authorFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
        }

    }

    UIColor *scoreColor = nil;
    if (self.commentNode.state != JMOutlineNodeStateNormal)
        scoreColor = [UIColor lightGrayColor];
    else if (comment.voteState == VoteStateUpvoted)
        scoreColor = [UIColor colorForUpvote];
    else if (comment.voteState == VoteStateDownvoted)
        scoreColor = [UIColor colorForDownvote];
    else
        scoreColor = [UIColor colorWithWhite:0.5 alpha:1.];
    [scoreColor set];

    NSMutableString *rightHandDetails = [NSMutableString stringWithString:@""];
  
    if (!comment.isScoreHidden)
    {
      [rightHandDetails appendString:comment.formattedScoreTinyWithPlus];
    }

    BOOL showTimestamp = [UDefaults boolForKey:kABSettingKeyAlwaysShowCommentTimestamps];
    if (self.commentNode.selected || showTimestamp)
    {
        if (comment.isScoreHidden)
        {
          [rightHandDetails appendString:@"[h]"];
        }
        [rightHandDetails appendString:@" • "];
        [rightHandDetails appendString:comment.tinyTimeAgo];
    }
  
    CGFloat rightInset = self.horizontalPadding;
    if (comment.isModdable)
    {
      rightInset += 12.;
    }
  
    [rightHandDetails drawInRect:CGRectMake(self.bounds.size.width - 90 - rightInset, yOffset, 80., 20.) withFont:authorFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
  
    [self drawModerationIndicatorIfNecessary];
}

@end
