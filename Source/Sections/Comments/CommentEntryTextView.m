#import "CommentEntryTextView.h"

@interface CommentEntryTextView()
@end

@implementation CommentEntryTextView

-(id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        [self setFont:[UIFont fontWithName:@"AmericanTypewriter" size:18.]];
        [self setFont:[UIFont systemFontOfSize:19.]];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setKeyboardType:UIKeyboardTypeDefault];
        [self setKeyboardAppearance:UIKeyboardAppearanceAlert];
        self.textColor = JMIsNight() ? [UIColor lightGrayColor] : [UIColor darkTextColor];
    }
    return self;
}


-(void)appendText:(NSString *)textToAppend;
{
    NSString * text = [[self text] stringByAppendingString:textToAppend];
    [self setText:text];    
}

-(void)insertTag:(NSString *)tag;
{
    NSString * tagStr = [NSString stringWithFormat:@"[](/%@)", tag];
    [self appendText:tagStr];
}

-(void)insertLOD;
{
    [self appendText:@"ಠ_ಠ"];
}


@end
