//
//  CommentsViewController+API.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "AFNetworking.h"
#import "CommentsViewController.h"
#import "CommentPostHeaderNode.h"

#define kCommentSortOrderTop @"top"

@interface CommentsViewController (API)

@property (strong) AFHTTPRequestOperation *loadOperation;
@property (nonatomic,strong) NSString *sortOrder;
@property NSUInteger customFetchLimit;
@property BOOL disallowPrerendingAndAttributedStylePreprocessing;

- (void)fetchCommentsOnComplete:(void (^)(NSArray *commentNodes, CommentPostHeaderNode *postHeaderNode))onComplete;

@end
