#import "TransparentCellContentView.h"

@implementation TransparentCellContentView

@synthesize showNoise = showNoise_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
}


@end
