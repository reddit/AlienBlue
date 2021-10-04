#import "MessagesViewController+LinkHandling.h"
#import "NSString+ABLegacyLinkTypes.h"
#import "NavigationManager+Deprecated.h"
#import "Resources.h"
#import "BrowserViewController_iPhone.h"
#import "MarkupEngine.h"

@interface MessagesViewController (LinkHandling_)

@end

@implementation MessagesViewController (LinkHandling)

- (void)openLinkUrl:(NSString *)url;
{
  [[NavigationManager shared] dismissModalView];
  [[NavigationManager shared] handleTapOnUrl:url fromController:self];
}

- (void)coreTextURLPressed:(NSString *)url;
{
  [self openLinkUrl:url];
}

@end
