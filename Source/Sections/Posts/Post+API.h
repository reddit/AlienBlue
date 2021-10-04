//
//  Post+API.h
//  AlienBlue
//
//  Created by J M on 3/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Post.h"
#import "AFNetworking.h"

@interface Post(API)

+ (AFHTTPRequestOperation *)fetchPostsForPath:(NSString *)path params:(NSDictionary *)params onComplete:(void (^)(NSArray *posts))onComplete;
+ (AFHTTPRequestOperation *)fetchPostsForPath:(NSString *)path params:(NSDictionary *)params shouldPixelTrack:(BOOL)shouldPixelTrack onComplete:(void (^)(NSArray *posts))onComplete;
+ (AFHTTPRequestOperation *)fetchAdvertorialPostsForSubredditPath:(NSString *)subredditPath onComplete:(void (^)(NSArray *advertorialPosts))onComplete;
+ (AFHTTPRequestOperation *)fetchLastSubmittedPostForUser:(NSString *)username onComplete:(void(^)(Post *lastSubmittedPostOrNil))onComplete;
+ (AFHTTPRequestOperation *)fetchPostInformationWithName:(NSString *)postName onComplete:(void(^)(Post *postOrNil))onComplete;
- (void)toggleSaved;
- (void)toggleHide;
- (void)report;
@end
