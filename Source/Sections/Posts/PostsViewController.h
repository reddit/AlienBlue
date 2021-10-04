//
//  PostsViewController.h
//  AlienBlue
//
//  Created by J M on 3/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "ABOutlineViewController.h"
#import "PostsHeaderCoordinator.h"
#import "PostsFooterCoordinator.h"
#import "Post.h"

#define kPostTableHeaderOffsetWithoutActionMenu 44.
#define kPostTableHeaderOffsetWithActionMenu 0.

@class PostNode;

@interface PostsViewController : ABOutlineViewController <PostsHeaderDelegate, PostsFooterDelegate>
@property (strong,readonly) NSString *subreddit;
@property (strong,readonly) NSString *subredditTitle;

@property (readonly, strong) PostsHeaderCoordinator *headerCoordinator;
@property (readonly, strong) PostsFooterCoordinator *footerCoordinator;


- (id)initWithSubreddit:(NSString *)subreddit title:(NSString *)title;
- (void)fetchPostsRemoveExisting:(BOOL)removeExisting;
- (void)clearAndRefreshFromSettingsLogin;
- (void)showSearch;
- (void)hideTitle;

- (void)showLinkForPost:(Post *)post;
- (void)showCommentsForPost:(Post *)post;
- (void)respondToStyleChange;

- (void)triggeredWithForce:(BOOL)force;
- (void)postsDidFinishLoading;

- (void)mimicTapOnCellForPostNode:(PostNode *)postNode;

@end
