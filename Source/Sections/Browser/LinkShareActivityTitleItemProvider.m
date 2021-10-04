#import "LinkShareActivityTitleItemProvider.h"
#import "JMCoreMacros.h"

@interface LinkShareActivityTitleItemProvider()
@property (copy) NSString *title;
@end

@implementation LinkShareActivityTitleItemProvider

- (instancetype)initWithTitle:(NSString *)title;
{
  JM_SUPER_INIT(initWithPlaceholderItem:title);
  self.title = title;
  return self;
}

- (id)item;
{
  // Assuming users will want only a URL when copying to clipboard
  // and not a prepended title
  if (self.activityType == UIActivityTypeCopyToPasteboard)
    return nil;
  
  return self.title;
}

@end
