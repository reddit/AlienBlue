#import "ItemSelectorManualEntryNode.h"

@implementation ItemSelectorManualEntryNode

@synthesize placeholder = placeholder_;
@synthesize enteredString = enteredString_;


+ (Class)cellClass;
{
    return NSClassFromString(@"ItemSelectorManualEntryCell");
}

//+ (SEL)selectedAction;
//{
//    return @selector(selectorManualEntryCellSelected:);
//}

+ (ItemSelectorManualEntryNode *)nodeWithPlaceholder:(NSString *)placeholder;
{
    ItemSelectorManualEntryNode *node = [[ItemSelectorManualEntryNode alloc] init];
    node.placeholder = placeholder;
    return node;
}

@end
