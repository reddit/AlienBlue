#import "ABHoverVolumeControlView.h"

@interface ABHoverVolumeControlView()
@property (strong) UIImageView *volumeTouchIndicatorView;
@end

@implementation ABHoverVolumeControlView

- (instancetype)initWithFrame:(CGRect)frame;
{
  JM_SUPER_INIT(initWithFrame:frame);
  self.backgroundColor = [UIColor purpleColor];
  return self;
}

@end
