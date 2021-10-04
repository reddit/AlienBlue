#import "Resources.h"
#import "MessageBoxSelectionBackgroundLayer.h"

@implementation MessageBoxSelectionBackgroundLayer

- (id)init;
{
  self = [super init];
  if (self)
  {
    CALayer *bgLayer = [CALayer new];
    bgLayer.frame = CGRectMake(0, 0, 1024, [Resources isIPAD] ? 60. : 48.);
    bgLayer.contents = (id)[[self class] imageForBarBackground].CGImage;
    [self insertSublayer:bgLayer atIndex:0];
  }
  return self;
}

+ (UIImage *)imageForBarBackground;
{
  UIImage *bgImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    UIColor *bgColor = [UIColor colorForBackground];
    [bgColor set];
    [[UIBezierPath bezierPathWithRect:bounds] fill];
  } opaque:YES withSize:CGSizeMake(31., 31.) cacheKey:[NSString stringWithFormat:@"posts_order_toolbar_background-%d", [Resources isNight]]];
  return [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15., 15., 15., 15.)];
}

@end
