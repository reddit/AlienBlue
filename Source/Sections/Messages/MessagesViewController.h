#import "ABOutlineViewController.h"

@interface MessagesViewController : ABOutlineViewController

@property (readonly) BOOL shouldDecorateAsUserComments;
@property BOOL shouldDismissModalAfterReplying;
@property (copy, readonly) NSString *boxUrl;

- (id)initWithBoxUrl:(NSString *)boxUrl;

@end
