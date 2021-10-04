#import "ABTableView.h"
#import "UIView+Additions.h"
#import "Resources.h"

@implementation ABTableView

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }
    return self;
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
{
  if (!JMIsIOS7())
  {
    [super reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    return;
  }
  
  // patch for internal iOS 7 animation memory leak
  [UIView beginAnimations:nil context:nil];
  [super reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
  [UIView commitAnimations];
}

@end
