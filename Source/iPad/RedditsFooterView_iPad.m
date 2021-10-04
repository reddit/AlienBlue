//
//  RedditsFooterView_iPad.m
//  AlienBlue
//
//  Created by J M on 14/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "RedditsFooterView_iPad.h"
#import "JMViewOverlay+NavigationButton.h"
#import "NavigationManager_iPad.h"

@interface RedditsFooterView_iPad()
@property (strong) JMViewOverlay *secondaryBackgroundOverlay;
@end

@implementation RedditsFooterView_iPad

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    {
        self.straightEdged = YES;
        
        self.secondaryBackgroundOverlay = [JMViewOverlay overlayWithFrame:self.contentView.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
            [[UIColor colorForBackgroundAlt] set];
            [[UIBezierPath bezierPathWithRect:bounds] fill];
            
            [[UIColor colorForDivider] set];
            [[UIBezierPath bezierPathWithRect:CGRectMake(0., 0., bounds.size.width, 1.)] fill];
        }];
        self.secondaryBackgroundOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addOverlay:self.secondaryBackgroundOverlay];
        
        self.foldersButtonOverlay = [JMViewOverlay buttonWithIcon:@"icons/folder" title:@"Groups" titleOffset:24.];
        self.foldersButtonOverlay.left = 10.;
        self.foldersButtonOverlay.top = 4.;
        [self.contentView addOverlay:self.foldersButtonOverlay];
        
        self.sortButtonOverlay = [JMViewOverlay buttonWithIcon:@"icons/sort"];
        self.sortButtonOverlay.top = 6.;
        self.sortButtonOverlay.right = self.contentView.width - 10.;
        self.sortButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addOverlay:self.sortButtonOverlay];
    }
    return self;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];

    CGFloat foldersButtonOffset = 10.;
    if (![NavigationManager_iPad foldingNavigation].showingSidePane)
        foldersButtonOffset += 100.;
    self.foldersButtonOverlay.left = foldersButtonOffset;
}

@end
