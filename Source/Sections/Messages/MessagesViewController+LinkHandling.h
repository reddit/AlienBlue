#import "MessagesViewController.h"

@interface MessagesViewController (LinkHandling)
- (void)openLinkUrl:(NSString *)url;
- (void)coreTextURLPressed:(NSString *)url;
@end
