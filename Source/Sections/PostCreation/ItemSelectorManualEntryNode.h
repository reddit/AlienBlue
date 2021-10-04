#import "JMOutlineNode.h"

@interface ItemSelectorManualEntryNode : JMOutlineNode

@property (nonatomic,strong) NSString * placeholder;
@property (nonatomic,strong) NSString * enteredString;

+ (ItemSelectorManualEntryNode *)nodeWithPlaceholder:(NSString *)placeholder;

@end
