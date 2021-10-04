//
//  Subreddit+Discovery.h
//  AlienBlue
//
//  Created by J M on 16/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "Subreddit.h"

@interface Subreddit (Discovery)
@property CGFloat popularityRating;
@property BOOL hasDiscoveryIcon;

- (id)initWithDiscoveryDictionary:(NSDictionary *)d;

@end
