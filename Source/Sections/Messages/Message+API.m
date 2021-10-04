#import "Message+API.h"
#import "RedditAPI+Messages.h"
#import "RedditAPI+Account.h"

#define kMessageAPILastCheckedModeratorMailDatePrefKey @"kMessageAPILastCheckedModeratorMailDatePrefKey"

@interface Message(API_)
@property (readonly) NSDate *lastCheckedModeratorMailDate;
@end

@implementation Message (API)


+ (void)didProcessModeratorMail;
{
  [UDefaults setObject:[NSDate date] forKey:kMessageAPILastCheckedModeratorMailDatePrefKey];
  [UDefaults synchronize];
}

+ (void)processModeratorMailUnreadStatusForMessages:(NSArray *)messages;
{
  if (![RedditAPI shared].hasModMail)
    return;

  NSDate *lastCheckedModMailDate = [UDefaults objectForKey:kMessageAPILastCheckedModeratorMailDatePrefKey];
  if (!lastCheckedModMailDate)
    return;
  
  [messages each:^(Message *message) {
    if (!message.isUnread && [message.createdDate isLaterThanDate:lastCheckedModMailDate])
    {
      message.isUnread = YES;
    }
  }];
}

+ (AFHTTPRequestOperation *)fetchMessagesForPath:(NSString *)path params:(NSDictionary *)params onComplete:(void (^)(NSArray *messages))onComplete;
{
  NSString *url = [NSString stringWithFormat:@"%@?%@", path, [params urlEncodedString]];
  NSURLRequest *request = [[RedditAPI shared] requestForUrl:url];
  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                       {
                                         NSMutableArray *newMessages = [NSMutableArray array];
                                         NSArray *apiMessages = nil;
                                         @try
                                         {
                                           apiMessages = [JSON valueForKeyPath:@"data.children.data"];
                                         }
                                         @catch (NSException *exception)
                                         {
                                           NSLog(exception);
                                         }
                                         [Message flattenMessagesDepthFirst:apiMessages
                                                                newMessages:newMessages
                                                                     parent:nil];

                                         if ([path jm_contains:@"moderator"])
                                         {
                                           [newMessages each:^(Message *message) {
                                             message.i_isModMail = YES;
                                           }];

                                           [Message processModeratorMailUnreadStatusForMessages:newMessages];
                                           [Message didProcessModeratorMail];
                                         }
                                         
                                         onComplete(newMessages);
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                       }];
  [operation start];
  return operation;
}

+ (AFHTTPRequestOperation *)fetchLastSubmittedMessageCommentForUser:(NSString *)username onComplete:(void(^)(Message *messageCommentOrNil))onComplete;
{
  NSDictionary *params = @{
                           @"limit" : @(1),
                           @"sort" : @"new",
                           };
  
  NSString *apiPath = [NSString stringWithFormat:@"/user/%@/comments/.json", username];
  AFHTTPRequestOperation *op = [self fetchMessagesForPath:apiPath params:params onComplete:^(NSArray *messages) {
    if (messages.count >= 1)
    {
      onComplete(messages.firstObject);
    }
    else
    {
      onComplete(nil);
    }
  }];
  return op;
}


#pragma mark - private

// Mod Mail supports threaded messages, but we don't yet. In the meantime, flatten the tree.
+ (void)flattenMessagesDepthFirst:(NSArray *)apiMessages
                      newMessages:(NSMutableArray *)newMessages
                           parent:(Message *)parent
{
  [apiMessages each:^(id item) {
    NSDictionary *itemDictionary = [item jm_dictionaryRemovingNullObjects];
    Message *message = [[Message alloc] initWithDictionary:itemDictionary];
    message.i_parentMessage = parent;
    [newMessages addObject:message];

    if (JMIsClass(itemDictionary[@"replies"], NSDictionary))
    {
      @try
      {
        NSArray *apiMessageChildren =
            [itemDictionary valueForKeyPath:@"replies.data.children.data"];
        [Message flattenMessagesDepthFirst:apiMessageChildren
                               newMessages:newMessages
                                    parent:message];
      }
      @catch (NSException *exception)
      {
        NSLog(exception);
      }
    }
  }];
}

@end
