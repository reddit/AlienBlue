#import "UITableViewCell+Transparency.h"

@implementation UITableViewCell (Transparency)

- (void)makeTransparent;
{
    self.opaque = NO;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
}

@end
