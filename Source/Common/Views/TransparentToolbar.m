//
//  TransparentToolbar.m
//  AlienBlue
//
//  Created by JM on 30/08/10.
//  Copyright (c) 2010 The Design Shed. All rights reserved.
//

#import "TransparentToolbar.h"

@implementation TransparentToolbar

// Override draw rect to avoid
// background coloring
- (void)drawRect:(CGRect)rect 
{
    [self handleTintSwitch];
}

// Set properties to make background
// translucent.
- (void) applyTranslucentBackground
{
	if (JMIsNight())
		[self setBarStyle:UIBarStyleBlack];
	else
		[self setBarStyle:UIBarStyleDefault];

	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.translucent = YES;
}

// Override init.
- (id) init
{
	self = [super init];
    if (self)
    {
        [self applyTranslucentBackground];
      self.jmShadowImageView.hidden = YES;
      self.upArrowImageView.hidden = YES;
    }
	return self;
}

// Override initWithFrame.
- (id) initWithFrame:(CGRect) frame
{
	self = [super initWithFrame:frame];
    if (self)
    {
        [self applyTranslucentBackground];
        [self registerForNotifications];
        self.jmShadowImageView.hidden = YES;
        self.upArrowImageView.hidden = YES;
    }
	return self;
}

- (void)handleTintSwitch;
{
}

- (void)setFrame:(CGRect)frame;
{
  CGFloat horizontalAdjustment = JMIsIOS7() ? 15. : 9.;
  CGFloat verticalAdjustment = 2.;
  frame.origin.x += horizontalAdjustment;
  frame.origin.y += verticalAdjustment;

  [super setFrame:frame];
}

@end
