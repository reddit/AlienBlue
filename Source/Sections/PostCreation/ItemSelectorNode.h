#import "JMOutlineNode.h"

@interface ItemSelectorNode : JMOutlineNode

@property (nonatomic,strong) NSString *uniqueId;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *thumbUrl;
@property (nonatomic,strong) UIImage *placeholderIcon;
@property (nonatomic,strong) UIImage *icon;

@end
