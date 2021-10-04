#import "CaptchaEntryViewController.h"
#import "UIImage+Skin.h"
#import "UIColor+Hex.h"
#import "JMTextField.h"
#import "RedditAPI+Captcha.h"
#import "ABButton.h"
#import "Resources.h"
#import "JMOutlineViewController+CustomNavigationBar.h"

@interface CaptchaEntryViewController()
@property (nonatomic,strong) NSString *captchaId;
@property (nonatomic,strong) UIImageView *captchaImageView;
@property (nonatomic,strong) JMTextField *textField;
@property (nonatomic,strong) UILabel *titleView;
- (void)releaseViews;
- (void)fetchCaptcha;
@end

@implementation CaptchaEntryViewController

@synthesize delegate = delegate_;
@synthesize propertyKey = propertyKey_;
@synthesize captchaId = captchaId_;
@synthesize captchaImageView = captchaImageView_;
@synthesize textField = textField_;

- (void)dealloc;
{
    [self releaseViews];
    self.delegate = nil;
}

- (id)initWithDelegate:(id<CaptchaEntryDelegate>)delegate propertyKey:(NSString *)propertyKey;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        [self setNavbarTitle:@"Captcha"];
        [self jm_usePreIOS7ScrollBehavior];
        self.delegate = delegate;
        self.propertyKey = propertyKey;
//        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStyleBordered target:self action:@selector(fetchCaptcha)] autorelease];
        
        UIBarButtonItem * sendItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(confirm)];
        if ([sendItem respondsToSelector:@selector(setTintColor:)])
        {
            [sendItem performSelector:@selector(setTintColor:) withObject:[UIColor colorWithHex:0x5085d8]];
        }
        self.navigationItem.rightBarButtonItem = sendItem;

    }
    return self;
}

- (void)updateCaptchaImageView;
{
    if (self.captchaId)
    {
        BSELF(CaptchaEntryViewController);
        NSString * captchaURL = [NSString stringWithFormat:@"https://www.reddit.com/captcha/%@.png", self.captchaId];
        UIImage *cachedCaptchaImage = [UIImage jm_remoteImageWithURL:[captchaURL URL] onRetrieveComplete:^(UIImage *image) {
          blockSelf.captchaImageView.image = image;
        }];
        self.captchaImageView.image = cachedCaptchaImage;
    }
}

- (void)fetchCaptcha;
{
    self.textField.text = nil;
	[[RedditAPI shared] requestCaptchaWithCallBackTarget:self];
}

- (void)captchaResponse:(id)sender
{
	self.captchaId = (NSString *) sender;
    [self updateCaptchaImageView];
}

#pragma Mark -
#pragma Mark - View Lifecycle

- (void)releaseViews;
{
    self.captchaImageView = nil;
    self.textField = nil;
}

- (void)viewDidUnload;
{
    [super viewDidUnload];
    [self releaseViews];
}

- (UIView *)createWrapperView;
{
  UIView *wrapperView = [[UIView alloc] initWithFrame:self.view.bounds];
  wrapperView.autoresizingMask = JMFlexibleSizeMask;
  
  UILabel *titleView = [[UILabel alloc] initWithSize:CGSizeMake(300., 100.)];
  titleView.text = @"reddit would like you to enter a captcha";
  titleView.autoresizingMask = JMFlexibleHorizontalMarginMask;
  titleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25.];
  titleView.textAlignment = NSTextAlignmentCenter;
  titleView.numberOfLines = 3;
  titleView.textColor = [UIColor colorForText];
  titleView.shadowColor = [UIColor colorForInsetDropShadow];
  titleView.shadowOffset = CGSizeMake(0., 1.);
  
  [wrapperView addSubview:titleView];
  [titleView centerHorizontallyInSuperView];
  self.titleView = titleView;
  
  CGRect captchaFrame = CGRectCenterWithSize(self.view.bounds, CGSizeMake(154., 65.));
  self.captchaImageView = [[UIImageView alloc] initWithFrame:captchaFrame];
  self.captchaImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  self.captchaImageView.backgroundColor = [UIColor clearColor];
  [wrapperView addSubview:self.captchaImageView];
  [self updateCaptchaImageView];
  
  self.textField = [[JMTextField alloc] initWithFrame:CGRectMake(0, captchaFrame.origin.y + 86., 154, 42.)];
  self.textField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  [wrapperView addSubview:self.textField];
  [self.textField centerHorizontallyInSuperView];
  self.textField.delegate = self;
  self.textField.enablesReturnKeyAutomatically = YES;
  self.textField.keyboardAppearance = UIKeyboardAppearanceAlert;
  self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.textField.font = [UIFont boldSystemFontOfSize:18.];
  self.textField.textAlignment = UITextAlignmentCenter;
  self.textField.returnKeyType = UIReturnKeySend;
  [self.textField becomeFirstResponder];
  return wrapperView;
}

- (void)loadView;
{
    [super loadView];
    [self.tableView addSubview:[self createWrapperView]];
    self.prefersFixedCompactCustomNavigationBar = YES;
}

- (void)viewWillLayoutSubviews;
{
  [super viewWillLayoutSubviews];
  BOOL shouldHideTitle = JMIsIphone() && JMLandscape();
  if (shouldHideTitle)
  {
    self.captchaImageView.top = 1.;
    self.textField.top = 76.;
    self.titleView.hidden = YES;
  }
  else
  {
    self.titleView.hidden = NO;
    self.captchaImageView.top = 93;
    self.textField.top = 174;
  }
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [self.textField becomeFirstResponder];
    [self fetchCaptcha];
}

- (void)confirm;
{
    [self.delegate performSelector:@selector(didEnterCaptcha:forCaptchaId:) withObject:self.textField.text withObject:self.captchaId];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [self confirm];
    return YES;
}

#pragma Mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return [Resources isIPAD];
}


@end
