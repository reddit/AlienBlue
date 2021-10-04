#import <Foundation/Foundation.h>

@interface ABActionMenuKarmaStatistics : NSObject
+ (ABActionMenuKarmaStatistics *)karmaStatistics;
- (NSAttributedString *)attributedStringBasedOnLatestStatsShouldTruncate:(BOOL)shouldTruncate;
@end
