//
//  NMyRedditInfoCell.m
//  AlienBlue
//
//  Created by J M on 13/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NMyRedditInfoCell.h"

@implementation MyRedditInfoNode

+ (Class)cellClass;
{
    return NSClassFromString(@"NMyRedditInfoCell");
}

@end

@implementation NMyRedditInfoCell

- (void)layoutCellOverlays;
{
  [super layoutCellOverlays];
}

@end
