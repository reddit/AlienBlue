//  REDListingViewController+FooterSupport.m
//  RedditApp

#import "RedditApp/Listing/REDListingViewController+FooterSupport.h"

#import "Common/Navigation/NavigationManager.h"
#import "Helpers/RedditAPI+Account.h"
#import "Helpers/RedditAPI+ElementInteraction.h"
#import "Helpers/RedditAPI+HideQueue.h"
#import "MKStoreKit/MKStoreManager.h"

@implementation REDListingViewController (FooterSupport)

- (void)loadMore;
{ [self fetchPostsRemoveExisting:NO]; }

- (void)hideRead;
{
  if (![MKStoreManager isProUpgraded]) {
    [MKStoreManager needProAlert];
    return;
  }

  if (![[RedditAPI shared] authenticated]) {
    [[RedditAPI shared] showAuthorisationRequiredDialog];
    return;
  }

  NSMutableArray* postsNodesToRemove = [NSMutableArray array];

  [[self nodes] each:^(id item) {
      if ([item isKindOfClass:[PostNode class]]) {
        PostNode* node = (PostNode*)item;
        Post* post = node.post;
        if (post.visited) {
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
  if (![MKStoreManager isProUpgraded]) {
    [MKStoreManager needProAlert];
    return;
  }

  if (![[RedditAPI shared] authenticated]) {
    [[RedditAPI shared] showAuthorisationRequiredDialog];
    return;
  }

  [[self nodes] each:^(id item) {
      if ([item isKindOfClass:[PostNode class]]) {
        PostNode* node = (PostNode*)item;
        Post* post = node.post;

        [[RedditAPI shared] addPostToHideQueue:post.name];
      }
  }];

  [self fetchPostsRemoveExisting:YES];
}

@end
