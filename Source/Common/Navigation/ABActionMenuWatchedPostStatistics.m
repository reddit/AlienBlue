#import "ABActionMenuWatchedPostStatistics.h"
#import "RedditAPI+Account.h"

@interface ABActionMenuWatchedPostStatistics()
@property NSTimeInterval lastPresentedTimestamp;
@property NSInteger lastPresentedReplyCount;
@property NSInteger lastPresentedScore;
@property (copy) NSString *authenticatedUserAtLastPresentation;
@property (copy) NSString *votableElementIdent;
@property (copy) NSString *postTitle;
@property NSInteger commentCountDelta;
@property NSInteger scoreDelta;
@property (copy) NSString *preferenceKeyPrefixForDefaults;
@end

@implementation ABActionMenuWatchedPostStatistics

+ (ABActionMenuWatchedPostStatistics *)lastSubmittedPostStats;
{
  static ABActionMenuWatchedPostStatistics *s_lastSubmittedPostStats = nil;
  if (!s_lastSubmittedPostStats)
  {
    s_lastSubmittedPostStats = [[ABActionMenuWatchedPostStatistics alloc] initWithPreferenceKeyPrefix:@"lastSubmittedPostStats_"];
  }
  return s_lastSubmittedPostStats;
}

+ (ABActionMenuWatchedPostStatistics *)watchedPostOneStats;
{
  static ABActionMenuWatchedPostStatistics *s_watchedPostOneStats = nil;
  if (!s_watchedPostOneStats)
  {
    s_watchedPostOneStats = [[ABActionMenuWatchedPostStatistics alloc] initWithPreferenceKeyPrefix:@"watchedPostOneStats_"];
  }
  return s_watchedPostOneStats;
}

+ (ABActionMenuWatchedPostStatistics *)watchedPostTwoStats;
{
  static ABActionMenuWatchedPostStatistics *s_watchedPostTwoStats = nil;
  if (!s_watchedPostTwoStats)
  {
    s_watchedPostTwoStats = [[ABActionMenuWatchedPostStatistics alloc] initWithPreferenceKeyPrefix:@"watchedPostTwoStats_"];
  }
  return s_watchedPostTwoStats;
}

- (id)initWithPreferenceKeyPrefix:(NSString *)preferenceKeyPrefix;
{
  JM_SUPER_INIT(init);
  self.preferenceKeyPrefixForDefaults = preferenceKeyPrefix;
  self.lastPresentedScore = [UDefaults integerForKey:[self.preferenceKeyPrefixForDefaults stringByAppendingString:@"lastPresentedScore"]];
  self.lastPresentedReplyCount = [UDefaults integerForKey:[self.preferenceKeyPrefixForDefaults stringByAppendingString:@"lastPresentedReplyCount"]];
  return self;
}

- (void)updateWithReplyCount:(NSInteger)replyCount score:(NSUInteger)score votableElementIdent:(NSString *)votableElementIdent postTitle:(NSString *)postTitle;
{
  self.commentCountDelta = 0;
  self.scoreDelta = 0;
  
  BOOL shouldAttemptDeltaCalculation = (JMIsEmpty(self.authenticatedUserAtLastPresentation) || [self.authenticatedUserAtLastPresentation jm_matches:[RedditAPI shared].authenticatedUser]) && (JMIsEmpty(self.votableElementIdent) || [self.votableElementIdent jm_matches:votableElementIdent]);
  
  if (self.lastPresentedReplyCount != 0 && shouldAttemptDeltaCalculation)
  {
    self.commentCountDelta = (replyCount - self.lastPresentedReplyCount);
  }
  
  if (self.lastPresentedScore != 0 && shouldAttemptDeltaCalculation)
  {
    self.scoreDelta = (score - self.lastPresentedScore);
  }
  
  self.lastPresentedReplyCount = replyCount;
  self.lastPresentedScore = score;
  self.authenticatedUserAtLastPresentation = [RedditAPI shared].authenticatedUser;
  self.lastPresentedTimestamp = CACurrentMediaTime();
  self.votableElementIdent = votableElementIdent;
  self.postTitle = postTitle;
  
  [UDefaults setInteger:self.lastPresentedScore forKey:[self.preferenceKeyPrefixForDefaults stringByAppendingString:@"lastPresentedScore"]];
  [UDefaults setInteger:self.lastPresentedReplyCount forKey:[self.preferenceKeyPrefixForDefaults stringByAppendingString:@"lastPresentedReplyCount"]];
}

