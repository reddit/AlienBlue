#import "TemplateDetailViewController.h"
#import "TemplateToken.h"
#import "TemplateEditToolsView.h"
#import "Resources.h"
#import "BlocksKit.h"
#import "NavigationManager.h"
#import "NavigationManager+Deprecated.h"
#import <QuartzCore/QuartzCore.h>

@interface TemplateDetailViewController() <JMTextViewDelegate>
@property (strong) Template *tPlate;
@property TemplateDetailMode mode;
@property (strong) NSArray *tokens;
@property TemplateEditToolsView *toolsView;
@property TemplateSendPreference sendPreference;
@property UITextField *templateTitleTextField;
@property (readonly) NSString *standardGreeting;
@property (readonly) NSString *standardSignoff;
@end

@implementation TemplateDetailViewController

- (id)initWithTemplate:(Template *)tPlate mode:(TemplateDetailMode)mode tokens:(NSArray *)tokens;
{
  self = [super initWithDelegate:self propertyKey:nil];
  if (self)
  {
    self.tPlate = tPlate;
    self.mode = mode;
    self.defaultText = tPlate.body;
    self.tokens = tokens;
    self.sendPreference = tPlate.sendPreference;
    self.onDismiss = ^{};
    if (self.mode == TemplateDetailModeExpanded && self.tPlate)
    {
      self.defaultText = [self applyTokensToString:self.tPlate.body];
    }
    
  }
  return self;
}

- (NSString *)applyTokensToString:(NSString *)str;
{
  NSMutableString *mStr = [NSMutableString stringWithString:str];
  [self.tokens each:^(TemplateToken *token) {
    [token applyTokenToMutableString:mStr];
  }];
  return mStr;
}

- (void)loadView;
{
  [super loadView];
  self.textView.backgroundColor = [UIColor colorForBackgroundAlt];
  self.textView.textColor = [UIColor colorForText];
  self.view.backgroundColor = [UIColor colorForBackground];
  
  if ([Resources isNight])
  {
    self.textViewBackgroundImageView.hidden = YES;
    self.textView.layer.cornerRadius = 5.;
  }
  
  self.textView.keyboardAppearance = [Resources isNight] ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDefault;
  self.toolsView = [[TemplateEditToolsView alloc] initWithFrame:CGRectMake(0., 0., 220., 30.)];
  self.toolsView.backgroundColor = [UIColor clearColor];
  [self.tableView addSubview:self.toolsView];
  
  BSELF(TemplateDetailViewController);
  self.toolsView.switchView.onSendSwitchChange = ^(TemplateSendPreference sendPref)
  {
    [blockSelf didToggleCommentSwitchToPreference:sendPref];
  };
  
  [self.toolsView.tokenButton addTarget:self action:@selector(didTapInsert) forControlEvents:UIControlEventTouchUpInside];
  
  [self.toolsView.switchView setDefaultSendSwitchPreference:self.tPlate.sendPreference];

  self.templateTitleTextField = [[UITextField alloc] initWithFrame:CGRectInset(self.navigationBar.bounds, 60., 0.)];
  self.templateTitleTextField.font = [UIFont skinFontWithName:kBundleFontNavigationButtonTitle];
  self.templateTitleTextField.backgroundColor = [UIColor clearColor];
  self.templateTitleTextField.adjustsFontSizeToFitWidth = YES;
  self.templateTitleTextField.minimumFontSize = 7.;
  self.templateTitleTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.templateTitleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  self.templateTitleTextField.textAlignment = NSTextAlignmentCenter;
  self.templateTitleTextField.keyboardAppearance = [Resources isNight] ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDefault;
  self.templateTitleTextField.textColor = (self.sendPreference == TemplateSendPreferenceComment) ? [UIColor colorWithHex:0xad49e1] : [UIColor colorWithHex:0x009cff];
  
  [self.navigationBar addSubview:self.templateTitleTextField];
//  UIView *navTitleWrapper = [[UIView alloc] initWithFrame:self.templateTitleTextField.frame];
//  navTitleWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//  [navTitleWrapper addSubview:self.templateTitleTextField];
//  [self.templateTitleTextField centerInSuperView];
//  self.navigationItem.titleView = navTitleWrapper;
  self.templateTitleTextField.text = (self.tPlate) ? self.tPlate.title : self.defaultTemplateTitle;
  
  if (!self.tPlate && self.sendPreference == TemplateSendPreferencePersonalMessage)
  {
    [self addGreetingAndSignoff];
  }
  
  self.templateTitleTextField.hidden = self.hidesNavbarTextField;
  [self updateNavigationButtons];
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  self.navigationController.toolbarHidden = NO;
}

- (BOOL)showsToolsOnTheSide;
{
  return NO;
}

- (void)viewWillLayoutSubviews;
{
  [super viewWillLayoutSubviews];
  
  self.textView.top = 10.;
  self.textView.width = self.view.width - 20.;
  [self.textView centerHorizontallyInSuperView];
  self.toolsView.top = self.textView.bottom + 5.;
  self.toolsView.width = self.textView.width + 4.;
  self.toolsView.height = 30.;
  [self.toolsView centerHorizontallyInSuperView];
  self.templateTitleTextField.top = -1;
  if ([NavigationManager shared].deprecated_isFullscreen)
  {
    self.toolsView.top += 10.;
  }
}

