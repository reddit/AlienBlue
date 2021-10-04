//
//  Comment+API.m
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Comment+API.h"
#import "Comment+Style.h"
#import "RedditAPI.h"
#import "RedditAPI+Comments.h"
#import "Post.h"
#import "ABAnalyticsManager.h"
#import "ReachabilityCoordinator.h"

@implementation Comment (API)

+ (AFHTTPRequestOperation *)fetchCommentsForPost:(Post *)post contextId:(NSString *)contextId params:(NSDictionary *)params onComplete:(void (^)(NSArray *commentDictionaries, NSDictionary *postDictionary, BOOL clientError))onComplete;
{
    NSString *url = nil;    
    
    if (contextId)
    {
        url = [NSString stringWithFormat:@"comments/%@/context/%@/.json?%@", post.ident, contextId, [params urlEncodedString]];
    }
    else
    {
        url = [NSString stringWithFormat:@"comments/%@/.json?%@", post.ident, [params urlEncodedString]];
    }
    
//    NSLog(@"query: %@", url);
    NSURLRequest *request = [[RedditAPI shared] requestForUrl:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
                                         {
                                             id commentsJSON = [[JSON valueForKeyPath:@"data"] objectAtIndex:1];
                                             NSDictionary *postDictionary = [[[[JSON valueForKeyPath:@"data"] objectAtIndex:0] valueForKeyPath:@"children.data"] objectAtIndex:0];
                                             NSArray *apiComments = [commentsJSON valueForKeyPath:@"children"];
                                             onComplete(apiComments, postDictionary, NO);
                                             [ABAnalyticsManager pixelTrackResponse:response];
                                         // Handle bad responses
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             if (error.code == NSURLErrorCancelled)
                                               return;

                                             // this condition is already handled and notified by the ReachabilityCoordinator
                                             if (![[ReachabilityCoordinator shared] isReachable])
                                               return;
                                           
                                             int statusCode = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
                                             // If 400-level error, set clientError to YES
                                             if (statusCode / 100 == 4)
                                             {
                                                 onComplete(nil, nil, YES);
                                             }
                                             // If non-400-level error, set clientError to NO
                                             else
                                             {
                                                 onComplete(nil, nil, NO);
                                             }
                                         }];
    [operation start];
    return operation;
}

- (void)deleteComment;
{
    [[RedditAPI shared] deleteCommentWithID:self.name];
    self.body = @"[deleted] ";
    self.bodyHTML = @"[deleted] ";
    self.author = @"[deleted]";
    [self flushCachedStyles];
}

@end
