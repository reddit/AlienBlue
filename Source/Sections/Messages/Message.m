#import "Message.h"
#import "RedditAPI+Messages.h"

@implementation Message

- (id)initWithDictionary:(NSDictionary *)dictionary;
{
  JM_SUPER_INIT(initWithDictionary:dictionary);

  self.wasComment = [dictionary[@"was_comment"] boolValue];
  self.linkTitle = dictionary[@"link_title"];

  self.firstMessageIdent = [dictionary[@"first_message"] unsignedIntegerValue];
  self.firstMessageName = dictionary[@"first_message_name"];
  self.destinationUser = dictionary[@"dest"];

  self.isUnread = [dictionary[@"new"] boolValue];
  self.subject = dictionary[@"subject"];
  self.contextUrl = dictionary[@"context"];
  
  return self;
}

- (void)preprocessStyles;
{
}

- (NSString *)titleForPresentation;
{
  NSString *title = self.subject;

  if (JMIsNull(title) || [title jm_matches:@"comment reply"] || [title jm_matches:@"post reply"])
  {
    title = self.linkTitle;
  }
  title = [title jm_removeOccurrencesOfString:@"re: "];
  
  if (self.i_isModMail)
  {
    title = [NSString stringWithFormat:@"%@ ┊ %@", title, self.subreddit];

    if ([self.author jm_matches:@"automoderator"])
    {
      // adds a unique number of invisible fixed-space characters so
      // that other messages with the same subject don't get grouped
      // together when presenting
      NSUInteger uniqueSuffixLength = self.body.length + self.author.length;
      NSString *uniqueSuffixPadding = [@"" stringByPaddingToLength:uniqueSuffixLength withString:@"\u200b" startingAtIndex:0];
      title = [title stringByAppendingString:uniqueSuffixPadding];
    }
  }
  
  return title;
}

- (NSString *)metadataForPresentation;
{
  BOOL hasScore = !JMIsNull([self.legacyDictionary objectForKey:@"ups"]);

  NSString *joinerString = hasScore ? @"  •  " : @"";
  NSString *scoreString = hasScore ? self.formattedScoreTinyWithPlus : @"";
  NSString *timestamp = self.tinyTimeAgo;
  
  return [NSString stringWithFormat:@"%@%@%@", scoreString, joinerString, timestamp];
}

- (void)markAsRead;
{
  if (!self.isUnread)
    return;
  
  self.isUnread = NO;
  [[RedditAPI shared] markMessageReadWithID:self.name];
}

@end
