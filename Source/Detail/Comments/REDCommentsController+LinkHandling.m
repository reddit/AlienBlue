//  REDCommentsController+LinkHandling.m
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController+LinkHandling.h"

#import "Common/Additions/NSString+ABLegacyLinkTypes.h"
#import "Common/Navigation/NavigationManager.h"
#import "Common/Navigation/NavigationManager+Deprecated.h"
#import "Helpers/MarkupEngine.h"
#import "Helpers/Resources.h"
#import "iPhone/BrowserViewController_iPhone.h"
#import "Sections/Browser/BrowserViewController.h"
#import "Sections/Posts/Post.h"

@implementation REDCommentsController (LinkHandling)

- (void)openLinkUrl:(NSString *)url;
{ [[NavigationManager shared] handleTapOnUrl:url fromController:self.detailViewController]; }

- (void)coreTextURLPressed:(NSString *)url;
{ [self openLinkUrl:url]; }

@end
