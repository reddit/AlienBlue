//
//  PostsViewController+API.h
//  AlienBlue
//
//  Created by J M on 12/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController.h"
#import "AFNetworking.h"

@interface PostsViewController (API)
@property (strong) AFHTTPRequestOperation *loadPostOperation;
- (NSDictionary *)postRequestOptionsRemoveExisting:(BOOL)removeExisting;
- (void)fetchPostsRemoveExisting:(BOOL)removeExisting onComplete:(void (^)(NSArray *posts))onComplete;
- (NSDictionary *)additionalURLParamsFromHeaderCoordinator;
@end
