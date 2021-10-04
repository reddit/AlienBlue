#import "JMTextField.h"
#import "UIImage+Skin.h"
#import "UIColor+Hex.h"

#define kJMTextFieldInset CGSizeMake(10.,10.)

@implementation JMTextField

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont boldSystemFontOfSize:15.];
        self.textColor = [UIColor colorWithHex:0x4a4a4a];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
    UIImage *background = [[UIImage skinImageNamed:@"common/textfield/textfield-background.png"] stretchableImageWithLeftCapWidth:113. topCapHeight:18.];
    [background drawInRect:self.bounds blendMode:kCGBlendModeMultiply alpha:1.];
}

- (void)drawPlaceholderInRect:(CGRect)rect;
{
  [[[UIColor grayColor] colorWithAlphaComponent:0.5] set];
  [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
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
