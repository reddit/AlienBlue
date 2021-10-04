#import "ABActionMenuKarmaStatistics.h"
#import "RedditAPI+Account.h"

#define kABActionMenuUpArrowUnicode @"\U00002B06\U0000FE0E"
#define kABActionMenuDownArrowUnicode @"\U00002B07\U0000FE0E"
#define kABActionMenuUnicodeSeparator @"┊"

@interface ABActionMenuKarmaStatistics()
@property NSInteger lastPresentedCommentKarmaCount;
@property NSInteger lastPresentedLinkKarmaCount;
@property NSInteger karmaDelta;
@property BOOL shouldTruncateForDisplay;
@property (copy) NSString *authenticatedUserAtLastPresentation;
@end

@implementation ABActionMenuKarmaStatistics

+ (ABActionMenuKarmaStatistics *)karmaStatistics;
{
  static ABActionMenuKarmaStatistics *s_karmaStatistics = nil;
  if (!s_karmaStatistics)
  {
    s_karmaStatistics = [ABActionMenuKarmaStatistics new];
    s_karmaStatistics.lastPresentedCommentKarmaCount = [UDefaults integerForKey:@"lastPresentedCommentKarmaCount"];
    s_karmaStatistics.lastPresentedLinkKarmaCount = [UDefaults integerForKey:@"lastPresentedLinkKarmaCount"];
  }
  return s_karmaStatistics;
}

- (void)updateWithKarmaStatisticsFromAPI;
{
  NSInteger linkKarma = [RedditAPI shared].karmaLink;
  NSInteger commentKarma = [RedditAPI shared].karmaComment;

  if ((self.lastPresentedCommentKarmaCount != 0 || self.lastPresentedLinkKarmaCount != 0) && (JMIsEmpty(self.authenticatedUserAtLastPresentation) || [self.authenticatedUserAtLastPresentation jm_matches:[RedditAPI shared].authenticatedUser]))
  {
    self.karmaDelta = (linkKarma - self.lastPresentedLinkKarmaCount) + (commentKarma - self.lastPresentedCommentKarmaCount);
  }
  self.lastPresentedCommentKarmaCount = commentKarma;
  self.lastPresentedLinkKarmaCount = linkKarma;
  self.authenticatedUserAtLastPresentation = [RedditAPI shared].authenticatedUser;

  [UDefaults setInteger:self.lastPresentedCommentKarmaCount forKey:@"lastPresentedCommentKarmaCount"];
  [UDefaults setInteger:self.lastPresentedLinkKarmaCount forKey:@"lastPresentedLinkKarmaCount"];
}

- (NSAttributedString *)attributedStringBasedOnLatestStatsShouldTruncate:(BOOL)shouldTruncate;
{
  [self updateWithKarmaStatisticsFromAPI];

  NSString *karmaTitle;
  if (shouldTruncate)
  {
    karmaTitle = [NSString stringWithFormat:@"%@ %@ %@", [NSString shortFormattedStringFromNumber:self.lastPresentedLinkKarmaCount shouldDecimilaze:YES], kABActionMenuUnicodeSeparator, [NSString shortFormattedStringFromNumber:self.lastPresentedCommentKarmaCount shouldDecimilaze:YES]];
  }
  else
  {
    karmaTitle = [NSString stringWithFormat:@"%d\n%d", self.lastPresentedLinkKarmaCount, self.lastPresentedCommentKarmaCount];
  }
  
  NSString *karmaDeltaString = @"";
  UIColor *deltaColor = (self.karmaDelta >= 0) ? [UIColor skinColorForConstructive] : [UIColor skinColorForDestructive];
  NSString *arrowUnicode = (self.karmaDelta >= 0) ? kABActionMenuUpArrowUnicode : kABActionMenuDownArrowUnicode;
  if (self.karmaDelta != 0)
  {
    karmaDeltaString = [NSString stringWithFormat:@"\n%d %@", self.karmaDelta, arrowUnicode];
  }
  
  NSString *completeTitleString = [NSString stringWithFormat:@"%@%@", karmaTitle, karmaDeltaString];
  
  NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:completeTitleString];
  [as jm_applyFont:[UIFont boldSystemFontOfSize:10.] toString:completeTitleString];
  [as jm_applyFont:[UIFont boldSystemFontOfSize:10.] toString:karmaDeltaString];
  [as jm_applyFont:[UIFont boldSystemFontOfSize:9.] toString:arrowUnicode];
  [as jm_applyColor:deltaColor toString:karmaDeltaString];
  [as jm_applyColor:[UIColor colorForDottedDivider] toString:kABActionMenuUnicodeSeparator];
  return as;
}

@end
