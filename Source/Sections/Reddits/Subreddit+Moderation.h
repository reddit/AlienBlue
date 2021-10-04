#import "Subreddit.h"

typedef enum SubredditModFolder {
  SubredditModFolderDefault = 0,
  SubredditModFolderModQueue,
  SubredditModFolderRemoved,
  SubredditModFolderReported,
  SubredditModFolderUnmoderated,
} SubredditModFolder;


@interface Subreddit (Moderation)

+ (NSString *)moderationUrlForSubredditUrl:(NSString *)subredditUrl modFolder:(SubredditModFolder)modFolder;
+ (NSString *)friendlyNameForModerationFolder:(SubredditModFolder)modFolder;
//+ (void)updateModeratedSubredditsUsingCache:(BOOL)useCache onComplete:(void(^)(NSArray *subreddits))onComplete;
//+ (BOOL)isUserAllowedToModerateSubredditUrl:(NSString *)subredditUrl;

@end
