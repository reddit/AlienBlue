//
//  PostsViewController+API.m
//  AlienBlue
//
//  Created by J M on 12/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController+API.h"
#import "PostsViewController+CanvasSupport.h"
#import "RedditAPI+HideQueue.h"
#import "RedditAPI+Posts.h"
#import "NPostCell.h"
#import "PostsHeaderCoordinator.h"
#import "Post+API.h"
#import "PostsViewController+Filters.h"
#import "Post+Style.h"
#import "NPostCell.h"
#import "NCenteredTextCell.h"
#import "Resources.h"
#import "NPostCell_iPad.h"
#import "Subreddit+Moderation.h"

@interface PostsViewController (API_)
@property (readonly) BOOL showingCanvas;
@property (readonly) PostsHeaderCoordinator *headerCoordinator;
@property (readonly) NSString *subreddit;
@end

@implementation PostsViewController (API)

SYNTHESIZE_ASSOCIATED_STRONG(AFHTTPRequestOperation, loadPostOperation, LoadPostOperation);

- (NSDictionary *)postRequestOptionsRemoveExisting:(BOOL)removeExisting;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (!removeExisting && [self nodeCount] > 2)
    {
        if ([self.nodes.last isKindOfClass:[PostNode class]])
        {
            NSString *lastPostId = [(PostNode *)self.nodes.last post].name;
            [params setObject:lastPostId forKey:@"after"];
        }
        else if ([self.nodes.last isKindOfClass:[CenteredTextNode class]])
        {
            // check the one just above the text node for last post id
            JMOutlineNode *secondLast = [self.nodes objectAtIndex:[self nodeCount] - 2];
            if (secondLast && [secondLast isKindOfClass:[PostNode class]])
            {
                NSString *lastPostId = [(PostNode *)secondLast post].name;
                [params setObject:lastPostId forKey:@"after"];
            }
        }
    }
    
  NSUInteger fetchCount = 25;    

    // compensate for posts that are being hidden
    fetchCount += [RedditAPI shared].hideQueue.count;
  
    [params setObject:[NSNumber numberWithInt:fetchCount] forKey:@"limit"];
    
    [params addEntriesFromDictionary:[self additionalURLParamsFromHeaderCoordinator]];

// These might be fine for Alien Blue, but I don't want to risk causing any regressions.
#if !ALIEN_BLUE
    // Get extra subreddit detail.
    [params setObject:@YES forKey:@"sr_detail"];
    [params setObject:@YES forKey:@"expand_srs"];
    // We don't want HTML.
    [params setObject:@YES forKey:@"raw_json"];
    [params setObject:@"json" forKey:@"api_type"];
#endif

    return params;
};

- (NSDictionary *)additionalURLParamsFromHeaderCoordinator;
{
  NSMutableDictionary *params = [NSMutableDictionary new];
  if ([self.headerCoordinator.sortOrder equalsString:kPostOrderTop])
  {
    [params setObject:self.headerCoordinator.topTimespan forKey:@"t"];
  }

  if (!JMIsEmpty(self.headerCoordinator.sortOrder))
  {
    [params setObject:self.headerCoordinator.sortOrder forKey:@"sort"];
  }
  
  if (self.headerCoordinator.showingSearch)
  {
    NSString *sortOrder = self.headerCoordinator.searchSortOrder;
    SET_IF_EMPTY(sortOrder, kPostSearchOrderRelevance);
    
    NSString *searchQuery = [self.headerCoordinator.searchQuery stringByEscaping];
    SET_IF_EMPTY(searchQuery, @"");
    
    [params setObject:sortOrder forKey:@"sort"];
    [params setObject:searchQuery forKey:@"q"];
    if (self.headerCoordinator.searchRestrictToSubreddit)
    {
      [params setObject:@"on" forKey:@"restrict_sr"];
    }
  }
  return params;
}

- (BOOL)shouldOverrideNSFWTags;
{
    if ([self.subreddit contains:@"+"] &&
        (
         [self.subreddit contains:@"nsfw"] ||
         [self.subreddit contains:@"gonewild"] ||
         [self.subreddit contains:@"boobies"] ||
         [self.subreddit contains:@"boobs"] ||
         [self.subreddit contains:@"tits"] ||
         [self.subreddit contains:@"milf"]
         ))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)fetchPostsRemoveExisting:(BOOL)removeExisting onComplete:(void (^)(NSArray *posts))onComplete;
{
    NSString *queryPath;
    if (self.headerCoordinator.showingSearch)
        queryPath = [self.subreddit stringByAppendingPathComponent:@"/search.json"];
    else
    {
      NSString *baseSubredditUrl = self.subreddit;
      if (self.headerCoordinator.modFolderSelection != SubredditModFolderDefault)
      {
        baseSubredditUrl = [Subreddit moderationUrlForSubredditUrl:self.subreddit modFolder:self.headerCoordinator.modFolderSelection];
      }
      queryPath = [[baseSubredditUrl stringByAppendingPathComponent:self.headerCoordinator.sortOrder] stringByAppendingString:@"/.json"]; 
    }
        
    NSDictionary *params = [self postRequestOptionsRemoveExisting:removeExisting];

    BOOL overrideNSFWTags = [self shouldOverrideNSFWTags];
    
    BSELF(PostsViewController);
    [RedditAPI shared].loadingPosts = YES;
  
    void(^postLoadCompleteAction)(NSArray *posts) = ^(NSArray *posts){
      blockSelf.loadPostOperation = nil;
      
      NSArray *filteredPosts = [posts filter:^BOOL(Post *post) {
        return [blockSelf shouldFilterPost:post removeExisting:removeExisting];
      }];
      
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [filteredPosts each:^(Post *post) {
          
          [post preprocessStyles];
          if (overrideNSFWTags)
          {
            post.nsfw = NO;
            post.rawThumbnail = @"http://127.0.0.1/";
          }
          //precache title height calculations
          Class postCellClass = [Resources isIPAD] ? NSClassFromString(@"NPostCell_iPad") : NSClassFromString(@"NPostCell_iPhone");
          CGFloat titleMargin = [postCellClass titleMarginForPost:post];
          [post titleHeightConstrainedToWidth:blockSelf.tableView.width - titleMargin];
          
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [RedditAPI shared].loadingPosts = NO;
          onComplete(filteredPosts);
        });
      });
    };
  
  self.loadPostOperation = [Post fetchPostsForPath:queryPath params:params shouldPixelTrack:YES onComplete:^(NSArray *posts) {
      postLoadCompleteAction(posts);
    }];
}

@end
