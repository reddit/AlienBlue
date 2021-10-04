#import <UIKit/UIKit.h>
#import "BrowserViewController_iPhone.h"

@interface SubredditSidebarViewController : BrowserViewController_iPhone

@property (copy, readonly) NSString *subredditName;

-(id)initWithSubredditNamed:(NSString *)subredditName;
- (void)apiSubredditsResponse:(id)sender;
+ (UINavigationController *) viewControllerWithNavigatonForSubredditName:(NSString *)subredditName;

@end
