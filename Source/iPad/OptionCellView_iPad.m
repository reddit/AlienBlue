//
//  OptionCellView_iPad.m
//  AlienBlue
//
//  Created by J M on 18/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "OptionCellView_iPad.h"
#import "Resources.h"

@implementation OptionCellView_iPad

- (void)drawTitleBackground;
{
    // draw header background
    CGRect bgRect = CGRectOffset(CGRectInset(self.bounds,0, 2.), 0, -10.);
    [[UIColor colorForBackground] set];
    [[UIBezierPath bezierPathWithRect:bgRect] fill];

    [UIView startEtchedDraw];
    
    [[UIColor colorForDivider] set];
    [[UIBezierPath bezierPathWithRect:CGRectMake(14., self.bounds.size.height - 13., self.bounds.size.width - 28, 1.)] fill];
    
    [UIView endEtchedDraw];
}

@end
