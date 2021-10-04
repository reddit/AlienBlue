//
//  SubredditFolder.h
//  AlienBlue
//
//  Created by J M on 8/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Subreddit.h"

@interface SubredditFolder : NSObject <NSCoding>
@property (strong) NSMutableArray *subreddits;
@property (strong) NSString *title;
@property (strong) NSString *ident;
@property BOOL collapsed;

+ (SubredditFolder *)folderWithTitle:(NSString *)title;

- (BOOL)containsSubreddit:(Subreddit *)subreddit;

- (void)addSubreddit:(Subreddit *)subreddit;
- (void)removeSubreddit:(Subreddit *)subreddit;
- (void)insertSubreddit:(Subreddit *)subreddit atIndex:(NSUInteger)nIndex;

- (void)sortAlphabetically;
- (NSString *)aggregateUrl;
@end