- (void)updateBasedOnReceivedPost:(Post *)post;
{
  [self updateWithReplyCount:post.numComments score:post.score votableElementIdent:post.ident postTitle:post.title];
}

- (NSAttributedString *)attributedStringBasedOnLatestStats;
{
  NSString *formattedPostScore = [NSString shortFormattedStringFromNumber:self.lastPresentedScore shouldDecimilaze:YES];
  NSString *formattedCommentCount = [NSString shortFormattedStringFromNumber:self.lastPresentedReplyCount shouldDecimilaze:YES];
  
  NSString *rowOne = [self.postTitle jm_truncateToLength:12];
  NSString *rowTwo = [NSString stringWithFormat:@"\n%@ %@ %@ %@ %@", formattedPostScore, kABActionMenuUnicodeRaisedUpArrow, kABActionMenuUnicodeSeparator, formattedCommentCount, kABActionMenuUnicodeRaisedQuotation];
  NSString *rowThree = (self.scoreDelta == 0 && self.commentCountDelta == 0) ? @"" : [NSString stringWithFormat:@"\n%@ %d %@ %d %@", kABActionMenuUnicodeDelta, self.scoreDelta, kABActionMenuUnicodeRaisedUpArrow, self.commentCountDelta, kABActionMenuUnicodeRaisedQuotation];
  NSString *totalString = [NSString stringWithFormat:@"%@%@%@", rowOne, rowTwo, rowThree];
  
  NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:totalString];
  [as jm_applyColor:[UIColor colorForDottedDivider] toString:kABActionMenuUnicodeSeparator];
  UIColor *deltaColor = (self.scoreDelta >= 0) ? [UIColor skinColorForConstructive] : [UIColor skinColorForDestructive];
  [as jm_applyColor:deltaColor toString:rowThree];
  [as jm_applyFont:[UIFont boldSystemFontOfSize:10.] toString:rowOne];
  [as jm_applyFont:[UIFont boldSystemFontOfSize:10.] toString:rowTwo];
  [as jm_applyFont:[UIFont boldSystemFontOfSize:10.] toString:rowThree];
  [as jm_mutableParagraphStyleAtSubstring:rowOne].paragraphSpacing = 5.;
  return as;
}

- (BOOL)shouldRestrictNetworkUpdateBasedOnRateLimiting;
{
  return ((CACurrentMediaTime() - self.lastPresentedTimestamp) < 20) && [[RedditAPI shared].authenticatedUser jm_matches:self.authenticatedUserAtLastPresentation];
}

@end

#pragma mark - Recently Visited Post Tracking

@implementation ABActionMenuPostRecord

+ (NSMutableArray *)recentlyVisitedPosts;
{
  static NSMutableArray *s_recentlyVisitedPosts = nil;
  if (!s_recentlyVisitedPosts)
  {
    s_recentlyVisitedPosts = [NSMutableArray new];
  }
  return s_recentlyVisitedPosts;
}

+ (void)addPostToRecentlyVisitedList:(Post *)post;
{
  NSMutableArray *recentlyVisitedPosts = [self recentlyVisitedPosts];
  BOOL alreadyContainsPost = [recentlyVisitedPosts match:^BOOL(ABActionMenuPostRecord *record) {
    return [record.votableElementIdent jm_matches:post.ident];
  }];

  if (alreadyContainsPost)
  {
    return;
  }
  
  ABActionMenuPostRecord *record = [ABActionMenuPostRecord new];
  record.postTitle = post.title;
  record.votableElementIdent = post.ident;
  record.votableElementName = post.name;
  
  [recentlyVisitedPosts jm_safeInsertObject:record atIndex:0];
  
  [recentlyVisitedPosts jm_reduceToFirst:3];
}

+ (NSArray *)recentlyVisitedPostRecords;
{
  return [self recentlyVisitedPosts];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  JM_SUPER_INIT(init);
  self.votableElementIdent = [coder decodeObjectForKey:@"votableElementIdent"];
  self.postTitle = [coder decodeObjectForKey:@"postTitle"];
  self.votableElementName = [coder decodeObjectForKey:@"votableElementName"];
  self.shouldNotifyOnCommentCountChange = [coder decodeBoolForKey:@"shouldNotifyOnCommentCountChange"];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.votableElementIdent forKey:@"votableElementIdent"];
  [coder encodeObject:self.postTitle forKey:@"postTitle"];
  [coder encodeObject:self.votableElementName forKey:@"votableElementName"];
  [coder encodeBool:self.shouldNotifyOnCommentCountChange forKey:@"shouldNotifyOnCommentCountChange"];
}

@end
