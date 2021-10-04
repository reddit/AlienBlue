#import "MoPubCompatibleOutlineView.h"
#import <mopub-ios-sdk/MoPub-Bridging-Header.h>

@interface MoPubCompatibleOutlineView()
@end

@implementation MoPubCompatibleOutlineView

- (void)jm_setDelegate:(id<UITableViewDelegate>)delegate;
{
  [self mp_setDelegate:delegate];
}

- (id<UITableViewDelegate>)jm_delegate;
{
  return [self mp_delegate];
}

- (void)jm_setDataSource:(id<UITableViewDataSource>)dataSource;
{
  [self mp_setDataSource:dataSource];
}

- (id<UITableViewDataSource>)jm_dataSource;
{
  return [self mp_dataSource];
}

- (void)jm_reloadData;
{
  [self mp_reloadData];
}

- (CGRect)jm_rectForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return [self mp_rectForRowAtIndexPath:indexPath];
}

- (NSIndexPath *)jm_indexPathForRowAtPoint:(CGPoint)point;
{
  return [self mp_indexPathForRowAtPoint:point];
}

- (NSIndexPath *)jm_indexPathForCell:(UITableViewCell *)cell;
{
  return [self mp_indexPathForCell:cell];
}

- (NSArray *)jm_indexPathsForRowsInRect:(CGRect)rect;
{
  return [self mp_indexPathsForRowsInRect:rect];
}

- (UITableViewCell *)jm_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return [self mp_cellForRowAtIndexPath:indexPath];
}

- (NSArray *)jm_visibleCells;
{
  return [self mp_visibleCells];
}

- (NSArray *)jm_indexPathsForVisibleRows;
{
  return [self mp_indexPathsForVisibleRows];
}

- (void)jm_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
{
  return [self mp_scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)jm_beginUpdates;
{
  [self mp_beginUpdates];
}

- (void)jm_endUpdates;
{
  [self mp_endUpdates];
}

- (void)jm_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self mp_insertSections:sections withRowAnimation:animation];
}

- (void)jm_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self mp_deleteSections:sections withRowAnimation:animation];
}

- (void)jm_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self mp_reloadSections:sections withRowAnimation:animation];
}

- (void)jm_moveSection:(NSInteger)section toSection:(NSInteger)newSection;
{
  [self mp_moveSection:section toSection:newSection];
}

- (void)jm_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self mp_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)jm_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self mp_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)jm_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
{
  [self mp_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)jm_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
{
  [self mp_moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (NSIndexPath *)jm_indexPathForSelectedRow;
{
  return [self mp_indexPathForSelectedRow];
}

- (NSArray *)jm_indexPathsForSelectedRows;
{
  return [self mp_indexPathsForSelectedRows];
}

- (void)jm_selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
{
  [self mp_selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)jm_deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
{
  [self mp_deselectRowAtIndexPath:indexPath animated:animated];
}

- (id)jm_dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
{
  return [self mp_dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

@end
