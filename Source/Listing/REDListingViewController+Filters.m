//  REDListingViewController+Filters.m
//  RedditApp

#import "RedditApp/Listing/REDListingViewController+Filters.h"

#import "Common/Navigation/NavigationManager.h"
#import "Helpers/RedditAPI+HideQueue.h"
#import "Helpers/Resources.h"
#import "Sections/Posts/NPostCell.h"

//#define kNumberOfPostsToCheckForDuplicates 20

@implementation REDListingViewController (Filters)

- (BOOL)isDuplicatePost:(Post *)post {
  __block BOOL isDuplicate = NO;
  //    if ([self nodeCount] > kNumberOfPostsToCheckForDuplicates)
  //    {
  //    NSArray *postNodesToCheck = [self.nodes subarrayWithRange:NSMakeRange([self nodeCount] -
  //    kNumberOfPostsToCheckForDuplicates, kNumberOfPostsToCheckForDuplicates)];
  //    [postNodesToCheck each:^(PostNode *node){

  [self.nodes enumerateObjectsUsingBlock:^(PostNode *node, NSUInteger idx, BOOL *stop) {
      if ([node isKindOfClass:[PostNode class]]) {
        //            DLog(@"comparing: %@ with %@", node.post.name, post.name);
        //            if ([node.post.name equalsString:post.name])
        if ([post.name equalsString:node.post.name]) {
          isDuplicate = YES;
          *stop = YES;
        }
      }
  }];

  //    }
  return isDuplicate;
}

- (BOOL)isInHideQueue:(Post *)post;
{ return [[RedditAPI shared] isPostInHideQueue:post.name]; }

- (BOOL)shouldFilterPost:(Post *)post removeExisting:(BOOL)removeExisting;
{
  // this handles cases in which Reddit can return comments alongside posts
  // eg. in ModQueue or Reported
  if ([post.title isEmpty]) return YES;

  if (!removeExisting && [self isDuplicatePost:post]) {
    return YES;
  }

  if ([self isInHideQueue:post]) return YES;

  if ([Resources safeFilter]) {
    if (post.nsfw || [post.subreddit equalsString:@"nsfw"] ||
        [post.subreddit equalsString:@"wtf"]) {
      return YES;
    }
  }

  NSMutableArray *filterList = (NSMutableArray *)[UDefaults objectForKey:kABSettingKeyFilterList];
  if (!filterList || [filterList count] == 0) return NO;

  for (NSString *filterItem in filterList) {
    if ([post.title contains:filterItem] || [post.subreddit contains:filterItem] ||
        [post.url contains:filterItem])
      return YES;
  }

  return NO;
}

@end
