#import "RedditAddController_iPad.h"
#import "NavigationManager_iPad.h"

@interface RedditAddController_iPad ()

@end

@implementation RedditAddController_iPad

- (void)dismiss;
{
  [[NavigationManager shared] dismissPopoverIfNecessary];
}

  
@end
