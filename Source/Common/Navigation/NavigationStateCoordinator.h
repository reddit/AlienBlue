@class NavigationManager;

@interface NavigationStateCoordinator : NSObject

- (id)initWithParentNavigationManager:(NavigationManager *)parentNavigationManager;
- (void)saveState;
- (void)restoreState;

@end
