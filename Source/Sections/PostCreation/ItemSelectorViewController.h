#import "ABOutlineViewController.h"

@class ItemSelectorViewController;

@protocol ItemSelectorDelegate <NSObject>
- (void)itemSelectorDidSelectValue:(NSString *)value propertyKey:(NSString *)propertyKey;
@end

@interface ItemSelectorViewController : ABOutlineViewController

@property (nonatomic,ab_weak) id<ItemSelectorDelegate> delegate;
@property (nonatomic,strong) NSString *propertyKey;
- (id)initWithDelegate:(id<ItemSelectorDelegate>) delegate;
@end
