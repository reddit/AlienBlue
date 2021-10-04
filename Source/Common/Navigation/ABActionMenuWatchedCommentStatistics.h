#import "ABActionMenuWatchedPostStatistics.h"
#import "Message.h"

@interface ABActionMenuWatchedCommentStatistics : ABActionMenuWatchedPostStatistics

+ (ABActionMenuWatchedCommentStatistics *)lastSubmittedCommentStats;
- (void)updateBasedOnReceivedMessageComment:(Message *)messageComment;

@end
