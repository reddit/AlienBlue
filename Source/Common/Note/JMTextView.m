#import "JMTextView.h"
#import "UIImage+Skin.h"
#import "UIColor+Hex.h"

#define kJMTextFieldInset CGSizeMake(12.,12.)

@implementation JMTextView

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont boldSystemFontOfSize:15.];
        self.textColor = [UIColor colorWithHex:0x4a4a4a];
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
    UIImage *background = [[UIImage skinImageNamed:@"common/textfield/textfield-background.png"] stretchableImageWithLeftCapWidth:113. topCapHeight:18.];
    [background drawInRect:self.bounds blendMode:kCGBlendModeMultiply alpha:1.];
}

- (CGRect)textRectForBounds:(CGRect)bounds;
{
    return CGRectInset(bounds, kJMTextFieldInset.width, kJMTextFieldInset.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds;
{
    return CGRectInset(bounds, kJMTextFieldInset.width, kJMTextFieldInset.height);
}

@end