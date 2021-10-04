#import "MessagesViewController+API.h"
#import "RedditAPI+Messages.h"
#import "Message+API.h"
#import "NMessageCell.h"

@interface MessagesViewController (API_)

@end

@implementation MessagesViewController (API)

SYNTHESIZE_ASSOCIATED_STRONG(AFHTTPRequestOperation, loadMessagesOperation, LoadMessagesOperation);

- (NSDictionary *)messageRequestOptionsRemoveExisting:(BOOL)removeExisting;
{
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  if (!removeExisting && [self nodeCount] > 2 && [self.nodes.last isKindOfClass:[MessageNode class]])
  {
    NSString *lastMessageId = [(MessageNode *)self.nodes.last message].name;
    [params setObject:lastMessageId forKey:@"after"];
  }
  
  NSUInteger fetchCount = 25;
  [params setObject:[NSNumber numberWithInt:fetchCount] forKey:@"limit"];

  [params setObject:@"false" forKey:@"mark"];
  return params;
};

- (void)fetchMessagesRemoveExisting:(BOOL)removeExisting onComplete:(void (^)(NSArray *messages))onComplete;
{
  [self.loadMessagesOperation cancel];
  self.loadMessagesOperation = nil;
  
  NSString *queryPath = [self.boxUrl stringByAppendingString:@"/.json"]; 
  NSDictionary *params = [self messageRequestOptionsRemoveExisting:removeExisting];
  
  BSELF(MessagesViewController);
  [RedditAPI shared].loadingMessages = YES;
  self.loadMessagesOperation = [Message fetchMessagesForPath:queryPath params:params onComplete:^(NSArray *messages) {
    blockSelf.loadMessagesOperation = nil;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      [messages each:^(Message *message) {
        [message preprocessStyles];
      }];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [RedditAPI shared].loadingMessages = NO;
        onComplete(messages);
      });
    });
    
  }];
}

@end
