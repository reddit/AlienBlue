#import <UIKit/UIKit.h>
#import "ABTableCellDrawerView.h"

#define kABTableCellContentViewTag 23408

@interface ABTableCell : UITableViewCell

- (void)addDrawer:(ABTableCellDrawerView *)drawerView;
- (void)removeDrawer;

@end
