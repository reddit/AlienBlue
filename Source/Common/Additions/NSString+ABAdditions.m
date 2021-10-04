#import "NSString+ABAdditions.h"
#import "NSMutableAttributedString+ABAdditions.h"
#import "RedditAPI.h"
#import "NSString+ABLegacyLinkTypes.h"

@implementation NSString (ABAdditions)

- (BOOL)contains:(NSString *)str;
{
    if (!str) return NO;
    
    return ([self rangeOfString:str options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])].location != NSNotFound);
}

- (BOOL)equalsString:(NSString *)str;
{
    if (!str) return NO;
    
    return (self.length == str.length && [self contains:str]);
}

- (BOOL)isEmpty;
{
    return !([self length] > 0);
}

- (NSString *)stringByEscaping;
{
	NSString * encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                     NULL,
                                                                                                     (__bridge CFStringRef)self,
                                                                                                     NULL,
                                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                     kCFStringEncodingUTF8);
	return encodedString;
}

- (NSString *)stringByUnescaping;
{
	return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    
}

- (NSString *)separateCamelCaseWithSpaces;
{
  return [self stringByReplacingOccurrencesOfString:@"([a-z])([A-Z])" withString:@"$1 $2" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)convertToSubredditTitle;
{
	NSMutableString * str = [NSMutableString stringWithString:self];
  [str replaceString:@"/r/" withString:@""];
  [str replaceString:@"/" withString:@""];
  [str replaceString:@"_" withString:@" "];
  [str replaceString:@"-" withString:@" "];
  NSString *separatedCamelCase = [str separateCamelCaseWithSpaces];
  NSString *capitalized = [separatedCamelCase capitalizedString];
  NSString *adjusted = [capitalized adjustManuallyForSpecificSubreddits];
  return adjusted;
}

- (NSString *)adjustManuallyForSpecificSubreddits;
{
  NSMutableString *s = [NSMutableString stringWithString:self];
  [s jm_mutableReplaceString:@"Ios" withString:@"iOS"];
  [s jm_mutableReplaceString:@"Iphone" withString:@"iPhone"];
  [s jm_mutableReplaceString:@"Ipad" withString:@"iPad"];
  [s jm_mutableReplaceString:@"Iama" withString:@"I Am A"];
  return s;
}

- (NSString *)deeplink;
{
  if ([self contains:@"imgur.com"])
  {
    NSString *imageUrl = [NSString ab_fixImgurLinkForCanvas:self];
    return imageUrl;
  }
  else if (![self contains:@"jpg"] && ([self contains:@"qkme.me"] || [self contains:@"quickmeme.com"]))
  {
    NSURL *qkURL = [NSURL URLWithString:self];
    NSString *imgId = [qkURL lastPathComponent];
    NSString *imageUrl = [NSString stringWithFormat:@"http://i.qkme.me/%@.jpg", imgId];
    return imageUrl;
  }
  else
  {
    return self;
  }
}

- (NSString *)domainFromUrl;
{
  NSMutableString *trimmedUrl = [NSMutableString stringWithString:self];
  [trimmedUrl replaceString:@"www." withString:@""];
  [trimmedUrl replaceString:@"blog." withString:@""];

  [trimmedUrl replaceString:@"http://en." withString:@"http://"];
  [trimmedUrl replaceString:@"http://en.m" withString:@"http://"];
  [trimmedUrl replaceString:@"http://m." withString:@"http://"];

  NSURL *url = [NSURL URLWithString:trimmedUrl];
  NSString *host = url.host;
  SET_IF_EMPTY(host, @"");
  return host;
}

- (NSString *)formattedUrl;
{
  NSMutableString *formattedUrl = [NSMutableString string];
  NSString *trimmedUrl = [self stringByReplacingOccurrencesOfString:@".html" withString:@""];
  trimmedUrl = [trimmedUrl stringByReplacingOccurrencesOfString:@"www." withString:@""];
  NSURL *url = [NSURL URLWithString:trimmedUrl];
  if (url.host)
  {
    [formattedUrl appendString:[url.host standardCharacterSetOnly]];
  }
  for (NSString *pathComponent in url.pathComponents)
  {
    if ([pathComponent length] > 2)
    {
      [formattedUrl appendString:@" • "];
      [formattedUrl appendString:[pathComponent standardCharacterSetOnly]];
    }
  }
  return formattedUrl;
}

- (NSString *)convertRedditNameToIdent
{
  if ([self rangeOfString:@"_"].location == NSNotFound)
      return nil;

  NSUInteger underscoreLocation = [self rangeOfString:@"_"].location + 1;
  NSString *ident = [self substringFromIndex:underscoreLocation];
  return ident;
}

- (CGFloat)widthWithFont:(UIFont *)font;
{
  return [self jm_sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 100.)].width;
}

