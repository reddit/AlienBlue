#import "ABOutlineViewController.h"
#import "ItemSelectorViewController.h"
#import "JMTabView.h"
#import "JMTextViewController.h"
#import "PhotoUploadViewController.h"
#import "CaptchaEntryViewController.h"
#import "ABNavigationController.h"

@interface CreatePostViewController : ABOutlineViewController <JMTabViewDelegate,ItemSelectorDelegate,JMTextViewDelegate,PhotoUploadDelegate,CaptchaEntryDelegate, UIAlertViewDelegate>

+ (ABNavigationController *) viewControllerWithNavigation;

@end
