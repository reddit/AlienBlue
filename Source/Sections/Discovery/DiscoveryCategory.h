//
//  Category.h
//  AlienBlue
//
//  Created by J M on 16/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Subreddit.h"

@interface DiscoveryCategory : NSObject
@property (strong) NSString *title;
@property (strong) NSString *ident;
@property (strong) NSString *iconIdent;

@property (strong) NSArray *subCategories;
@property (strong) NSArray *subreddits;

- (id)initWithDiscoveryDictionary:(NSDictionary *)d;

+ (void)recommendSubreddit:(NSString *)subreddit forCategory:(DiscoveryCategory *)category onComplete:(ABAction)onComplete;
@end