- (NSString *)limitToLength:(NSUInteger)ind;
{
  if ([self length] > ind)
  {
    return [self substringToIndex:ind];
  }
  else
  {
    return self;
  }
}

- (NSString *)limitToFirstWord;
{
  NSRange r = [self rangeOfString:@" "];
  if (r.location == NSNotFound)
      return self;
  
  return [self substringToIndex:r.location];
}

- (NSString *)stringMatchingPattern:(NSString *)pattern;
{
  NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
  NSArray* results = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
  
  if (results && [results count] == 1)
  {
    NSTextCheckingResult *result = [results first];
    NSString* resultString = [self substringWithRange:result.range];
    return resultString;
  }
  else
  {
    return nil;
  }
}

- (NSString *)extractSubredditLink;
{
  if (![self jm_contains:@"reddit.com"] && ![self hasPrefix:@"/r/"])
    return nil;
  
  NSString *pattern = @"/r/[a-z0-9_]{2,}/?$";
  NSString *match = [self stringMatchingPattern:pattern];
  if (!match)
    return nil;
  
  if ([match characterAtIndex:(match.length - 1)] != '/')
  {
    match = [match stringByAppendingString:@"/"];
  }
  return match;
}

- (NSString *)extractUserLink;
{
  if (![self jm_contains:@"reddit.com"] && ![self hasPrefix:@"/u/"])
    return nil;
  
  NSString *pattern = @"/u/[a-z0-9_-]{2,}/?$";
  NSString *match = [self stringMatchingPattern:pattern];
  if (!match)
    return nil;
  
  if ([match characterAtIndex:(match.length - 1)] != '/')
  {
    match = [match stringByAppendingString:@"/"];
  }
  return match;
}

- (NSString *)extractRedditPostIdent;
{
  NSString *context = self;
  NSInteger post_id_left = [context rangeOfString:@"/comments/" options:NSCaseInsensitiveSearch].location;
  if (post_id_left != NSNotFound)
  {
    post_id_left += 10;
    NSInteger post_id_right = [[context substringFromIndex:post_id_left] rangeOfString:@"/" options:NSCaseInsensitiveSearch].location;
    if (post_id_right != NSNotFound)
    {
      NSString * post_id = [context substringWithRange:NSMakeRange(post_id_left, post_id_right)];
      return post_id;
    }
  }
  return nil;
}

- (NSString *)extractContextCommentID;
{
  NSString *url = self;
  NSInteger comment_id_right = [url rangeOfString:@"?context=" options:NSCaseInsensitiveSearch].location;
  if (comment_id_right != NSNotFound)
  {
    NSInteger comment_id_left = [url rangeOfString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(comment_id_right - 9, 9)].location;
    if (comment_id_left != NSNotFound)
    {
      NSString * comment_id = [url substringWithRange:NSMakeRange(comment_id_left + 1, comment_id_right - comment_id_left - 1)];
      return comment_id;
    }
  }
  
  // if the url doesn't have a ?context flag, we can also try the case where
  // the url ends with the comment id (excluding the ?context at the end).
  NSArray *params = [url componentsSeparatedByString: @"/"];
  if (params && [params count] > 1)
  {
    NSString * last_param = [params objectAtIndex:([params count] - 1)];
    
    // we can guess that the comment ID should be between 5 and 10 characters
    // long.  even if we mistakenly identify the last parameter as a comment
    // this will only mean that we won't have the luxury of auto-scrolling for
    // the end user -- it will not cause anything to crash.
    if (last_param && [last_param length] > 5 && [last_param length] < 10)
      return last_param;
  }
  
  return nil;
}

