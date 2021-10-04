#import <Foundation/Foundation.h>
#import "Post.h"

#define kABActionMenuUnicodeSeparator @"┊"
#define kABActionMenuUnicodeRaisedUpArrow @"ꜛ"
#define kABActionMenuUnicodeRaisedQuotation @"”"
#define kABActionMenuUnicodeDelta @"Δ"

@interface ABActionMenuPostRecord : NSObject <NSCoding>
@property (copy) NSString *votableElementIdent;
@property (copy) NSString *postTitle;
@property (copy) NSString *votableElementName;
@property BOOL shouldNotifyOnCommentCountChange;
+ (void)addPostToRecentlyVisitedList:(Post *)post;
+ (NSArray *)recentlyVisitedPostRecords;
@end

@interface ABActionMenuWatchedPostStatistics : NSObject

+ (ABActionMenuWatchedPostStatistics *)lastSubmittedPostStats;
+ (ABActionMenuWatchedPostStatistics *)watchedPostOneStats;
+ (ABActionMenuWatchedPostStatistics *)watchedPostTwoStats;

@property (readonly) BOOL shouldRestrictNetworkUpdateBasedOnRateLimiting;
@property (readonly) NSAttributedString *attributedStringBasedOnLatestStats;

@property (readonly) NSInteger lastPresentedReplyCount;
@property (readonly) NSInteger lastPresentedScore;
@property (readonly, copy) NSString *postTitle;
@property (readonly) NSInteger commentCountDelta;
@property (readonly) NSInteger scoreDelta;


- (id)initWithPreferenceKeyPrefix:(NSString *)preferenceKeyPrefix;
- (void)updateWithReplyCount:(NSInteger)replyCount score:(NSUInteger)score votableElementIdent:(NSString *)votableElementIdent postTitle:(NSString *)postTitle;
- (void)updateBasedOnReceivedPost:(Post *)post;


@end
