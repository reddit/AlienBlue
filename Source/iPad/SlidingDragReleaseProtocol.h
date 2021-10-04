//
//  SlidingDragReleaseCompatible.h
//  AlienBlue
//
//  Created by J M on 23/03/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SlidingDragReleaseProtocol <NSObject>
- (BOOL)canDragRelease;
- (NSString *)titleForDragReleaseLabel;
- (void)didDragRelease;

@optional

- (NSString *)iconNameForDragReleaseDestination;

@end
