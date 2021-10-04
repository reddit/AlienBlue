//
//  PostsViewController+Filters.m
//  AlienBlue
//
//  Created by J M on 12/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController+Filters.h"
#import "NPostCell.h"
#import "NavigationManager.h"
#import "Resources.h"
#import "RedditAPI+HideQueue.h"

//#define kNumberOfPostsToCheckForDuplicates 20

@implementation PostsViewController (Filters)

- (BOOL)isDuplicatePost:(Post *)post
{
    __block BOOL isDuplicate = NO;
//    if ([self nodeCount] > kNumberOfPostsToCheckForDuplicates)
//    {
//    NSArray *postNodesToCheck = [self.nodes subarrayWithRange:NSMakeRange([self nodeCount] - kNumberOfPostsToCheckForDuplicates, kNumberOfPostsToCheckForDuplicates)];
//    [postNodesToCheck each:^(PostNode *node){
    
    [self.nodes enumerateObjectsUsingBlock:^(PostNode *node, NSUInteger idx, BOOL *stop) {
        if ([node isKindOfClass:[PostNode class]])
        {
//            DLog(@"comparing: %@ with %@", node.post.name, post.name);
//            if ([node.post.name equalsString:post.name])
            if ([post.name equalsString:node.post.name])
            {
                isDuplicate = YES;
                *stop = YES;
            }
        }
    }];
    
//    }
    return isDuplicate;
}

- (BOOL)isInHideQueue:(Post *)post;
{
  return [[RedditAPI shared] isPostInHideQueue:post.name];
}

- (BOOL)shouldFilterPost:(Post *)post removeExisting:(BOOL)removeExisting;
{
    // this handles cases in which Reddit can return comments alongside posts
    // eg. in ModQueue or Reported
    if ([post.title isEmpty])
      return YES;
  
    if (!removeExisting && [self isDuplicatePost:post])
    {
        return YES;
    }
    
    if ([self isInHideQueue:post])
        return YES;
  
  if ([Resources safeFilter])
  {
    if (post.nsfw || [post.subreddit equalsString:@"nsfw"] || [post.subreddit equalsString:@"wtf"])
    {
      return YES;
    }
  }

    
	NSMutableArray * filterList = (NSMutableArray *) [UDefaults objectForKey:kABSettingKeyFilterList];
	if (!filterList || [filterList count] == 0)
		return NO;
	
	for (NSString * filterItem in filterList)
	{
		if ([post.title contains:filterItem] || [post.subreddit contains:filterItem] || [post.url contains:filterItem])
			return YES;
	}
	
	return NO;
}


@end
