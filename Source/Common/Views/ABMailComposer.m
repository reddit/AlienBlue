//
//  ABMailComposer.m
//  AlienBlue
//
//  Created by JM on 6/09/10.
//  Copyright (c) 2010 The Design Shed. All rights reserved.
//

#import "ABMailComposer.h"
#import "Resources.h"

@implementation ABMailComposer

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([Resources isIPAD])
        return YES;
    else
        return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
