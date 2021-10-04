//
//  RedditsHeaderView_iPad.m
//  AlienBlue
//
//  Created by J M on 19/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsHeaderView_iPad.h"
#import "JMViewOverlay+NavigationButton.h"

@implementation RedditsHeaderView_iPad

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.doneOverlay = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/navbar-done" title:@"Done"];
        self.doneOverlay.right = self.width - 9.;
        self.doneOverlay.top = 4.;
        self.doneOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.doneOverlay];

//        self.editOverlay = [JMViewOverlay buttonWithIcon:@"icons/ipad-navbar/navbar-edit"];
        self.editOverlay = [JMViewOverlay buttonWithTitle:@"Edit"];
        self.editOverlay.right = self.width - 15.;
        self.editOverlay.top = 4.;
        self.editOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.editOverlay];
    }
    return self;
}

- (void)switchMode;
{
    BSELF(RedditsHeaderView_iPad);
    [UIView transitionWithView:self.contentView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        blockSelf.editOverlay.hidden = !blockSelf.editOverlay.hidden;
        blockSelf.doneOverlay.hidden = !blockSelf.doneOverlay.hidden;
        [blockSelf.contentView setNeedsDisplay];
    } completion:nil];
}

//- (void)setEditMode:(BOOL)editMode;
//{
//    BSELF(RedditsHeaderView_iPad);
//    [UIView transitionWithView:self.contentView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        blockSelf.editOverlay.hidden = editMode;
//        blockSelf.doneOverlay.hidden = !editMode;
//    } completion:nil];
//}

@end
