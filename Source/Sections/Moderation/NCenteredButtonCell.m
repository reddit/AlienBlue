#import "NCenteredButtonCell.h"

@interface CenteredButtonNode()
@property (strong) NSString *title;
@property (strong) UIColor *buttonColor;
@end

@implementation CenteredButtonNode

- (id)initWithTitle:(NSString *)title buttonColor:(UIColor *)buttonColor;
{
  self = [super init];
  if (self)
  {
    self.title = title;
    self.buttonColor = buttonColor;
  }
  return self;
}

+ (Class)cellClass;
{
  return UNIVERSAL(NCenteredButtonCell);
}

@end

@implementation NCenteredButtonCell

@end
