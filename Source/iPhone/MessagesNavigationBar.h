#import "ABCustomOutlineNavigationBar.h"

@interface MessagesNavigationBar : ABCustomOutlineNavigationBar

@property (copy) JMAction onMarkAsReadTap;
- (void)attachBoxTabView:(UIView *)boxTabView;

@end
