//
//  DiscoveryHeaderView_iPad.m
//  AlienBlue
//
//  Created by J M on 16/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "DiscoveryHeaderView_iPad.h"

@implementation DiscoveryHeaderView_iPad

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:self.loadingIndicator];
        self.loadingIndicator.top = 17.;
        self.loadingIndicator.right = self.contentView.width - 14.;
    }
    return self;
}

@end
