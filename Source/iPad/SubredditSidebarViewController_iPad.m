#import "SubredditSidebarViewController_iPad.h"
#import "NavigationBar_iPad.h"
#import "Post.h"
#import "NavigationManager_iPad.h"
#import "BrowserViewController_iPad.h"

@implementation SubredditSidebarViewController_iPad

- (void)loadView;
{
  [super loadView];
  NavigationBar_iPad *headerView = [[NavigationBar_iPad alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 55.)];
  headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  headerView.title = [self.subredditName stringByAppendingString:@" Sidebar"];
  [self.view addSubview:headerView];
  
  self.contentView.top = headerView.height - 5.;
  self.contentView.height -= self.contentView.top;
  
  [headerView addSubview:self.loadingIndicator];
  self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  self.loadingIndicator.right = headerView.bounds.size.width - 20.;
  self.loadingIndicator.top = 14.;
}

- (CGFloat)pageWidth;
{
  return 430.;
}

@end
