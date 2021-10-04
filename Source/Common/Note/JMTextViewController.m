#import "JMTextViewController.h"
#import "UIImage+Skin.h"
#import "UIColor+Hex.h"
#import <QuartzCore/QuartzCore.h>
#import "Resources.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "ABCustomOutlineNavigationBar.h"

@interface JMTextViewController()
@property (nonatomic,strong) JMTextView *textView;
@property (nonatomic,strong) UIImageView *textViewBackgroundImageView;
@property (nonatomic,strong) UILabel *placeholderLabel;
- (void)releaseViews;
- (void)autosave;
- (void)dismiss;
@end

@implementation JMTextViewController

@synthesize delegate = delegate_;
@synthesize propertyKey = propertyKey_;
@synthesize textView = textView_;
@synthesize placeholderText = placeholderText_;
@synthesize placeholderLabel = placeholderLabel_;
@synthesize defaultText = defaultText_;
@synthesize preserveDefaultText = preserveDefaultText_;

@synthesize autoCorrectionType = autoCorrectionType_;
@synthesize keyboardType = keyboardType_;
@synthesize singleLine = singleLine_;
@synthesize returnKeyType = returnKeyType_;

- (void)dealloc;
{
    [self releaseViews];
    
    self.delegate = nil;

}

- (void)releaseViews;
{
    self.textView = nil;
    self.placeholderLabel = nil;
}

- (id)initWithDelegate:(id<JMTextViewDelegate>) delegate propertyKey:(NSString *)propertyKey;
{
    self = [super init];
    if (self)
    {
        [self jm_usePreIOS7ScrollBehavior];
      
        self.delegate = delegate;
        self.propertyKey = propertyKey;

        self.preserveDefaultText = NO;

        self.singleLine = NO;
        self.autoCorrectionType = UITextAutocorrectionTypeDefault;
        self.keyboardType = UIKeyboardTypeDefault;
        self.returnKeyType = UIReturnKeyDefault;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    }
    return self;
}

+ (JMTextViewController *)controllerOnComplete:(JMTextViewCompleteAction)onComplete onDismiss:(ABAction)onDismiss;
{
    JMTextViewController *controller = [[JMTextViewController alloc] initWithDelegate:nil propertyKey:nil];
    controller.onComplete = onComplete;
    controller.onDismiss = onDismiss;
    return controller;
}

- (void)finishWithValue:(NSString *)value;
{
    if (value && [value length] > 0)
    {
        if (self.onComplete)
        {
            self.onComplete(value);
        }
        else if (self.delegate)
        {
            [self.delegate performSelector:@selector(textViewDidEnterValue:propertyKey:) withObject:value withObject:self.propertyKey];
        }
        [self dismiss];        
    }
}

- (void)dismiss;
{
    if (self.onDismiss)
    {
        self.onDismiss();
    }
    else
    {
      [self jm_dismiss];
    }
}

- (void)done;
{
    [self autosave];
    [self finishWithValue:self.textView.text];
}

- (void)cancel;
{
    if (self.textView.text && [self.textView.text length] > 5)
    {
        [self autosave];
    }
    [self dismiss];
}

- (CGFloat)heightForTextViewInOrientation:(UIInterfaceOrientation)orientation;
{
    if (self.singleLine)
    {
        return 58.;
    }
    
    if ([Resources isIPAD])
    {
        CGFloat height = (UIInterfaceOrientationIsPortrait(orientation)) ? 340. : 330.;
        if (JMIsIOS8())
        {
          height -= 30.;
        }
        return height;
    }
    else
    {
      return [self suggestTextEntryHeightForPhoneForOrientation:orientation];
//      CGFloat height = (UIInterfaceOrientationIsPortrait(orientation)) ? (JMIsIphone5() ? 264. : 180.) : 86.;
//      height -= 10.;
//      if (JMIsIOS8())
//      {
//        height -= 30.;
//      }
//      return height;
    }
}

