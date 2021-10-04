//
//  CommentSeparatorBar.m
//  AlienBlue
//
//  Created by J M on 19/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentSeparatorBar.h"
#import "Resources.h"

@interface CommentSeparatorBar()
@property NSUInteger commentCount;
@property BOOL i_shouldDrawLineWithoutArrow;
@end

@implementation CommentSeparatorBar

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.allowTouchPassthrough = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
  if (self.i_shouldDrawLineWithoutArrow)
  {
    CGRect lineRect = CGRectCropToTop(self.bounds, 1.);
    lineRect = CGRectInset(lineRect, 10., 0.);
    [[UIColor colorForDivider] setFill];
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRect:lineRect];
    [linePath fill];
  }
  else
  {
    CGRect dividerRect = CGRectCenterWithSize(self.bounds, CGSizeMake(self.bounds.size.width, 12.));
    dividerRect = CGRectInset(dividerRect, 10., 0.);
    [UIView jm_drawHorizontalArrowDividerInRect:dividerRect color:[UIColor colorForDivider] edgeFadeRatio:0. flipped:YES];
  }
  
//  [[UIColor colorForBevelInnerShadow] set];
//  [[UIBezierPath bezierPathWithRect:CGRectMake(0., 0., self.bounds.size.width, 1.)] fill];
}

- (void)updateWithCommentCount:(NSUInteger)commentCount;
{
  self.commentCount = commentCount;
  [self setNeedsDisplay];
}

- (void)setShouldDrawLineWithoutArrow:(BOOL)shouldDrawLineWithoutArrow;
{
  self.i_shouldDrawLineWithoutArrow = shouldDrawLineWithoutArrow;
  [self setNeedsDisplay];
}

@end
