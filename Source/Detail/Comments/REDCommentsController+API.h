//  REDCommentsController+API.h
//  RedditApp

#import <AFNetworking/AFNetworking.h>

#import "RedditApp/Detail/Comments/REDCommentsController.h"
#import "Sections/Comments/CommentPostHeaderNode.h"

#define kCommentSortOrderTop @"top"

@interface REDCommentsController (API)

@property(strong) AFHTTPRequestOperation *loadOperation;
@property(nonatomic, strong) NSString *sortOrder;
@property NSUInteger customFetchLimit;
@property BOOL disallowPrerendingAndAttributedStylePreprocessing;

- (void)fetchCommentsOnComplete:(void (^)(NSArray *commentNodes,
                                          CommentPostHeaderNode *postHeaderNode))onComplete;

@end
