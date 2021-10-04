#import <UIKit/UIKit.h>
#import "JMTextView.h"
#import "ABOutlineViewController.h"

typedef void(^JMTextViewCompleteAction)(NSString *text);

@protocol JMTextViewDelegate <NSObject>
- (void)textViewDidEnterValue:(NSString *)value propertyKey:(NSString *)propertyKey;
@end

@interface JMTextViewController : ABOutlineViewController <UITextViewDelegate>
@property (readonly,nonatomic, strong) JMTextView *textView;
@property (readonly, nonatomic,strong) UIImageView *textViewBackgroundImageView;
@property (nonatomic,jmfn_weak) id<JMTextViewDelegate> delegate;
@property (nonatomic,strong) NSString *propertyKey;
@property (nonatomic,strong) NSString *placeholderText;
@property (nonatomic,strong) NSString *defaultText;
@property (nonatomic) BOOL preserveDefaultText;
- (id)initWithDelegate:(id<JMTextViewDelegate>) delegate propertyKey:(NSString *)propertyKey;

// configuring keyboard
@property (assign) UITextAutocorrectionType autoCorrectionType;
@property (assign) UIKeyboardType keyboardType;
@property (assign) UIReturnKeyType returnKeyType;
@property (assign) BOOL singleLine;

@property (copy) JMTextViewCompleteAction onComplete;
@property (copy) ABAction onDismiss;

+ (JMTextViewController *)controllerOnComplete:(JMTextViewCompleteAction)onComplete onDismiss:(ABAction)onDismiss;

- (CGFloat)heightForTextViewInOrientation:(UIInterfaceOrientation)orientation;

@end
