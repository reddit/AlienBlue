#import "ABCustomOutlineNavigationBar.h"
#import "JMOptimalToolbarCoordinator.h"

@class Post;
@interface BrowserNavigationBar : ABCustomOutlineNavigationBar

@property (copy) JMAction onCommentButtonTap;
@property (copy) void(^onOptimalSwitchChange)(BOOL didChangeToOptimal);

- (void)updateWithWithToolbarCoordinator:(JMOptimalToolbarCoordinator *)optimalToolbarCoordinator forPost:(Post *)post displaysOptimalByDefault:(BOOL)displaysOptimalByDefault hidesOptimalBar:(BOOL)hidesOptimalBar;

@end
