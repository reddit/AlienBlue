#import "ABActionMenuWatchedCommentStatistics.h"

@implementation ABActionMenuWatchedCommentStatistics

+ (ABActionMenuWatchedCommentStatistics *)lastSubmittedCommentStats;
{
  static ABActionMenuWatchedCommentStatistics *s_lastSubmittedCommentStats = nil;
  if (!s_lastSubmittedCommentStats)
  {
    s_lastSubmittedCommentStats = [[ABActionMenuWatchedCommentStatistics alloc] initWithPreferenceKeyPrefix:@"lastSubmittedCommentStats_"];
  }
  return s_lastSubmittedCommentStats;
}

- (void)updateBasedOnReceivedMessageComment:(Message *)messageComment;
{
  [self updateWithReplyCount:0 score:messageComment.score votableElementIdent:messageComment.ident postTitle:messageComment.titleForPresentation];
}

- (NSAttributedString *)attributedStringBasedOnLatestStats;
{
  NSString *formattedScore = [NSString shortFormattedStringFromNumber:self.lastPresentedScore shouldDecimilaze:YES];
  
  NSString *rowOne = [self.postTitle jm_truncateToLength:12];
  NSString *rowTwoA = [NSString stringWithFormat:@"\n%@ %@", formattedScore, kABActionMenuUnicodeRaisedUpArrow];
  NSString *rowTwoB = (self.scoreDelta == 0) ? @"" : [NSString stringWithFormat:@"%@ %@ %d %@", kABActionMenuUnicodeSeparator, kABActionMenuUnicodeDelta, self.scoreDelta, kABActionMenuUnicodeRaisedUpArrow];
  NSString *totalString = [NSString stringWithFormat:@"%@%@%@", rowOne, rowTwoA, rowTwoB];
  
  NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:totalString];
  UIColor *deltaColor = (self.scoreDelta >= 0) ? [UIColor skinColorForConstructive] : [UIColor skinColorForDestructive];
  [as jm_applyColor:deltaColor toString:rowTwoB];
  [as jm_applyColor:[UIColor colorForDottedDivider] toString:kABActionMenuUnicodeSeparator];
  [as jm_applyFont:[UIFont boldSystemFontOfSize:10.] toString:totalString];
  [as jm_mutableParagraphStyleAtSubstring:rowOne].paragraphSpacing = 5.;
  return as;
}

@end
