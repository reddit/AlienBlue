#import "NSString+ABLegacyLinkTypes.h"

@implementation NSString (ABLegacyLinkTypes)

+ (NSString *)ab_useTinyResImgurVersion:(NSString *)link
{
  NSMutableString *nlink = [NSMutableString stringWithString:[self ab_fixImgurLinkForCanvas:link]];
  if(link && [link rangeOfString:@"imgur" options:NSCaseInsensitiveSearch].location != NSNotFound)
  {
    [nlink replaceOccurrencesOfString:@".jpg" withString:@"s.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [nlink length])];
    [nlink replaceOccurrencesOfString:@".jpeg" withString:@"s.jpeg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [nlink length])];
    [nlink replaceOccurrencesOfString:@".png" withString:@"s.png" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [nlink length])];
    return nlink;
  }
  else
  {
    return link;
  }
}

+ (NSString *)ab_useMediumThumbnailImgurVersion:(NSString *)link
{
  NSMutableString *nlink = [NSMutableString stringWithString:[self ab_fixImgurLinkForCanvas:link]];
  if(link && [link rangeOfString:@"imgur" options:NSCaseInsensitiveSearch].location != NSNotFound)
  {
    [nlink replaceOccurrencesOfString:@".jpg" withString:@"m.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [nlink length])];
    [nlink replaceOccurrencesOfString:@".jpeg" withString:@"m.jpeg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [nlink length])];
    [nlink replaceOccurrencesOfString:@".png" withString:@"m.png" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [nlink length])];
    return nlink;
  }
  else
  {
    return link;
  }
}

+ (NSString *)ab_useLowResImgurVersion:(NSString *)link
{
  if(link && ([link rangeOfString:@"http://imgur" options:NSCaseInsensitiveSearch].location != NSNotFound || [link rangeOfString:@"http://i.imgur" options:NSCaseInsensitiveSearch].location != NSNotFound))
  {
    NSMutableString * nlink = [NSMutableString stringWithString:link];
    [nlink replaceOccurrencesOfString:@".jpg" withString:@"l.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [nlink length])];
    [nlink replaceOccurrencesOfString:@".jpeg" withString:@"l.jpeg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [nlink length])];
    [nlink replaceOccurrencesOfString:@".png" withString:@"l.png" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [nlink length])];
    
    // on the off chance that a user has already directly linked to a large thumb of the image
    // we can remove the redundant l
    [nlink replaceOccurrencesOfString:@"ll." withString:@"l." options:NSLiteralSearch range:NSMakeRange(0, [nlink length])];
    return nlink;
  }
  else
  {
    return link;
  }
}

// this method will remove everything after the "?" in an imgur URL
// like ?full&size=l etc.
+ (NSString *)ab_removeImgurURLParameters:(NSString *)link
{
  if(link && [link rangeOfString:@"imgur" options:NSCaseInsensitiveSearch].location != NSNotFound)
  {
    NSMutableString * nlink = [NSMutableString stringWithString:link];
    NSRange quesRange = [nlink rangeOfString:@"?"];
    if (quesRange.location != NSNotFound)
    {
      link = [nlink substringWithRange:NSMakeRange(0, quesRange.location)];
    }
    
    // remove further ampersands, for example in a url like:
    // http://imgur.com/og2hrl&rnJhw&4Mp8P&igH29
    nlink = [NSMutableString stringWithString:link];
    NSRange ampersandRange = [nlink rangeOfString:@"&"];
    if (ampersandRange.location != NSNotFound)
    {
      link = [nlink substringWithRange:NSMakeRange(0, ampersandRange.location)];
    }
  }
  return link;
}

// this method allows drawing imgur links inline if the link isn't pointing directly
// to the image file.
+ (NSString *)ab_fixImgurLink:(NSString *)url
{
  NSString *link = [url copy];
  link = [link stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  link = [link stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  
  // if it's not from imgur, leave the url alone
  if (link &&
      [link rangeOfString:@"http://www.imgur" options:NSCaseInsensitiveSearch].location == NSNotFound &&
      [link rangeOfString:@"http://i.imgur" options:NSCaseInsensitiveSearch].location == NSNotFound &&
      [link rangeOfString:@"http://imgur" options:NSCaseInsensitiveSearch].location == NSNotFound)
    return link;
  
  if(
     [link rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location == NSNotFound	&&
     [link rangeOfString:@".png" options:NSCaseInsensitiveSearch].location == NSNotFound	&&
     [link rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location == NSNotFound	&&
     [link rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location == NSNotFound &&
     [link rangeOfString:@"/a/" options:NSCaseInsensitiveSearch].location == NSNotFound &&
     [link rangeOfString:@"/gallery/" options:NSCaseInsensitiveSearch].location == NSNotFound &&
     [[NSUserDefaults standardUserDefaults] boolForKey:kABSettingKeyUseDirectImgurLink]
     )
  {
    // if there is no extension on an imgur link we add one here.  Imgur doesn't
    // care about the type of extension, as long as one exists it will return the image.
    link = [self ab_removeImgurURLParameters:link];
    
    // filter out subreddit appended links like /r/abc/123.jpg
    NSString *pattern = @"/r/[a-z0-9]{2,}/";
    NSString *match = [link stringMatchingPattern:pattern];
    if (match)
    {
      link = [link stringByReplacingOccurrencesOfString:match withString:@"/"];
    }
    
    link = [link stringByAppendingString:@".jpg"];
    link = [link stringByReplacingOccurrencesOfString:@"http://imgur.com" withString:@"http://i.imgur.com"];
    link = [link stringByReplacingOccurrencesOfString:@"http://www.imgur.com" withString:@"http://i.imgur.com"];
  }
  return link;
}

// this overrides the use_direct_imgur_link setting
+ (NSString *)ab_fixImgurLinkForCanvas:(NSString *)url;
{
  NSString *link = [url copy];
  link = [link stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  link = [link stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  
  // if it's not from imgur, leave the url alone
  if (link &&
      [link rangeOfString:@"http://www.imgur" options:NSCaseInsensitiveSearch].location == NSNotFound &&
      [link rangeOfString:@"http://i.imgur" options:NSCaseInsensitiveSearch].location == NSNotFound &&
      [link rangeOfString:@"http://imgur" options:NSCaseInsensitiveSearch].location == NSNotFound
      )
    return link;
  
  if(
     [link rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location == NSNotFound	&&
     [link rangeOfString:@".png" options:NSCaseInsensitiveSearch].location == NSNotFound	&&
     [link rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location == NSNotFound	&&
     [link rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location == NSNotFound &&
     [link rangeOfString:@"/a/" options:NSCaseInsensitiveSearch].location == NSNotFound &&
     [link rangeOfString:@"gallery" options:NSCaseInsensitiveSearch].location == NSNotFound
     )
  {
    // if there is no extension on an imgur link we add one here.  Imgur doesn't
    // care about the type of extension, as long as one exists it will return the image.
    link = [self ab_removeImgurURLParameters:link];
    link = [link stringByReplacingOccurrencesOfString:@"http://imgur" withString:@"http://i.imgur"];
    link = [link stringByAppendingString:@".jpg"];
  }
  return link;
}

+ (BOOL)ab_isImageLink:(NSString *)link
{
  // we need to treat .gifs as non-images as they will not work when shown inline
  if([link rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location != NSNotFound)
  {
    return NO;
  }
  
  if([link rangeOfString:@"imgur.com/a/" options:NSCaseInsensitiveSearch].location != NSNotFound)
  {
    return NO;
  }
  
  if([link rangeOfString:@".html" options:NSCaseInsensitiveSearch].location != NSNotFound)
  {
    return NO;
  }
  
  if([link rangeOfString:@".php" options:NSCaseInsensitiveSearch].location != NSNotFound)
  {
    return NO;
  }
  
  if([link rangeOfString:@".jpg?" options:NSCaseInsensitiveSearch].location != NSNotFound)
  {
    return NO;
  }
  
  if ([link contains:@"qkme.me"] || [link contains:@"quickmeme.com"])
    return YES;
  
  if(
     [link rangeOfString:@".png" options:NSCaseInsensitiveSearch].location != NSNotFound	||
     [link rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound	||
     [link rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound ||
     (
      ([link rangeOfString:@"http://imgur" options:NSCaseInsensitiveSearch].location != NSNotFound ||
       [link rangeOfString:@"http://i.imgur" options:NSCaseInsensitiveSearch].location != NSNotFound
       )
      && [[NSUserDefaults standardUserDefaults] boolForKey:kABSettingKeyUseDirectImgurLink])
     )
  {
    return true;
  }
  else
  {
    return false;
  }
}

+ (BOOL)ab_isVideoLink:(NSString *)link
{
  return ([link rangeOfString:@"youtube" options:NSCaseInsensitiveSearch].location != NSNotFound);
}

+ (BOOL)ab_isSelfLink:(NSString *)link
{
  return (
     [link rangeOfString:@"self." options:NSCaseInsensitiveSearch].location != NSNotFound ||
     [link rangeOfString:@"reddit.com/comments/" options:NSCaseInsensitiveSearch].location != NSNotFound ||
     [link rangeOfString:@"reddit.com/r/" options:NSCaseInsensitiveSearch].location != NSNotFound ||
     [link contains:@"reddit.local"]
  );
}

+ (NSString *)ab_getLinkType:(NSString *)url
{
  NSString * linkType;
  if ([self ab_isImageLink:url])
    linkType = @"image";
  else if ([self ab_isSelfLink:url])
    linkType = @"self";
  else if ([self ab_isVideoLink:url])
    linkType = @"video";
  else
    linkType = @"article";
  return linkType;
}

@end
