//
//  Subreddit+API.m
//  AlienBlue
//
//  Created by J M on 11/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "Subreddit+API.h"
#import "AFHTTPRequestOperation.h"
#import "RedditAPI.h"
#import "RedditAPI+Account.h"
#import "Post+API.h"
#import "Resources.h"
#import "NSDictionary+UrlEncoding.h"
#import "NSMutableURLRequest+Parameters.h"

@implementation Subreddit (API)

+ (AFHTTPRequestOperation *)fetchSubredditsAtPath:(NSString *)path useCache:(BOOL)useCache cacheKey:(NSString *)cacheKey onComplete:(void (^)(NSArray *posts))onComplete;
{
  NSString *url = [NSString stringWithFormat:@"%@/.json?limit=500&un=%@", path, [[RedditAPI shared] authenticatedUser]];
  NSString *cachePrefKey = [NSString stringWithFormat:@"%@_%@_json", [[RedditAPI shared] authenticatedUser], cacheKey];
  NSMutableURLRequest *request = [[RedditAPI shared] requestForUrl:url];
  
  typedef void (^ProcessSubredditsAction)(id JSON);
  
  ProcessSubredditsAction processAction = ^(id JSON)
  {
    // json cache
    NSData *stateArchive = [NSKeyedArchiver archivedDataWithRootObject:JSON];
    [[NSUserDefaults standardUserDefaults] setObject:stateArchive forKey:cachePrefKey];
    
    NSMutableArray *newSubreddits = [NSMutableArray array];
    NSArray *rawApiSubreddits = [JSON valueForKeyPath:@"data.children.data"];
    [rawApiSubreddits each:^(NSDictionary *item) {
      Subreddit *sr = [Subreddit subredditFromDictionary:item];
      [newSubreddits addObject:sr];
    }];
    onComplete(newSubreddits);
  };
  
  if (useCache)
  {
    NSData *stateArchive = [[NSUserDefaults standardUserDefaults] objectForKey:cachePrefKey];
    if (stateArchive)
    {
      id JSON = [NSKeyedUnarchiver unarchiveObjectWithData:stateArchive];
      if (JSON)
      {
        processAction(JSON);
        return nil;
      }
    }
  }
  
  //    DLog(@"network accessing subreddits");
  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                       {
                                         processAction(JSON);
                                       } failure:nil];
  [operation start];
  return operation;
}

+ (AFHTTPRequestOperation *)fetchSubscribedSubredditsUsingCache:(BOOL)useCache onComplete:(void (^)(NSArray *subreddits))onComplete;
{
  return [[self class] fetchSubredditsAtPath:@"/reddits/mine/" useCache:useCache cacheKey:@"subreddits" onComplete:onComplete];  
}

+ (AFHTTPRequestOperation *)i_retrieveIdentForSubredditWithUrl:(NSString *)url onComplete:(void (^)(NSString *subredditIdent))onComplete;
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"limit", nil];
    NSString *requestPath = [NSString stringWithFormat:@"%@.json", url];
    AFHTTPRequestOperation *postFetchOperation = [Post fetchPostsForPath:requestPath params:params onComplete:^(NSArray *posts) {
        if (posts && [posts count] > 0)
        {
            Post *p = [posts first];
            onComplete(p.subredditId);
        }
        else
        {
            DLog(@"failed to retrieve ident for subreddit: %@", url);
        }
    }];
    [postFetchOperation start];
    return postFetchOperation;
}

+ (AFHTTPRequestOperation *)i_performAction:(NSString *)action toSubredditWithIdent:(NSString *)ident;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:ident forKey:@"sr"];
    [params setObject:action forKey:@"action"];
    
    NSString *requestPath = [NSString stringWithFormat:@"/api/subscribe/?%@", [params urlEncodedString]];
    NSMutableURLRequest *request = [[RedditAPI shared] requestForUrl:requestPath];
    [request setHTTPMethod:@"POST"];
        
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
                                         {
//                                             DLog(@"finished action (%@) to ident: %@", action, ident);
                                         } failure:nil];
    
    [operation start];
    return operation;
}

+ (void)subscribeToSubredditWithUrl:(NSString *)url;
{
    [Subreddit i_retrieveIdentForSubredditWithUrl:url onComplete:^(NSString *subredditIdent) {
        [Subreddit i_performAction:@"sub" toSubredditWithIdent:subredditIdent];
    }];
}

+ (void)unsubscribeToSubredditWithUrl:(NSString *)url;
{
    [Subreddit i_retrieveIdentForSubredditWithUrl:url onComplete:^(NSString *subredditIdent) {
        [Subreddit i_performAction:@"unsub" toSubredditWithIdent:subredditIdent];
    }];
}

+ (AFHTTPRequestOperation *)fetchSubredditInformationForSubredditName:(NSString *)subredditName onComplete:(void (^)(Subreddit *subredditOrNil))onComplete;
{
  NSString *path = [NSString stringWithFormat:@"/r/%@/about.json", subredditName];
  NSURLRequest *request = [[RedditAPI shared] requestForUrl:path];
  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                       {
                                         NSDictionary *subDictionary = [JSON valueForKeyPath:@"data"];
                                         if (!subDictionary || ![subDictionary valueForKey:@"id"])
                                         {
                                           onComplete(nil);
                                           return;
                                         }
                                         Subreddit *subreddit = [Subreddit subredditFromDictionary:subDictionary];
                                         onComplete(subreddit);
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                         onComplete(nil);
                                       }];
  [operation start];
  return operation;
}

@end
