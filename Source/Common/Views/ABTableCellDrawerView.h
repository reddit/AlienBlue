#import <UIKit/UIKit.h>
#import "ABButton.h"

#define kABTableCellDrawerHeight 67.

@interface ABTableCellDrawerView : UIControl

@property (nonatomic,ab_weak) NSObject *delegate;
@property (nonatomic,strong) NSObject *node;

- (id)initWithNode:(NSObject *)node;

- (UIButton *)createDrawerButtonWithIconName:(NSString *)iconName highlightColor:(UIColor *)highlightColor target:(id)target action:(SEL)action;
- (void)addButton:(UIButton *)button;

@end
