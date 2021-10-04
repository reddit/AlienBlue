#import "ABTableCellDrawerView.h"

@interface ModerationSupportedTableDrawerView : ABTableCellDrawerView
- (UIButton *)generateModButton;
- (BOOL)shouldShowModToolsByDefault;
- (void)enterModModeAnimated:(BOOL)animated;
@end
