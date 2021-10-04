#import "JMTextFieldEntry.h"
#import "UIImage+Skin.h"
#import "UIColor+Hex.h"
#import "ABButton.h"
#import "Resources.h"

#define kJMFieldEntryFrame CGRectMake(0, 0, 320., 50.)
#define kJMFieldEntryAnimationName @"kJMFieldEntryAnimationName"
#define kJMFieldEntryAnimationDuration 0.4

@interface JMTextFieldEntry()
@property (nonatomic,strong) ABButton *cancelButton;
@property (nonatomic,strong) ABButton *doneButton;
@property (nonatomic,strong) NSString *placeholderText;
@property (nonatomic,strong) JMTextField *textField;
@property (assign) BOOL focussed;

- (void)unfocus;
- (void)focus;
@end

@implementation JMTextFieldEntry

@synthesize cancelButton = cancelButton_;
@synthesize doneButton = doneButton_;
@synthesize textField = textField_;
@synthesize focussed = focussed_;
@synthesize delegate = delegate_;
@synthesize placeholderText = placeholderText_;

- (void)dealloc;
{
    self.delegate = nil;
}

- (id)init;
{
    self = [super initWithFrame:kJMFieldEntryFrame];
    if (self)
    {
        self.cancelButton = [ABButton buttonWithImageName:@"common/textfield/textfield-cancel-normal.png" target:self action:@selector(cancel)];
        self.doneButton = [ABButton buttonWithImageName:@"common/textfield/button-done-square-normal" target:self action:@selector(done)];
        self.textField = [[JMTextField alloc] init];
        self.textField.delegate = self;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.enablesReturnKeyAutomatically = YES;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self addSubview:self.cancelButton];
        [self addSubview:self.doneButton];
        [self addSubview:self.textField];
    }
    return self;
}

- (void)setTextFieldPlaceholder:(NSString *)placeholder;
{
    self.placeholderText = placeholder;   
    self.textField.placeholder = placeholder; 
}

- (void)setDefaultText:(NSString *)defaultText;
{
    self.textField.text = defaultText;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)capitalizationType;
{
    self.textField.autocapitalizationType = capitalizationType;
}

- (void)positionSubviews;
{
    CGFloat width = self.bounds.size.width;
    if (!self.focussed)
    {
        self.cancelButton.frame = CGRectMake(-40., 8, 27., 37.);
        self.doneButton.frame = CGRectMake(width + 40., 2., 50., 45.);
        self.textField.frame = CGRectMake(6, 6, width - 12., 38.);
    }
    else
    {
        self.cancelButton.frame = CGRectMake(6, 8, 27., 37.);
        self.doneButton.frame = CGRectMake(width - 50., 2., 50., 45.);
        self.textField.frame = CGRectMake(38., 6, width - 92., 38.);
    }
}

- (void)layoutSubviews;
{
    [self positionSubviews];
}

- (void)cancel;
{
    self.textField.text = nil;
    [self unfocus];

    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldEntryDidCancel:)])
    {
        [self.delegate performSelector:@selector(textFieldEntryDidCancel:) withObject:self];
    }
}

- (void)done;
{
    [self.textField resignFirstResponder];

    if ([self.textField.text length] == 0)
        return;

    if (self.delegate)
    {
        [self.delegate performSelector:@selector(textFieldEntry:finishedWithString:) withObject:self withObject:self.textField.text];
    }
}

- (void)animateFocusChange;
{
    [UIView beginAnimations:kJMFieldEntryAnimationName context:(__bridge void *)(self)];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kJMFieldEntryAnimationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self positionSubviews];
    [UIView commitAnimations];
}

- (void)focus;
{
    self.focussed = YES;
    [self animateFocusChange];
}

- (void)unfocus;
{
    self.focussed = NO;
    [self.textField resignFirstResponder];
    [self animateFocusChange];
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    [self focus];
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldEntryDidBeginEditing:)])
    {
        [self.delegate performSelector:@selector(textFieldEntryDidBeginEditing:) withObject:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    [self unfocus];
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldEntryDidEndEditing:)])
    {
        [self.delegate performSelector:@selector(textFieldEntryDidEndEditing:) withObject:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [self done];
    return YES;
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
//- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder

// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
//- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
//
//- (BOOL)textFieldShouldClear:(UITextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)

@end