- (void)didTapInsert;
{
  BSELF(TemplateDetailViewController);
  UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"Insert ..."];
  [self.tokens each:^(TemplateToken *token) {
    [sheet bk_addButtonWithTitle:token.title handler:^{
      [blockSelf insertToken:token];
    }];
  }];
  [sheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [sheet showFromToolbar:self.navigationController.toolbar];
}

- (void)didToggleCommentSwitchToPreference:(TemplateSendPreference)sendPref;
{
  self.sendPreference = sendPref;
  if (sendPref == TemplateSendPreferenceComment)
  {
    [self removeGreetingAndSignoff];
  }
  else
  {
    [self addGreetingAndSignoff];
  }
  [self updateNavigationButtons];
  self.templateTitleTextField.textColor = (self.sendPreference == TemplateSendPreferenceComment) ? [UIColor colorWithHex:0xad49e1] : [UIColor colorWithHex:0x009cff];
}

- (void)updateNavigationButtons;
{
  UIColor *tintColor = (self.sendPreference == TemplateSendPreferenceComment) ? [UIColor colorWithHex:0xad49e1] : [UIColor colorWithHex:0x009cff];
  NSString *buttonTitle = @"Save";
  
  if (self.useSendAsDoneButtonTitle)
  {
    buttonTitle = (self.sendPreference == TemplateSendPreferenceComment) ? @"Post Comment" : @"Send Message";
  }
  
  CGSize doneButtonOffset = JMIsIOS7() ? CGSizeMake(16., 3.) : CGSizeMake(0., 3.);
  UIBarButtonItem *doneButton = [UIBarButtonItem skinBarItemWithTitle:buttonTitle textColor:tintColor fillColor:nil positionOffset:doneButtonOffset target:self action:@selector(done)];
//  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleDone target:self action:@selector(done)];
//  doneButton.tintColor = tintColor;
  self.navigationItem.rightBarButtonItem = doneButton;
  
  BOOL shouldDisableDone = (self.sendPreference == TemplateSendPreferenceComment && [self.textView.text isEmpty]) ||
                           (self.sendPreference == TemplateSendPreferencePersonalMessage && [self.textView.text equalsString:[NSString stringWithFormat:@"%@%@", self.standardGreeting, self.standardSignoff]]);
  
  doneButton.enabled = !shouldDisableDone;
}

- (void)insertToken:(TemplateToken *)token;
{
  [self.textView insertText:token.replacerString];
  
  if (self.mode == TemplateDetailModeExpanded)
  {
    NSRange cursorRange = self.textView.selectedRange;
    [self.textView setText:[self deflatedBodyFromTextView]];
    if (cursorRange.location <= self.textView.text.length)
    {
      self.textView.selectedRange = cursorRange;
    }
  }
}

- (NSString *)deflatedBodyFromTextView;
{
  NSMutableString *deflated = [NSMutableString stringWithString:self.textView.text];
  [self.tokens each:^(TemplateToken *token) {
    [token applyTokenToMutableString:deflated];
  }];
  return deflated;
}

#pragma mark - Manage greeting/sign-off for messages

- (NSString *)standardGreeting;
{
  TemplateToken *usernameToken = [self.tokens match:^BOOL(TemplateToken *token) {
    return [token.tokenIdent equalsString:@"poster_username"];
  }];
  NSString *greeting = [NSString stringWithFormat:@"Hi %@,\n\n", usernameToken.replacerString];
  return greeting;
}

- (NSString *)standardSignoff;
{
  TemplateToken *modUsernameToken = [self.tokens match:^BOOL(TemplateToken *token) {
    return [token.tokenIdent equalsString:@"moderator_username"];
  }];
  NSString *signoff = [NSString stringWithFormat:@"\n\nRegards,\n\n%@", modUsernameToken.replacerString];
  return signoff;
}

- (void)removeGreetingAndSignoff;
{
  NSMutableString *content = [NSMutableString stringWithString:self.textView.text];
  [content removeOccurrencesOfString:self.standardGreeting.jm_trimmed];
  [content removeOccurrencesOfString:self.standardSignoff.jm_trimmed];
  self.textView.text = content.jm_trimmed;
}

- (void)addGreetingAndSignoff;
{
  [self removeGreetingAndSignoff];
  NSString *trimmedText = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *content = [NSString stringWithFormat:@"%@%@%@", self.standardGreeting, trimmedText, self.standardSignoff];
  self.textView.text = content;
}

#pragma mark - JMTextViewDelegate methods

- (CGFloat)heightForTextViewInOrientation:(UIInterfaceOrientation)orientation;
{
  CGFloat height = [super heightForTextViewInOrientation:orientation];
  if (UIInterfaceOrientationIsPortrait(orientation) || JMIsIpad())
  {
    height -= 30.;
  }
  return height;
}

- (void)textViewDidEnterValue:(NSString *)value propertyKey:(NSString *)propertyKey;
{
  if (!self.onTemplateEditComplete)
    return;

  NSString *deflated = [self deflatedBodyFromTextView];
  NSString *templateTitle = self.templateTitleTextField.text;
  self.onTemplateEditComplete(templateTitle, deflated, self.sendPreference);
}

- (void)textViewDidChange:(UITextView *)textView;
{
  if (!self.navigationItem.rightBarButtonItem.enabled)
  {
    self.navigationItem.rightBarButtonItem.enabled = YES;
  }
}

- (void)cancel;
{
  [self.navigationController popViewControllerAnimated:YES];
}

@end
