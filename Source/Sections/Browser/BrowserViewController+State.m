//
//  BrowserViewController+State.m
//  AlienBlue
//
//  Created by J M on 7/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "BrowserViewController+State.h"
#import "Resources.h"

@implementation BrowserViewController (State)

- (id)initWithState:(NSDictionary *)state;
{
    NSString *url = [state objectForKey:@"url"];
    Post *post = [state objectForKey:@"post"];
    
    BrowserViewController *browserController = nil;
    if (post)
    {
        browserController = [self initWithPost:post];
    }
    else
    {
        browserController = [self initWithUrl:url];
    }
    return browserController;
}

- (NSDictionary *)state;
{
    NSMutableDictionary *state = [NSMutableDictionary dictionary];
    if (self.URL)
    {
      [state setObject:self.URL.absoluteString forKey:@"url"];
    }
    if (self.post)
    {
        [state setObject:self.post forKey:@"post"];        
    }
    return state;
}

@end
