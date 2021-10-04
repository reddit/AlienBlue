#import "RedditAPI.h"

@interface RedditAPI (Moderation)

- (void)modApproveItemWithName:(NSString *)name;
- (void)modRemoveItemWithName:(NSString *)name;
- (void)modMarkAsSpamItemWithName:(NSString *)name;
- (void)modDistinguishItemWithName:(NSString *)name distinguish:(BOOL)distinguish;

@end
