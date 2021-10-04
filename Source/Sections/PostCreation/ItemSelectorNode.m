#import "ItemSelectorNode.h"

@implementation ItemSelectorNode

@synthesize title = title_;
@synthesize uniqueId = uniqueId_;
@synthesize thumbUrl = thumbUrl_;
@synthesize icon = icon_;
@synthesize placeholderIcon = placeholderIcon_;


+ (Class)cellClass;
{
    return NSClassFromString(@"ItemSelectorCell");
}

//+ (SEL)selectedAction;
//{
//    return @selector(selectorCellSelected:);
//}

@end
