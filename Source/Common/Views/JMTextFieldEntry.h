#import <UIKit/UIKit.h>
#import "JMTextField.h"

@class JMTextFieldEntry;

@protocol JMTextFieldEntryDelegate <NSObject>
- (void)textFieldEntry:(JMTextFieldEntry *)textFieldEntry finishedWithString:(NSString *)string;

@optional
- (void)textFieldEntryDidBeginEditing:(JMTextFieldEntry *)textFieldEntry;
- (void)textFieldEntryDidCancel:(JMTextFieldEntry *)textFieldEntry;
- (void)textFieldEntryDidEndEditing:(JMTextFieldEntry *)textFieldEntry;
@end

@interface JMTextFieldEntry : UIView <UITextFieldDelegate>
@property (jmfn_weak) id<JMTextFieldEntryDelegate>delegate;
@property (readonly,nonatomic,strong) JMTextField *textField;

- (void)setTextFieldPlaceholder:(NSString *)placeholder;
- (void)setDefaultText:(NSString *)defaultText;
- (void)setAutocapitalizationType:(UITextAutocapitalizationType)capitalizationType;

- (void)cancel;
@end
