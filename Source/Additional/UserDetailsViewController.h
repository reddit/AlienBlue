#import "ABOutlineViewController.h"

@interface UserDetailsViewController : ABOutlineViewController
@property (strong, readonly) NSString *username;
- (id)initWithUsername:(NSString *)username;
@end
