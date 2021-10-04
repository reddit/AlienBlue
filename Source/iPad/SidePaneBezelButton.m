//
//  SidePaneBezelButton.m
//  AlienBlue
//
//  Created by J M on 22/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SidePaneBezelButton.h"

@interface SidePaneBezelButton()
@property (strong) NSString *i_title;
@end


@implementation SidePaneBezelButton

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (NSString *)title;
{
    return self.i_title;
}

- (void)setHighlighted:(BOOL)highlighted;
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)setPaneTitle:(NSString *)title;
{
    self.i_title = [title limitToLength:17.];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect;
{
    UIImage *paneBackground = [UIImage skinImageNamed:@"common/bevel-stretchable"];
    UIImage *paneBG = [paneBackground stretchableImageWithLeftCapWidth:(paneBackground.size.width / 2.) topCapHeight:(paneBackground.size.height / 2.)];
    [paneBG drawInRect:self.bounds];
    if (self.highlighted)
    {
        [paneBG drawInRect:self.bounds];
    }

    if  (self.alternatePresentation)
        [[UIColor orangeColor] set];
    else
        [[UIColor whiteColor] set];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIFont *font = [UIFont boldSystemFontOfSize:13.];
    CGSize titleSize = [self.i_title sizeWithFont:font];
    CGSize titleSizeRotated = CGSizeMake(titleSize.height, titleSize.width);
    CGRect titleFrame = CGRectCenterWithSize(self.bounds, titleSizeRotated);
    titleFrame.origin.y +=titleSize.width;

    [UIView startShadowedDraw];
    [UIView drawVerticalText:self.i_title context:context point:titleFrame.origin font:font];
    [UIView endShadowedDraw];    
}

@end
