//
//  Comment+API.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Comment.h"
#import "AFNetworking.h"

@class Post;

@interface Comment (API)

+ (AFHTTPRequestOperation *)fetchCommentsForPost:(Post *)post contextId:(NSString *)contextId params:(NSDictionary *)params onComplete:(void (^)(NSArray *commentDictionaries, NSDictionary *postDictionary, BOOL clientError))onComplete;
- (void)deleteComment;

@end
