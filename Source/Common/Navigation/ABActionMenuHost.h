#import "JMActionMenuView.h"

@class ABCustomOutlineNavigationBar;

@interface ABActionMenuHost : NSObject <JMActionMenuViewDelegate>
@property (strong, readonly) JMActionMenuView *actionMenuView;
@property (weak, readonly) UIViewController *parentController;
@property (readonly) NSString *friendlyName;
@property (readonly) ABCustomOutlineNavigationBar *customNavigationBar;
+ (ABActionMenuHost *)actionMenuHostForViewController:(UIViewController *)viewController;
- (void)updateCustomNavigationBar;
- (Class)classForCustomNavigationBar;
- (void)willAttachCustomNavigationBar:(ABCustomOutlineNavigationBar *)customNavigationBar;

- (void)updateActionMenuBadges;

@end
