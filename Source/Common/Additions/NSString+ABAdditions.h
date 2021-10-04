#import <Foundation/Foundation.h>

@interface NSString (ABAdditions)

@property (readonly) NSString *jm_trimmed;

- (BOOL)contains:(NSString *)str;
- (BOOL)equalsString:(NSString *)str;
- (BOOL)isEmpty;
- (NSString *)stringByEscaping;
- (NSString *)stringByUnescaping;
- (NSString *)convertToSubredditTitle;
- (NSString *)deeplink;
- (NSString *)formattedUrl;
- (NSString *)domainFromUrl;

- (NSString *)convertRedditNameToIdent;
- (NSString *)extractSubredditLink;
- (NSString *)extractUserLink;
- (NSString *)extractRedditPostIdent;
- (NSString *)extractContextCommentID;
- (NSString *)generateSubredditPathFromSubredditTitle;

- (CGFloat)widthWithFont:(UIFont *)font;
- (NSString *)limitToLength:(NSUInteger)ind;
- (NSString *)stringMatchingPattern:(NSString *)pattern;

- (NSString *)limitToFirstWord;
- (BOOL)linkContainsSpoilerTag;

- (NSString *)standardCharacterSetOnly;

- (BOOL)isLastCharacter:(NSString *)lastChar;
- (NSString *)jm_trimmed;

+ (NSString *)formattedTimeToDaysFromReferenceTime:(CGFloat)refTime;
+ (NSString *)formattedTimeFromReferenceTime:(CGFloat)refTime;
+ (NSString *)formattedNumberPrefixedWithPlusOrMinus:(NSInteger)numberToFormat;

@end
