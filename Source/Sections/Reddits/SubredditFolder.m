//
//  SubredditFolder.m
//  AlienBlue
//
//  Created by J M on 8/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SubredditFolder.h"
#import "NSArray+BlocksKit.h"

@implementation SubredditFolder

+ (SubredditFolder *)folderWithTitle:(NSString *)title;
{
    SubredditFolder *folder = [[SubredditFolder alloc] init];
    folder.title = title;
    folder.ident = title;
    folder.subreddits = [NSMutableArray array];
    return folder;
}

// compare via urls... pointers/objects may be different, but we should
// treat subreddits with matching urls as equivalent objects
- (Subreddit *)itemMatchingSubreddit:(Subreddit *)subreddit;
{
    Subreddit *match = [self.subreddits match:^BOOL(Subreddit *existingSubreddit) {
        return [existingSubreddit.url equalsString:subreddit.url];
    }];
    return match;
}

- (BOOL)containsSubreddit:(Subreddit *)subreddit;
{
    return [self itemMatchingSubreddit:subreddit] != nil;
}

- (void)insertSubreddit:(Subreddit *)subreddit atIndex:(NSUInteger)nIndex;
{
    if (![self containsSubreddit:subreddit])
    {
        [self.subreddits insertObject:subreddit atIndex:nIndex];
    }
}

- (void)addSubreddit:(Subreddit *)subreddit;
{
    [self insertSubreddit:subreddit atIndex:[self.subreddits count]];
}

- (void)removeSubreddit:(Subreddit *)subreddit;
{
    [self.subreddits removeObject:[self itemMatchingSubreddit:subreddit]];
}

- (void)sortAlphabetically;
{
    [self.subreddits sortUsingComparator:^NSComparisonResult(Subreddit *obj1, Subreddit *obj2) {
        return [obj1.title localizedCaseInsensitiveCompare:obj2.title];
    }];
}

- (NSString *)aggregateUrl;
{
    NSString *url = [self.subreddits reduce:@"/r/" withBlock:^id(NSString * sum, Subreddit *sr) {
        NSMutableString *sUrl = [NSMutableString stringWithString:sr.url];
        [sUrl removeOccurrencesOfString:@"/r/"];
        [sUrl removeOccurrencesOfString:@"/"];
        [sUrl removeOccurrencesOfString:@" "];
        return [sum stringByAppendingFormat:@"%@+", sUrl];
    }];
    
    return [[url stringByAppendingString:@"/"] stringByReplacingOccurrencesOfString:@"+/" withString:@"/"];
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subreddits forKey:@"subreddits"];
    [aCoder encodeObject:self.ident forKey:@"ident"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.collapsed] forKey:@"collapsed"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    SubredditFolder *folder = nil;
    NSString *title = [aDecoder decodeObjectForKey:@"title"];
    NSString *ident = [aDecoder decodeObjectForKey:@"ident"];
    NSArray *subreddits = [aDecoder decodeObjectForKey:@"subreddits"];
    BOOL collapsed = [[aDecoder decodeObjectForKey:@"collapsed"] boolValue];
    if (title && subreddits && ident)
    {
        folder = [[SubredditFolder alloc] init];
        folder.title = title;
        folder.ident = ident;
        folder.subreddits = [NSMutableArray arrayWithArray:subreddits];
        folder.collapsed = collapsed;
    }
    
    return folder;
}

@end
