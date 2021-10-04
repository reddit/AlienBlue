#import "RedditAPI+Comments.h"
#import "RedditAPI+DeprecationPatches.h"

@interface RedditAPI (Comments_)
@property (ab_weak) id commentReplyResultCallBackTarget;
@end

@implementation RedditAPI (Comments)

SYNTHESIZE_ASSOCIATED_WEAK(NSObject, commentReplyResultCallBackTarget, CommentReplyResultCallBackTarget);

- (void)deleteCommentWithID:(NSString *)commentID;
{
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/del", self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&executed=deleted&id=%@",commentID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(deleteResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)submitChangeReply:(NSMutableDictionary *)item withCallBackTarget:(id)target;
{
  self.commentReplyResultCallBackTarget = target;
  NSString *itemID = [item valueForKey:@"name"];
  NSString *replyText = [item valueForKey:@"replyText"];
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/editusertext", self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&text=%@&thing_id=%@", [replyText jm_escaped], itemID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(replyResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)submitReply:(NSMutableDictionary *)item withCallBackTarget:(id)target;
{
  self.commentReplyResultCallBackTarget = target;
  NSString *itemID = [item valueForKey:@"name"];
  NSString *replyText = [item valueForKey:@"replyText"];
  NSString *url = [[NSString alloc] initWithFormat:@"%@/api/comment", self.server];
  NSString *params = [[NSString alloc] initWithFormat:@"api_type=json&text=%@&thing_id=%@", [replyText jm_escaped], itemID];
  [self doPostToURL:url withParams:params connectionCategory:kConnectionCategoryOther callBackTarget:self callBackMethod:@selector(replyResponseReceived:) failedMethod:@selector(connectionFailedDialog:)];
}

- (void)replyToItem:(NSMutableDictionary *)item callbackTarget:(id)callbackTarget;
{
  if (!item || ![item objectForKey:@"replyText"] || [[item valueForKey:@"replyText"] length] == 0)
    return;
  
  if ([item objectForKey:@"editMode"])
  {
    [self submitChangeReply:item withCallBackTarget:callbackTarget];
  }
  else
  {
    [self submitReply:item withCallBackTarget:callbackTarget];
  }
}

- (void)replyResponseReceived:(id)sender;
{
  JMJSONParser *parser = [[JMJSONParser alloc] init];
  NSData *data = (NSData *) sender;
  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSDictionary *response = [[parser objectWithString:responseString error:nil] objectForKey:@"json"];
  
  if (!response || ![response isKindOfClass:[NSDictionary class]])
    return;
  
  NSDictionary * responseDictionary = [[[[response objectForKey:@"data"] objectForKey:@"things"] objectAtIndex:0] objectForKey:@"data"];
  
  if (!responseDictionary)
  {
    [self displayReplyErrorIfAvailableFromResponse:response];
    return;
  }
  
  if ([responseString length] < 10)
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bad Response Received" message:@"Reddit has responded with an error. The servers may currently be under heavy load." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
  }
  else if (self.commentReplyResultCallBackTarget)
  {
    [self.commentReplyResultCallBackTarget rd_performSelector:@selector(apiReplyResponse:) withObject:responseDictionary];
  }
}

- (void)displayReplyErrorIfAvailableFromResponse:(NSDictionary *)response
{
  NSArray *errors = [response valueForKeyPath:@"errors"];
  if (!errors || errors.count == 0)
    return;
  
  NSArray *error = [errors objectAtIndex:0];
  if (error && [error count] > 0)
  {
    NSString *message = [error objectAtIndex:1];
    if (message)
    {
      NSString *formattedMessage = [NSString stringWithFormat:@"Reddit returned an error \"%@\". Alien Blue has saved a backup copy of your comment.", [message capitalizedString]];
      UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Failed to submit" message:formattedMessage];
      [alert bk_setCancelButtonWithTitle:@"OK" handler:nil];
      [alert show];
    }
  }
}

- (void)resetConnectionsForComments;
{
  self.commentReplyResultCallBackTarget = nil;
  [self clearConnectionsWithCategory:kConnectionCategoryComments];
}

@end
