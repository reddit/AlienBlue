//
//  Subreddit+Discovery.m
//  AlienBlue
//
//  Created by J M on 16/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "Subreddit+Discovery.h"

@implementation Subreddit (Discovery)

SYNTHESIZE_ASSOCIATED_BOOL(hasDiscoveryIcon, HasDiscoveryIcon);
SYNTHESIZE_ASSOCIATED_FLOAT(popularityRating, PopularityRating);

- (id)initWithDiscoveryDictionary:(NSDictionary *)d;
{
    self = [super init];
    if (self)
    {
        self.title = [d objectForKey:@"title"];
        self.url = [NSString stringWithFormat:@"/r/%@/", self.title];
        self.name = @"";
        self.numSubscribers = [[d objectForKey:@"subscribers"] unsignedIntegerValue];
        self.hasDiscoveryIcon = [[d objectForKey:@"icon"] boolValue];
        self.popularityRating = [[d objectForKey:@"popularity"] floatValue];
    }
    return self;
}

@end
