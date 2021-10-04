#import "RedditAPI+HideQueue.h"
#import "RedditAPI+ElementInteraction.h"

// We maintain two hide queues, one that the API calls to Reddit, and localHideQueue.
// The reason for this localHideQueue is that a "hide" call may not be finished
// before a fetchPosts call is made.  This would result in one or two posts
// being shown even though the user wanted to hide them.

@interface RedditAPI (HideQueue_)
@property (strong) NSMutableArray *hideQueue;
@property (strong) NSMutableArray *localHideQueue;
@property (strong) NSTimer *hideQueueTimer;
@end

@implementation RedditAPI (HideQueue)

SYNTHESIZE_ASSOCIATED_STRONG(NSMutableArray, hideQueue, HideQueue)
SYNTHESIZE_ASSOCIATED_STRONG(NSMutableArray, localHideQueue, LocalHideQueue)
SYNTHESIZE_ASSOCIATED_STRONG(NSTimer, hideQueueTimer, HideQueueTimer)

- (void)prepareHideQueue;
{
  self.hideQueue = [NSMutableArray new];
  self.localHideQueue = [NSMutableArray new];
  self.hideQueueTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(processHideQueue:) userInfo:nil repeats:YES];
}

- (void)processHideQueue:(NSTimer *)theTimer
{
  if (self.hideQueue.count > 0)
  {
    [self processFirstInPostQueue];
  }
  else
  {
    [self.localHideQueue removeAllObjects];
  }
}

- (void)processFirstInPostQueue
{
  if (self.hideQueue.count == 0)
    return;
  
  [self hidePostWithID:[self.hideQueue objectAtIndex:0]];
  [self.hideQueue removeObjectAtIndex:0];
}

- (BOOL)isPostInHideQueue:(NSString *)postID
{
  return [self.localHideQueue containsObject:postID];
}

- (void)addPostToHideQueue:(NSString *)postID
{
  if (![self.hideQueue containsObject:postID])
  {
    [self.hideQueue addObject:postID];
    [self.localHideQueue addObject:postID];
  }
}

@end
