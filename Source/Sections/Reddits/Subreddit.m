//
//  Subreddit.m
//  AlienBlue
//
//  Created by J M on 7/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "Subreddit.h"
#import "SessionManager.h"

@implementation Subreddit

+ (Subreddit *)subredditFromDictionary:(NSDictionary *)dictionary;
{
    Subreddit *sr = [[Subreddit alloc] init];

    sr.rawDictionary = dictionary;
    sr.ident = [dictionary objectForKey:@"id"];
    sr.name = [dictionary objectForKey:@"name"];
    sr.longTitle = [dictionary objectForKey:@"title"];
    
    if ([dictionary objectForKey:@"subscribers"])
    {
        sr.numSubscribers = [[dictionary objectForKey:@"subscribers"] unsignedIntegerValue];
    }
    
    sr.url = [dictionary objectForKey:@"url"];
    sr.subredditDescription = [dictionary objectForKey:@"description"];
  
    sr.submitRulesHtml = [dictionary objectForKey:@"submit_text_html"];
    sr.submitRulesText = [dictionary objectForKey:@"submit_text"];
    sr.submitAllowedTypesText = [dictionary objectForKey:@"submission_type"];
  
	NSMutableString * str = [NSMutableString stringWithString:sr.url];
	[str replaceOccurrencesOfString:@"/r/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
      
  sr.title = [[self class] formattedTitleForSubreddit:str];
    
    return sr;
}

+ (NSString *)formattedTitleForSubreddit:(NSString *)sr;
{
  if ([sr equalsString:@"IAMA"])
    return @"IAmA";
  
  if ([sr equalsString:@"IPhone"])
    return @"iPhone";
  
  if ([sr equalsString:@"IPad"])
    return @"iPad";
  
  if ([sr equalsString:@"Iosgaming"])
    return @"iOSGaming";

  if ([sr equalsString:@"Iosprogramming"])
    return @"iOSProgramming";
  
  if ([sr equalsString:@"Ios"])
    return @"iOS";
  
  return [sr capitalizedString];
}

- (NSString *)iconIdent;
{
    NSMutableString *iconIdent = [NSMutableString stringWithString:self.url];
    [iconIdent removeOccurrencesOfString:@"/r/"];
    [iconIdent removeOccurrencesOfString:@"/"];    
    return iconIdent;
}

+ (Subreddit *)subredditWithUrl:(NSString *)url name:(NSString *)name;
{
    Subreddit *sr = [[Subreddit alloc] init];
    sr.name = name;
    sr.url = url;

	NSMutableString * str = [NSMutableString stringWithString:url];
	[str replaceOccurrencesOfString:@"/r/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString:@"/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
  sr.title = [[self class] formattedTitleForSubreddit:str];
    
    return sr;
}

- (BOOL)isNativeSubreddit;
{
    NSString *url = self.url;
    if ([url isEmpty] || [url equalsString:@"/r/all/"] || [url equalsString:@"/r/mod/"])
        return NO;
    
    if ([url contains:@"/user/"] || [url contains:@"+"] || [url contains:@"saved/"])
        return NO;
    
    return YES;    
}


//- (NSString *)description;
//{
//    return [NSString stringWithFormat:@"%@ : %@", self.title, self.url];
//}


#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
//    NSMutableDictionary *subredditDictionary = nil;

//    if (self.rawDictionary)
//    {
//        subredditDictionary = [NSMutableDictionary dictionaryWithDictionary:self.rawDictionary];
//    }
//    else 
//    {
//        subredditDictionary = [NSMutableDictionary dictionary];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.title forKey:@"title"];
//    [aCoder encodeObject:[NSNumber numberWithBool:self.subscribed] forKey:@"subscribed"];
//    }
//    [aCoder encodeObject:subredditDictionary forKey:@"subredditDictionary"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    Subreddit *s = nil;
    
    NSString *name = [aDecoder decodeObjectForKey:@"name"];
    NSString *url = [aDecoder decodeObjectForKey:@"url"];
    NSString *title = [aDecoder decodeObjectForKey:@"title"];
//    NSNumber *isSubscribed = [aDecoder decodeObjectForKey:@"subscribed"];
    SET_IF_EMPTY(name, @"");
    if (url)
    {
        s = [Subreddit subredditWithUrl:url name:name];
        if (title)
        {
          s.title = [[self class] formattedTitleForSubreddit:title];
        }
//        if (isSubscribed)
//        {
//            s.subscribed = [isSubscribed boolValue];
//        }
    }
    return s;
}

- (BOOL)subscribed;
{
    return [[SessionManager manager].subredditPrefs.folderForSubscribedReddits containsSubreddit:self];
}

- (BOOL)allowsLinkPosts;
{
  return [self.submitAllowedTypesText jm_contains:@"any"] || [self.submitAllowedTypesText jm_contains:@"link"];
}

- (BOOL)allowsSelfPosts;
{
  return [self.submitAllowedTypesText jm_contains:@"any"] || [self.submitAllowedTypesText jm_contains:@"self"];
}

@end
