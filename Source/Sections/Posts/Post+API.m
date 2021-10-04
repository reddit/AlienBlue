//
//  Post+API.m
//  AlienBlue
//
//  Created by J M on 3/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Post+API.h"
#import "RedditAPI.h"
#import "Resources.h"
#import "RedditAPI+ElementInteraction.h"
#import "ABAnalyticsManager.h"

@implementation Post (API)

+ (AFHTTPRequestOperation *)fetchPostsForPath:(NSString *)path params:(NSDictionary *)params shouldPixelTrack:(BOOL)shouldPixelTrack onComplete:(void (^)(NSArray *posts))onComplete;
{
  NSString *url = [NSString stringWithFormat:@"%@?%@", path, [params urlEncodedString]];
  NSURLRequest *request = [[RedditAPI shared] requestForUrl:url];
  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                       {
                                         NSMutableArray *newPosts = [NSMutableArray array];
                                         NSArray *apiPosts = [JSON valueForKeyPath:@"data.children.data"];
                                         [apiPosts each:^(id item) {
                                           Post *post = [Post postFromDictionary:item];
                                           [newPosts addObject:post];
                                         }];
                                         onComplete(newPosts);
                                         if (shouldPixelTrack)
                                         {
                                           [ABAnalyticsManager pixelTrackResponse:response];
                                         }
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                           onComplete(nil);
                                       }];
  [operation start];
  return operation;
}

+ (AFHTTPRequestOperation *)fetchPostsForPath:(NSString *)path params:(NSDictionary *)params onComplete:(void (^)(NSArray *posts))onComplete;
{
  return [self fetchPostsForPath:path params:params shouldPixelTrack:NO onComplete:onComplete];
}

+ (AFHTTPRequestOperation *)fetchAdvertorialPostsForSubredditPath:(NSString *)subredditPath onComplete:(void (^)(NSArray *advertorialPosts))onComplete;
{
  NSString *url = [NSString stringWithFormat:@"/api/apple/request_promo.json?app=alienblue&limit=1"];
  NSMutableURLRequest *request = [[RedditAPI shared] requestForUrl:url];
  [request setHTTPMethod:@"POST"];
  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                       {
                                         NSMutableArray *newPosts = [NSMutableArray array];
                                         NSArray *apiPosts = [JSON valueForKeyPath:@"data.children.data"];
                                         [apiPosts each:^(id item) {
                                           Post *post = [Post postFromDictionary:item];
                                           [newPosts addObject:post];
                                         }];
                                         onComplete(newPosts);
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                         onComplete([NSArray new]);
                                       }];
  [operation start];
  return operation;
}


+ (AFHTTPRequestOperation *)fetchLastSubmittedPostForUser:(NSString *)username onComplete:(void(^)(Post *lastSubmittedPostOrNil))onComplete;
{
  NSDictionary *params = @{
                           @"limit" : @(1),
                           @"sort" : @"new",
                           };
  
  NSString *apiPath = [NSString stringWithFormat:@"/user/%@/submitted/.json", username];
  AFHTTPRequestOperation *op = [self fetchPostsForPath:apiPath params:params onComplete:^(NSArray *posts) {
    if (posts.count >= 1)
    {
      onComplete(posts.firstObject);
    }
    else
    {
      onComplete(nil);
    }
  }];
  return op;
}

+ (AFHTTPRequestOperation *)fetchPostInformationWithName:(NSString *)postName onComplete:(void(^)(Post *postOrNil))onComplete;
{
  NSDictionary *params = @{
                           @"id" : postName,
                           };
  
  NSString *path = [NSString stringWithFormat:@"/api/info/.json"];
  AFHTTPRequestOperation *op = [self fetchPostsForPath:path params:params onComplete:^(NSArray *posts) {
    if (posts.count >= 1)
    {
      onComplete(posts.firstObject);
    }
    else
    {
      onComplete(nil);
    }
  }];
  return op;
}

- (void)toggleSaved;
{
    if (self.saved)
    {
        [self reportAnalyticEventWithAction:@"Unsave"];
        [[RedditAPI shared] unsavePostWithID:self.name];
    }
    else
    {
        [self reportAnalyticEventWithAction:@"Save"];
        [[RedditAPI shared] savePostWithID:self.name];        
    }
    self.saved = !self.saved;
}

- (void)toggleHide;
{
    if (self.hidden)
    {
        [self reportAnalyticEventWithAction:@"Unhide"];
        [[RedditAPI shared] unhidePostWithID:self.name];
    }
    else
    {
        [self reportAnalyticEventWithAction:@"Hide"];
        [[RedditAPI shared] hidePostWithID:self.name];
    }
    self.hidden = !self.hidden;
}

- (void)report;
{
    self.reported = YES;
    [self reportAnalyticEventWithAction:@"Report"];
    [[RedditAPI shared] reportPostWithID:self.name];
}

@end
