#import "PostDetailNode.h"

@implementation PostDetailNode

@synthesize key = key_;
@synthesize title = title_;
@synthesize value = value_;
@synthesize placeholder = placeholder_;
@synthesize icon = icon_;
@synthesize disclosureIcon = disclosureIcon_;

+ (Class)cellClass;
{
    return NSClassFromString(@"CreatePostDetailCell");
}

//+ (SEL)selectedAction;
//{
//   return @selector(postNodeSelected:);
//}

@end
