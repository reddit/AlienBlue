#import <UIKit/UIKit.h>
#import "ABOutlineViewController.h"

@class CaptchaEntryViewController;

@protocol CaptchaEntryDelegate <NSObject>
- (void)didEnterCaptcha:(NSString *)captchaEntered forCaptchaId:(NSString *)captchaId;
@end

@interface CaptchaEntryViewController : ABOutlineViewController <UITextFieldDelegate>
@property (nonatomic,ab_weak) id<CaptchaEntryDelegate> delegate;
@property (nonatomic,strong) NSString *propertyKey;
- (id)initWithDelegate:(id<CaptchaEntryDelegate>)delegate propertyKey:(NSString *)propertyKey;
@end
