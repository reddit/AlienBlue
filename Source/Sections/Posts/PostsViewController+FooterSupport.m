//
//  PostsViewController+Hiding.m
//  AlienBlue
//
//  Created by J M on 10/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsViewController+FooterSupport.h"
#import "MKStoreManager.h"
#import "NavigationManager.h"
#import "RedditAPI+HideQueue.h"
#import "RedditAPI+ElementInteraction.h"
#import "RedditAPI+Account.h"

@implementation PostsViewController (FooterSupport)

- (void)loadMore;
{
    [self fetchPostsRemoveExisting:NO];    
}

- (void)hideRead;
{
	if (![MKStoreManager isProUpgraded])
	{
		[MKStoreManager needProAlert];
		return;
	}
	
	if (![[RedditAPI shared] authenticated])
	{
		[[RedditAPI shared] showAuthorisationRequiredDialog];
		return;
	}
    
    NSMutableArray * postsNodesToRemove =[NSMutableArray array];

    [[self nodes] each:^(id item) {
        if ([item isKindOfClass:[PostNode class]])
        {
            PostNode *node = (PostNode *)item;
            Post *post = node.post;
            if (post.visited)
            {
                [[RedditAPI shared] hidePostWithID:post.name];
                [postsNodesToRemove addObject:node];
            }
        }
    }];
    
    [self.nodes removeObjectsInArray:postsNodesToRemove];
    
    [self reload];
    [self fetchPostsRemoveExisting:NO];    
}

- (void)hideAll;
{
	if (![MKStoreManager isProUpgraded])
	{
		[MKStoreManager needProAlert];
		return;
	}
	
	if (![[RedditAPI shared] authenticated])
	{
		[[RedditAPI shared] showAuthorisationRequiredDialog];
		return;
	}

    [[self nodes] each:^(id item) {
        if ([item isKindOfClass:[PostNode class]])
        {
            PostNode *node = (PostNode *)item;
            Post *post = node.post;

            [[RedditAPI shared] addPostToHideQueue:post.name];
        }
    }];
    
    [self fetchPostsRemoveExisting:YES];
}

@end
