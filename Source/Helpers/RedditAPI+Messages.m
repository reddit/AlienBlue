#import "RedditAPI+Messages.h"
#import "RedditAPI+DeprecationPatches.h"
#import "RedditAPI+Posting.h"
#import "RedditAPI+Account.h"
#import "SessionManager+Authentication.h"

@interface RedditAPI (Messages_)
@property (ab_weak) id inboxCallBackTarget;
@property (ab_weak) id submitMessageCallBackTarget;
@end

@implementation RedditAPI (Messages)

SYNTHESIZE_ASSOCIATED_WEAK(NSObject, inboxCallBackTarget, InboxCallBackTarget);
SYNTHESIZE_ASSOCIATED_WEAK(NSObject, submitMessageCallBackTarget, SubmitMessageCallBackTarget);

- (void)submitDirectMessage:(NSMutableDictionary *)messageToSubmit withCallBackTarget:(id)target;
{
  if (!messageToSubmit)
    return;
  
  NSString * submitUrl = [[NSString alloc] initWithFormat:@"%@/api/compose", self.server];
  NSMutableString *p = [NSMutableString new];
  [p appendFormat:@"id=#compose-message&to=%@&subject=%@&text=%@&iden=%@&captcha=%@",
   [[messageToSubmit valueForKey:@"toUsername"] jm_escaped],
   [[messageToSubmit valueForKey:@"subject"] jm_escaped],
   [[messageToSubmit valueForKey:@"content"] jm_escaped],
   [messageToSubmit valueForKey:@"captchaID"],
   [messageToSubmit valueForKey:@"captchaEntered"]
   ];
  
  self.submitMessageCallBackTarget = target;
  [self doPostToURL:submitUrl withParams:p connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(submitMessageResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)submitMessageResponseReceived:(id)sender;
{
  NSData *data = (NSData *) sender;
  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSMutableArray *errors = [self getErrorsInPostSubmission:responseString];
  
  if (self.submitMessageCallBackTarget)
  {
    [self.submitMessageCallBackTarget rd_performSelector:@selector(submitResponse:) withObject:errors];
  }
}

- (void)inboxFetchResponse:(id)sender;
{
  self.loadingMessages = NO;
  NSData * data = (NSData *) sender;
  JMJSONParser *parser = [[JMJSONParser alloc] init];
  NSString * responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  
  NSMutableDictionary *response = [parser objectWithString:responseString error:nil];
  if (self.inboxCallBackTarget)
  {
    [self.inboxCallBackTarget rd_performSelector:@selector(apiInboxResponse:) withObject:response];
  }
  
  // the mark=false flag does not work when using .json so we need to make an extra call
  // to /message/unread even though we will not need the response.  A call to this URL will
  // mark all unread messages as "read".
  if([[UDefaults valueForKey:kABSettingKeyAutoMarkMessagesAsRead] boolValue] && self.hasMail)
  {
    [self markAllMessagesAsRead];
  }
}

- (void)fetchMessagesWithCategoryUrl:(NSString *)categoryUrl afterMessageID:(NSString *)messageID withCallBackTarget:(id)target
{
  self.loadingMessages = YES;
  self.inboxCallBackTarget = target;
  NSUInteger fetchCount = 25;
  NSString *params = @"";
  if ([messageID length] > 0)
  {
    params = [[NSString alloc] initWithFormat:@"&limit=%d&after=%@", fetchCount, messageID];
  }
  NSString *url = [[NSString alloc] initWithFormat:@"%@%@.json?mark=false%@", self.server, categoryUrl, params];
  [self doGetURL:url withConnectionCategory:kConnectionCategoryMessages callBackTarget:self callBackMethod:@selector(inboxFetchResponse:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)markAllModMailAsRead
{
  self.hasModMail = NO;
  [[SessionManager manager] didManuallyUpdateUserInformation];
  
  NSString *url = [[NSString alloc] initWithFormat:@"%@/message/moderator.json?mark=true", self.server];
  [self doGetURL:url withConnectionCategory:kConnectionCategoryMessages callBackTarget:nil callBackMethod:nil failedMethod:@selector(connectionFailedDialog:)];
}

- (void)markAllMessagesAsRead
{
  self.hasMail = NO;
  [[SessionManager manager] didManuallyUpdateUserInformation];
  
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/read_all_messages", self.server];
  [self doPostToURL:url withParams:nil connectionCategory:kConnectionCategoryOther callBackTarget:nil callBackMethod:@selector(markReadResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)markMessageReadWithID:(NSString *)messageID
{
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/read_message",self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&executed=read&id=%@",messageID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(markReadResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)resetConnectionsForMessages;
{
  self.inboxCallBackTarget = nil;
  [self clearConnectionsWithCategory:kConnectionCategoryMessages];
}

@end
