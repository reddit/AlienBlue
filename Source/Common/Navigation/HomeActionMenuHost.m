#import "HomeActionMenuHost.h"
#import "RedditsViewController.h"
#import "HomeNavigationBar.h"

@interface HomeActionMenuHost()
@property (readonly) RedditsViewController *redditsViewController;
@end

@implementation HomeActionMenuHost

- (Class)classForCustomNavigationBar;
{
  return [HomeNavigationBar class];
}

- (NSString *)friendlyName;
{
  return @"reddit";
}

- (RedditsViewController *)redditsViewController;
{
  return (RedditsViewController *)self.parentController;
}

- (NSArray *)generateScreenSpecificActionMenuNodes;
{
  return [NSArray new];
}

- (void)willAttachCustomNavigationBar:(ABCustomOutlineNavigationBar *)customNavigationBar;
{
  [super willAttachCustomNavigationBar:customNavigationBar];
}

@end
