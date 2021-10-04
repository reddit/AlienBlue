#import "PostsNavigation.h"

@interface ActionMenuManager : NSObject

@property (strong, readonly) ABActionMenuHost *currentMenuHost;

- (void)updateForPostsNavigationController:(PostsNavigation *)postsNavigationController;
- (void)postsNavigationController:(PostsNavigation *)postsNavigation willShowViewController:(UIViewController *)viewController;
- (void)postsNavigationController:(PostsNavigation *)postsNavigation didShowViewController:(UIViewController *)viewController;

@end
