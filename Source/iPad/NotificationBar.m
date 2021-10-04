//
//  NotificationBar.m
//  AlienBlue
//
//  Created by J M on 4/03/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NotificationBar.h"
#import "Resources.h"

@interface NotificationBar()
@property (strong) UILabel *label;
@end

@implementation NotificationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *bg = [[UIImageView alloc] initWithFrame:self.bounds];
        bg.backgroundColor = JMHexColor(252525);
//        bg.image = [UIImage skinImageNamed:@"common/panel-gradient-dark"];
        bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//        bg.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:bg];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., 200., 40)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.shadowColor = [UIColor blackColor];
        self.label.shadowOffset = CGSizeMake(0., 1.);
        self.label.font = [UIFont boldSystemFontOfSize:13.];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setMessage:(NSString *)message;
{
    self.label.text = message;
    [self.label sizeToFit];
    [self.label centerInSuperView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
