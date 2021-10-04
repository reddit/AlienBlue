#import "MessagesViewController.h"

@interface MessagesViewController (API)
@property (strong) AFHTTPRequestOperation *loadMessagesOperation;
- (void)fetchMessagesRemoveExisting:(BOOL)removeExisting onComplete:(void (^)(NSArray *messages))onComplete;
@end
