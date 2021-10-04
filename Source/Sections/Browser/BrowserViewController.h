#import <UIKit/UIKit.h>
#import "NavigationManager.h"
#import "MBProgressHUD.h"
#import "Post.h"
#import "JMOptimalBrowserController.h"
#import "SlidingDragReleaseProtocol.h"

@interface BrowserViewController : JMOptimalBrowserController <SlidingDragReleaseProtocol>

@property (readonly) NSString *currentURL;
@property (strong, readonly) Post *post;

@property (readonly) BOOL shouldHideVoteIcons;

- (id)initWithPost:(Post *)post;
- (id)initWithUrl:(NSString *)url;

- (void)popupExtraOptionsActionSheet:(id)sender;
- (void)updateWithStaticHTML:(NSString *)html;

@end