- (NSString *)generateSubredditPathFromSubredditTitle;
{
  NSString *sr = self;
  NSMutableString *srPath = [NSMutableString string];
  
  if (![sr contains:@"/r/"] && ![sr isEmpty])
  {
    if (![sr contains:@"saved/"] && ![sr contains:@"/user/"])
    {
      [srPath appendString:@"/r/"];
    }
  }
  [srPath appendString:sr];
  return srPath;
}

- (BOOL)linkContainsSpoilerTag;
{
  NSArray *spoilerPrefixes = @[@"b", @"s", @"g", @"spoiler"];
  BSELF(NSString);
  BOOL containsSpoiler = [spoilerPrefixes match:^BOOL(NSString *tag) {
    return [blockSelf hasPrefix:[NSString stringWithFormat:@"/%@", tag]] || [blockSelf hasPrefix:[NSString stringWithFormat:@"#%@", tag]];
  }] != nil;
  return containsSpoiler;
}

- (NSString *)standardCharacterSetOnly;
{
  NSCharacterSet *trimSet = [NSCharacterSet nonBaseCharacterSet];
  NSString *trimmedReplacement = [[self componentsSeparatedByCharactersInSet:trimSet] componentsJoinedByString:@""];
  return trimmedReplacement;
}

- (BOOL)isLastCharacter:(NSString *)lastChar;
{
  NSString *lChar = [self substringFromIndex:(self.length - 1)];
  return [lChar equalsString:lastChar];
}

- (NSString *)jm_trimmed;
{
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)formattedTimeToDaysFromReferenceTime:(CGFloat)refTime;
{
  NSDate * now = [NSDate date];
  CGFloat nTime = [now timeIntervalSince1970];
  CGFloat pTime = refTime;
  CGFloat iTime = nTime - pTime;

  NSUInteger units;
  NSString *unitStr;
  if (iTime > 86400)
  {
    // days
    units = iTime / 86400;
    unitStr = @"d";
  }
  else if (iTime > 3600)
  {
    // hours
    units = iTime / 3600;
    unitStr = @"h";
  }
  else if (iTime > 60)
  {
    // minutes
    units = iTime / 60;
    unitStr = @"m";
  }
  else
  {
    units = 0;
    unitStr = @"m";
  }
  
  if (units > 10000)
    return @"-";
  
  NSString * timeStr = [NSString stringWithFormat:@"%d %@", units, unitStr];
  return timeStr;
}

+ (NSString *)formattedTimeFromReferenceTime:(CGFloat)refTime;
{
  NSDate *now = [NSDate date];
  CGFloat nTime = [now timeIntervalSince1970];
  CGFloat pTime = refTime;
  CGFloat iTime = nTime - pTime;

  NSUInteger units;
  NSString *unitStr;
  if (iTime > 31536000)
  {
    // years
    units = iTime / 31536000;
    unitStr = @"y";
  }
  else if (iTime > 86400)
  {
    // days
    units = iTime / 86400;
    unitStr = @"d";
  }
  else if (iTime > 3600)
  {
    // hours
    units = iTime / 3600;
    unitStr = @"h";
  }
  else if (iTime > 60)
  {
    // minutes
    units = iTime / 60;
    unitStr = @"m";
  }
  else
  {
    units = 0;
    unitStr = @"m";
  }
  
  if (units > 10000)
    return @"-";
  
  NSString * timeStr = [NSString stringWithFormat:@"%d %@", units, unitStr];
  return timeStr;
}

+ (NSString *)formattedNumberPrefixedWithPlusOrMinus:(NSInteger)numberToFormat;
{
  NSString *prefix = (numberToFormat >= 0) ? @"+" : @"-";
  return [NSString stringWithFormat:@"%@ %d", prefix, labs(numberToFormat)];
}

@end
