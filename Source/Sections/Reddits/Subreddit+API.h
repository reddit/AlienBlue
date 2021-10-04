//
//  Subreddit+API.h
//  AlienBlue
//
//  Created by J M on 11/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "Subreddit.h"
#import "AFJSONRequestOperation.h"

@interface Subreddit (API)
+ (AFHTTPRequestOperation *)fetchSubscribedSubredditsUsingCache:(BOOL)useCache onComplete:(void (^)(NSArray *subreddits))onComplete;
+ (AFHTTPRequestOperation *)fetchSubredditInformationForSubredditName:(NSString *)subredditName onComplete:(void (^)(Subreddit *subredditOrNil))onComplete;

+ (void)subscribeToSubredditWithUrl:(NSString *)url;
+ (void)unsubscribeToSubredditWithUrl:(NSString *)url;

@end
