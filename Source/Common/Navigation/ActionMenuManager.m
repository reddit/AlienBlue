#import "ActionMenuManager.h"
#import "JMActionMenuView.h"
#import "ABActionMenuHost.h"

#import "ABCustomOutlineNavigationBar.h"
#import "JMOutlineViewController+CustomNavigationBar.h"

#import "NavigationManager.h"

@interface ActionMenuManager()
@property (strong) ABActionMenuHost *currentMenuHost;
@end

@implementation ActionMenuManager

- (id)init;
{
  JM_SUPER_INIT(init);
  return self;
}

- (void)updateForPostsNavigationController:(PostsNavigation *)postsNavigationController;
{
  JMOutlineViewController *controller = JMCastOrNil(postsNavigationController.topViewController, JMOutlineViewController);
  if (!controller)
    return;
  
  if (self.currentMenuHost.parentController == postsNavigationController.topViewController)
  {
    [self.currentMenuHost updateActionMenuBadges];
    [self.currentMenuHost updateCustomNavigationBar];
    return;
  }
  
  postsNavigationController.toolbarHidden = YES;
  postsNavigationController.navigationBarHidden = YES;
  
  self.currentMenuHost = [ABActionMenuHost actionMenuHostForViewController:controller];
  [self.currentMenuHost updateCustomNavigationBar];
}

- (void)postsNavigationController:(PostsNavigation *)postsNavigationController willShowViewController:(UIViewController *)viewController;
{
}

- (void)postsNavigationController:(PostsNavigation *)postsNavigation didShowViewController:(UIViewController *)viewController;
{
}

@end
