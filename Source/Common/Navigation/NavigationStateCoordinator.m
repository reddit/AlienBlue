#import "NavigationStateCoordinator.h"
#import "RedditAPI+HideQueue.h"
#import "NavigationManager+Deprecated.h"

#import "Resources.h"
#import "BrowserViewController.h"
#import "SettingsViewController.h"
#import "RedditsViewController.h"
#import "CommentsViewController+PopoverOptions.h"
#import "PostsViewController+PopoverOptions.h"
#import "UserDetailsViewController.h"
#import "MessagesViewController.h"

@interface NavigationManager()
@property (strong) Post *lastVisitedPost;
@end

@interface NavigationStateCoordinator()
@property (weak) NavigationManager *parentNavigationManager;
@end

@implementation NavigationStateCoordinator

- (id)initWithParentNavigationManager:(NavigationManager *)parentNavigationManager;
{
  JM_SUPER_INIT(init);
  self.parentNavigationManager = parentNavigationManager;
  return self;
}

- (void)restoreState;
{
  // check the hide queue state from when the user exited the app.
  NSMutableArray * savedHideQueueList = (NSMutableArray *) [UDefaults objectForKey:kABSettingKeyHideQueue];
  if (savedHideQueueList && [savedHideQueueList count] > 0)
  {
    for (NSString *postIdent in savedHideQueueList)
    {
      [[RedditAPI shared] addPostToHideQueue:postIdent];
    }
  }
  
  Class redditsClass = [Resources isIPAD] ? NSClassFromString(@"RedditsViewController_iPad") : NSClassFromString(@"RedditsViewController_iPhone");
  RedditsViewController * redditsViewController = [[redditsClass alloc] init];
  [self.parentNavigationManager.postsNavigation setViewControllers:[NSArray arrayWithObject:redditsViewController] animated:NO];
  NavigationManager<UINavigationControllerDelegate> *parentManagerAndNavigationDelegate = (NavigationManager<UINavigationControllerDelegate> *) self.parentNavigationManager;
  [parentManagerAndNavigationDelegate navigationController:self.parentNavigationManager.postsNavigation willShowViewController:redditsViewController animated:NO];
  [parentManagerAndNavigationDelegate navigationController:self.parentNavigationManager.postsNavigation didShowViewController:redditsViewController animated:NO];

  
  NSData *savedStateArchive = [UDefaults objectForKey:@"savedStateArchive"];
  if (!savedStateArchive)
  {
    Class postsClass = [Resources isIPAD] ? NSClassFromString(@"PostsViewController_iPad") : NSClassFromString(@"PostsViewController");
    PostsViewController *postsController = [[postsClass alloc] initWithSubreddit:@"" title:@"Front Page"];
    [self.parentNavigationManager.postsNavigation pushViewController:postsController animated:NO];
    if (![Resources useActionMenu])
    {
      [self.parentNavigationManager interactionIconsNeedUpdate];
    }
    return;
  }
  
  // we need to reset this to protect from a launch-crash loop if we screw something up
  [UDefaults removeObjectForKey:@"savedStateArchive"];
  [UDefaults synchronize];
  
  NSDictionary *savedState = [NSKeyedUnarchiver unarchiveObjectWithData:savedStateArchive];
  
  NSDictionary *legacyPostDictionary = [savedState objectForKey:@"post"];
  if (legacyPostDictionary)
  {
    self.parentNavigationManager.deprecated_legacyPostDictionary = [NSMutableDictionary dictionaryWithDictionary:legacyPostDictionary];
    self.parentNavigationManager.lastVisitedPost = [Post postFromDictionary:self.parentNavigationManager.deprecated_legacyPostDictionary];
  }
  
  [self.parentNavigationManager.postsNavigation popToRootViewControllerAnimated:NO];
  NSArray *controllerStack = [savedState objectForKey:@"controllerStack"];
  [controllerStack each:^(NSDictionary *controllerState) {
    Class controllerClass = NSClassFromString([controllerState objectForKey:@"name"]);
    UIViewController *controller = [[controllerClass alloc] initWithState:[controllerState objectForKey:@"state"]];
    if (controller)
    {
      [self.parentNavigationManager.postsNavigation pushViewController:controller animated:NO];
    }
  }];
  
  [self.parentNavigationManager interactionIconsNeedUpdate];
}

- (void)saveState;
{
  [UDefaults setObject:[RedditAPI shared].hideQueue forKey:kABSettingKeyHideQueue];
  
  NSMutableDictionary *savedState = [NSMutableDictionary dictionary];
  
  if (self.parentNavigationManager.lastVisitedPost)
  {
    [savedState setObject:self.parentNavigationManager.lastVisitedPost.legacyDictionary forKey:@"post"];
  }
  
  __block NSMutableArray * controllerStack = [NSMutableArray array];
  NSArray *statefulControllers = [self.parentNavigationManager.postsNavigation.viewControllers filter:^BOOL(id item) {
    return ![item conformsToProtocol:@protocol(StatefulControllerProtocol)];
  }];
  
  [statefulControllers each:^(id<StatefulControllerProtocol> controller) {
    NSString *controllerName = NSStringFromClass([controller class]);
    NSMutableDictionary *controllerState = [NSMutableDictionary dictionary];
    [controllerState setObject:controllerName forKey:@"name"];
    [controllerState setObject:[controller state] forKey:@"state"];
    [controllerStack addObject:controllerState];
  }];

  // Here we take the very last controller that the user was viewing, and make that the 3rd viewstack.
  // Rather than storing the state of an entire navigation hierarchy, we'll store only
  // the last 3. This would also protect from cases where the user could crash from
  // pushing too many controllers on older devices unnecessarily.
  if ([controllerStack count] > 3)
  {
    [controllerStack replaceObjectAtIndex:2 withObject:[controllerStack objectAtIndex:3]];
    [controllerStack removeObjectsInRange:NSMakeRange(3, [controllerStack count] - 3)];
  }
  
  [savedState setObject:controllerStack forKey:@"controllerStack"];
  
  NSData *savedStateArchive = [NSKeyedArchiver archivedDataWithRootObject:savedState];
  [UDefaults setObject:savedStateArchive forKey:@"savedStateArchive"];
  [UDefaults synchronize];
}

@end
