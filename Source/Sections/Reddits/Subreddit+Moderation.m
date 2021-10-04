#import "Subreddit+Moderation.h"
#import "Subreddit+API.h"
#import "RedditAPI.h"

@implementation Subreddit (Moderation)

+ (NSString *)friendlyNameForModerationFolder:(SubredditModFolder)modFolder;
{
  NSString *name = nil;
  switch (modFolder) {
    case SubredditModFolderModQueue:
      name = @"Queue";
      break;
    case SubredditModFolderRemoved:
      name = @"Removed";
      break;
    case SubredditModFolderReported:
      name = @"Reported";
      break;
    case SubredditModFolderUnmoderated:
      name = @"Unmoderated";
      break;
    default:
      name = @"";
      break;
  }
  return name;
}

+ (NSString *)moderationUrlForSubredditUrl:(NSString *)subredditUrl modFolder:(SubredditModFolder)modFolder;
{
  if (modFolder == SubredditModFolderDefault)
    return subredditUrl;
  
  NSString *basePath = nil;
  
  if ([subredditUrl isEmpty] || [subredditUrl contains:@"/r/all"] || [subredditUrl contains:@"+"] || [subredditUrl contains:@"user"])
    basePath = @"/r/mod";
  else
    basePath = subredditUrl;
  
  NSString *mPath = nil;
  switch (modFolder) {
    case SubredditModFolderModQueue:
      mPath = @"about/modqueue";
      break;
    case SubredditModFolderRemoved:
      mPath = @"about/spam";
      break;
    case SubredditModFolderReported:
      mPath = @"about/reports";
      break;
    case SubredditModFolderUnmoderated:
      mPath = @"about/unmoderated";
      break;
    default:
      mPath = @"";
      break;
  }
  
  return [basePath stringByAppendingPathComponent:mPath];
}

//+ (void)updateModeratedSubredditsUsingCache:(BOOL)useCache onComplete:(void(^)(NSArray *subreddits))onComplete;
//{
//  if (![RedditAPI shared].isMod)
//  {
//    s_moderatedSubreddits = [NSArray array];
//    if (onComplete) onComplete(s_moderatedSubreddits);
//    return;
//  }
//  
//  [Subreddit fetchModeratedSubredditsUsingCache:YES onComplete:^(NSArray *subreddits) {
//    s_moderatedSubreddits = (subreddits != nil) ? subreddits : [NSArray array];
//    if (onComplete) onComplete(s_moderatedSubreddits);
//  }];
//}
//
//+ (BOOL)isUserAllowedToModerateSubredditUrl:(NSString *)subredditUrl;
//{
//  if (![RedditAPI shared].isMod)
//    return NO;
//  
//  if (!s_moderatedSubreddits)
//    return NO;
//  
//  if ([s_moderatedSubreddits count] == 0)
//    return NO;
//  
//  Subreddit *s = [Subreddit subredditWithUrl:subredditUrl name:@""];
//  if (!s.isNativeSubreddit)
//    return YES;
//  
//  Subreddit *match = [s_moderatedSubreddits match:^BOOL(Subreddit *modSub) {
//    return [[modSub.url lowercaseString] equalsString:[subredditUrl lowercaseString]];
//  }];
//  
//  return match != nil;
//}

@end
