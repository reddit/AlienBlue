//
//  Subreddit.h
//  AlienBlue
//
//  Created by J M on 7/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Subreddit : NSObject <NSCoding>
@property (strong) NSDictionary *rawDictionary;
@property (strong) NSString *title;
@property (strong) NSString *longTitle;
@property (strong) NSString *subredditDescription;
@property (strong) NSString *url;
@property (strong) NSString *ident;
@property (strong) NSString *name;
@property (strong) NSString *submitRulesText;
@property (strong) NSString *submitRulesHtml;
@property (strong) NSString *submitAllowedTypesText;
@property (readonly, strong) NSString *iconIdent;

@property BOOL nsfw;
@property NSUInteger numSubscribers;

@property (readonly) BOOL subscribed;

@property (readonly) BOOL allowsSelfPosts;
@property (readonly) BOOL allowsLinkPosts;

+ (Subreddit *)subredditFromDictionary:(NSDictionary *)dictionary;
+ (Subreddit *)subredditWithUrl:(NSString *)url name:(NSString *)name;

- (BOOL)isNativeSubreddit;
@end
