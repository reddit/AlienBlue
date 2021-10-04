//
//  Post.m
//  AlienBlue
//
//  Created by J M on 3/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Post.h"
#import "Post+Style.h"
#import "RedditAPI.h"
#import "Resources.h"
#import "NSString+ABLegacyLinkTypes.h"

@implementation Post
@synthesize score = score_;
@synthesize visited = visited_;

+ (Post *)postFromDictionary:(NSDictionary *)dictionary;
{
    Post *post = [[Post alloc] init];
  
    [post setVotableElementPropertiesFromDictionary:dictionary];
    
    NSMutableString *title = [NSMutableString string];
    if ([dictionary objectForKey:@"title"] && [dictionary objectForKey:@"title"])
    {
        NSString *rawTitle = [dictionary objectForKey:@"title"];
        rawTitle = [rawTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [title appendString:rawTitle];
        [title replaceString:@"&amp;" withString:@"&"];
        [title replaceString:@"&gt;" withString:@">"];
        [title replaceString:@"&lt;" withString:@"<"];
        [title removeOccurrencesOfString:@"\n"];
    }
    post.title = title;
    SET_IF_EMPTY(post.title, @"");
    
    post.selftext = [dictionary objectForKey:@"selftext"];
    post.selftextHtml = [dictionary objectForKey:@"selftext_html"];
    post.linkFlairText = [dictionary objectForKey:@"link_flair_text"];
    SET_IF_EMPTY(post.linkFlairText, @"");
  
    post.url = [NSString ab_fixImgurLink:[[dictionary objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]];
    if (([post.subreddit contains:@"gifs"] || [post.subreddit contains:@"holdmybeer"]) && [post.url contains:@"imgur"] && [post.url contains:@".jpg"])
    {
        post.url = [post.url stringByReplacingOccurrencesOfString:@".jpg" withString:@".gif"];
    }
    post.url = [post.url stringByReplacingOccurrencesOfString:@"np.reddit.com" withString:@"www.reddit.com"];
  
    post.domain = [dictionary objectForKey:@"domain"];
    SET_IF_EMPTY(post.domain, @"reddit.com");
    post.domain = [post.domain stringByReplacingOccurrencesOfString:@"np.reddit.com" withString:@"reddit.com"];
  
    post.rawThumbnail = [dictionary objectForKey:@"thumbnail"];
    SET_IF_EMPTY(post.rawThumbnail, @"noimage");
    
    post.numComments = [[dictionary objectForKey:@"num_comments"] integerValue];
  
    post.stickied = [[dictionary objectForKey:@"stickied"] boolValue];
    post.nsfw = [[dictionary objectForKey:@"over_18"] boolValue];
    post.hidden = [[dictionary objectForKey:@"hidden"] boolValue];
    post.saved = [[dictionary objectForKey:@"saved"] boolValue];
    post.selfPost = [[dictionary objectForKey:@"is_self"] boolValue];
    post.promoted = [[dictionary objectForKey:@"promoted"] boolValue];
    post.gilded = [[dictionary objectForKey:@"gilded"] integerValue];
    post.preview = [dictionary objectForKey:@"preview"];
    post.subredditDetail = [dictionary objectForKey:@"sr_detail"];

    [post updateVisitedStatus];
  
//    post.rawThumbnail = @"http://localhost:8000/tall.png";
//    post.url = post.rawThumbnail;
  
    return post;
}

+ (Post *)postSkeletonFromRedditUrl:(NSString *)url;
{
  NSString *threadUrl = url;
  if ([threadUrl contains:@"http://redd.it/"])
  {
    // tiny hack to allow the reddit postID parser to work without modification
    threadUrl = [threadUrl stringByReplacingOccurrencesOfString:@"http://redd.it/" withString:@"http://redd.it/comments/"];
    threadUrl = [threadUrl stringByAppendingString:@"/"];
  }

  NSString * parsedPostID = [threadUrl extractRedditPostIdent];
  if (!parsedPostID || [parsedPostID isEmpty])
    return nil;
  
  NSMutableDictionary * npost = [[NSMutableDictionary alloc] init];
  [npost setValue:parsedPostID forKey:@"id"];
  [npost setValue:[NSString stringWithFormat:@"t3_%@",parsedPostID] forKey:@"name"];
  [npost setValue:@"" forKey:@"type"];
  [npost setValue:@"self.reddit" forKey:@"url"];
  NSString *commentID = [threadUrl extractContextCommentID];
  NSString *contextId = nil;
  if (commentID && [commentID length] > 0)
  {
    contextId = [NSString stringWithFormat:@"t1_%@",commentID];
  }
  
  Post *p = [Post postFromDictionary:npost];
  p.contextCommentIdent = contextId;
  return p;
}

- (void)updateVisitedStatus;
{
    self.visited = [self isInVisitedList];
}

- (NSString *)thumbnail
{  
    if (!self.rawThumbnail || [self.rawThumbnail length] == 0)
        return nil;

    if ([self.rawThumbnail contains:@"default"])
        return nil;

    if ([self.rawThumbnail contains:@"noimage"])
        return nil;

    if ([self.rawThumbnail contains:@"nsfw"])
        return nil;

    if (self.selfPost)
        return nil;
    
    if (![Resources shouldShowPostThumbnails])
        return nil;
  
    return self.rawThumbnail;
}

- (NSString *)tinyDomain;
{
    if (JMIsEmpty(self.domain))
      return nil;
  
    NSMutableString *tiny = [NSMutableString stringWithString:self.domain];
    [tiny replaceString:@"quickmeme" withString:@"qkme"];
  
    NSArray *components = [tiny componentsSeparatedByString:@"."];
  
    if (components.count >= 2)
    {
      NSString *secondLast = [components objectAtIndex:components.count - 2];
      if (secondLast.length >= 4)
      {
        return secondLast;
      }
    }
  
    [tiny removeOccurrencesOfString:@".com"];
    [tiny removeOccurrencesOfString:@".net"];
    [tiny removeOccurrencesOfString:@".org"];
    [tiny removeOccurrencesOfString:@".co.uk"];
    [tiny replaceString:@"i.imgur" withString:@"imgur"];
  
    return tiny;
}

//- (void)setScore:(NSInteger)score;
//{
//    score_ = score;
//    self.cachedStyledSubdetails = nil;
//}

- (void)markVisited;
{	    
  self.visited = YES;
  [self flushCachedStyles];
  
  if (JMIsEmpty(self.name))
      return;
  
	NSMutableArray * visitedList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyVisitedList]];
    
	[visitedList insertObject:self.name atIndex:0];
    
  NSArray * subArray = [visitedList subarrayWithRange:NSMakeRange(0, MIN(500, [visitedList count]))];

	[[NSUserDefaults standardUserDefaults] setObject:subArray forKey:kABSettingKeyVisitedList];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isInVisitedList;
{
    NSArray *visitedList = (NSMutableArray *) [[NSUserDefaults standardUserDefaults] objectForKey:kABSettingKeyVisitedList];
	if (!visitedList || [visitedList count] == 0)
		return NO;

	BOOL isVisited = NO;

	for (NSString * visitedPostName in visitedList)
	{
		if ([visitedPostName isEqualToString:self.name])
			isVisited = YES;
	}
    return isVisited;
}

- (BOOL)visited;
{
    if (![UDefaults boolForKey:kABSettingKeyMarkPostsAsRead])
        return NO;
    
    return visited_;
}

- (LinkType)linkType;
{
    return [CommentLink linkTypeFromUrl:self.url];
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.legacyDictionary];
    [dictionary setObject:[NSNumber numberWithBool:self.saved] forKey:@"saved"];
    [dictionary setObject:[NSNumber numberWithBool:self.hidden] forKey:@"hidden"];

    if (self.voteState == VoteStateUpvoted)
        [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"likes"];
    else if (self.voteState == VoteStateDownvoted)
        [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"likes"];
    
    [aCoder encodeObject:dictionary forKey:@"legacyDictionary"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    Post *p = nil;
    NSDictionary *legacyDictionary = [aDecoder decodeObjectForKey:@"legacyDictionary"];
    if (legacyDictionary)
    {
        p = [Post postFromDictionary:legacyDictionary];
    }
    return p;
}

- (BOOL)needsNSFWWarning;
{
    return [self.rawThumbnail contains:@"nsfw"] || [self.title contains:@"nsfw"];
}

- (NSString *)linkTypeIconName;
{
  NSString *weblinkIconName = @"browser-icon";
  
  if ([self.url contains:@".gif"])
    weblinkIconName = @"gif-icon";
  else if ([self.url jm_contains:@"imgur.com"] && ([self.url jm_contains:@"/a/"] || [self.url jm_contains:@"gallery"]))
    weblinkIconName = @"album-icon";
  else if (self.linkType == LinkTypePhoto)
    weblinkIconName = @"photo-icon";
  else if (self.linkType == LinkTypeVideo)
    weblinkIconName = @"video-icon";
  else if (self.linkType == LinkTypeSelf)
    weblinkIconName = @"self-icon";
  return weblinkIconName;
}

- (BOOL)hasExternalLink;
{
  return !self.selfPost || ![self.url jm_contains:self.permalink];
}

- (NSString *)linkFlairTextForPresentation;
{
  if ([UDefaults boolForKey:kABSettingKeyShowNSFWRibbon] && self.needsNSFWWarning)
    return @"NSFW";
  
  if (self.stickied)
    return @"STICKY";
  
  if (self.promoted)
    return @"SPONSORED";
  
  if ([UDefaults boolForKey:kABSettingKeyShowPostFlair] && !JMIsEmpty(self.linkFlairText))
    return [self.linkFlairText jm_truncateToLength:14];
  
  return nil;
}

@end