- (CGFloat)suggestTextEntryHeightForPhoneForOrientation:(UIInterfaceOrientation)orientation;
{
  CGFloat height = 0.;
  BOOL isLandscape = JMLandscape();
  if (JMIsIphone5())
  {
    height += isLandscape ? 110. : 290.;
  }
  else if (JMIsIphone6())
  {
    height += isLandscape ? 160. : 390.;
  }
  else if (JMIsIphone6Plus())
  {
    height += isLandscape ? 185. : 445.;
  }
  else
  {
    // iphone 4
    height += isLandscape ? 110. : 210.;
  }
  
  if (JMIsIOS8())
  {
    height -= 40.;
  }
  return height;
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
//{
//    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
////    self.textView.height = [self heightForTextViewInOrientation:toInterfaceOrientation];
//    [self.textView resignFirstResponder];
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
//{
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    self.textView.height = [self heightForTextViewInOrientation:JMAppStatusBarOrientation];
//    [self.textView becomeFirstResponder];
//}

- (void)viewWillLayoutSubviews;
{
  [super viewWillLayoutSubviews];
  self.textView.height = [self heightForTextViewInOrientation:JMAppStatusBarOrientation];
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
}

- (void)loadView;
{
    [super loadView];

    BSELF(JMTextViewController);
    ABCustomOutlineNavigationBar *customNavigationBar = [ABCustomOutlineNavigationBar new];
    [self attachCustomNavigationBarView:customNavigationBar];
    [customNavigationBar setCustomLeftButtonWithIcon:[ABCustomOutlineNavigationBar cancelIcon] onTapAction:^{
      [blockSelf cancel];
    }];
    [customNavigationBar setCustomRightButtonWithTitle:@"Done" onTapAction:^{
      [blockSelf done];
    }];
    customNavigationBar.showsThinUnderlineViewInCompactMode = YES;
    [customNavigationBar setTitleLabelText:self.title];
  
    UIView *viewWrapper = [[UIView alloc] initWithFrame:self.view.bounds];
    viewWrapper.autoresizingMask = JMFlexibleSizeMask;

    self.textViewBackgroundImageView.hidden = YES;
    viewWrapper.backgroundColor = [UIColor colorForBackground];
  
    self.textView = [[JMTextView alloc] initWithFrame:CGRectInset(viewWrapper.bounds, 10., 10.)];
    self.textView.backgroundColor = [UIColor colorForBackgroundAlt];
    self.textView.textColor = [UIColor colorForText];
    self.textView.delegate = self;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    self.textView.height = [self heightForTextViewInOrientation:orientation];
    [self.textView becomeFirstResponder];
    [viewWrapper addSubview:self.textView];
    
    self.textView.keyboardAppearance = JMIsNight() ? UIKeyboardAppearanceDark : UIKeyboardAppearanceLight;
  
    if (self.defaultText && [self.defaultText length] > 0)
    {
        self.textView.text = self.defaultText;
    }
    else
    {
        self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(22., 12., 300., 30.)];
        self.placeholderLabel.text = self.placeholderText;
        self.placeholderLabel.font = self.textView.font;
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
        [viewWrapper addSubview:self.placeholderLabel];
    }

    if (self.singleLine)
    {
        self.textView.enablesReturnKeyAutomatically = YES;
    }
    
    self.textView.autocorrectionType = self.autoCorrectionType;
    self.textView.keyboardType = self.keyboardType;
    self.textView.returnKeyType = self.returnKeyType;
  
    [self.tableView addSubview:viewWrapper];
    self.prefersFixedCompactCustomNavigationBar = !self.singleLine;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);    
}

- (void)viewDidUnload;
{
    [super viewDidUnload];
    [self releaseViews];
}

#pragma mark - TextView Delegate

- (BOOL)textViewShouldReturn:(UITextView *)textView {
	[self.textView resignFirstResponder];
	return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.preserveDefaultText && ![textView.text hasPrefix:self.defaultText])
    {
        self.textView.text = self.defaultText;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.placeholderLabel.hidden = YES;
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"] && self.singleLine) {
        [self.textView resignFirstResponder];
		[self done];
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    else if ([text isEqualToString:@"\n"] && self.propertyKey)
    {
        [self autosave];
    }
    return TRUE;
}

- (void)autosave;
{
    if (self.propertyKey && [self.propertyKey length] > 0)
    {
        NSLog(@"autosaving with key : %@", self.propertyKey);
        [[NSUserDefaults standardUserDefaults] setValue:self.textView.text forKey:self.propertyKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
//
//- (void)textViewDidBeginEditing:(UITextView *)textView;
//- (void)textViewDidEndEditing:(UITextView *)textView;
//
//- (void)textViewDidChange:(UITextView *)textView;
//
//- (void)textViewDidChangeSelection:(UITextView *)textView;


@end
