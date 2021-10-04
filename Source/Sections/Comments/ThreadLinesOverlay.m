//
//  ThreadLinesOverlay.m
//  AlienBlue
//
//  Created by J M on 17/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "ThreadLinesOverlay.h"
#import "JMOutlineCell.h"
#import "Resources.h"

@interface ThreadLinesOverlay()
@property NSUInteger level;
@end

@implementation ThreadLinesOverlay

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.allowTouchPassthrough = YES;
        self.redrawsOnTouch = NO;
    }
    return self;
}

- (void)updateWithLevel:(NSUInteger)level;
{
    self.level = level;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect;
{ 
    [[UIColor colorForSoftDivider] set];
    NSUInteger level = MIN([Resources maxThreadLevel], self.level);
    for (int i=0; i<level; i++)
    {
        CGFloat offsetX = (i+1) * kThreadIndentSize - (0.5 * kThreadIndentSize) + 5.;
        CGRect lineRect = CGRectMake(offsetX, 0, 1., self.bounds.size.height);
        lineRect = CGRectInset(lineRect, 0., 5.);
        [[UIBezierPath bezierPathWithRect:lineRect] fill];
    }
}

@end
