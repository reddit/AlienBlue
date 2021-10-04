#import "ABTableCell.h"
#import "ABTableCellView.h"

@interface ABTableCell()
@end

@implementation ABTableCell


- (void)addDrawer:(ABTableCellDrawerView *)drawerView;
{
    ABTableCellView *contentView = (ABTableCellView *)[self viewWithTag:kABTableCellContentViewTag];
    [contentView addDrawerView:drawerView];
}

- (void)removeDrawer;
{
    ABTableCellView *contentView = (ABTableCellView *)[self viewWithTag:kABTableCellContentViewTag];
    [contentView removeDrawerView];
}

@end
