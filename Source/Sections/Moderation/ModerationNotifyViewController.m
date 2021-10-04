#import "ModerationNotifyViewController.h"
#import "TemplatePrefs.h"
#import "TemplateDetailViewController.h"
#import "RedditAPI.h"
#import "ABNavigationController.h"
#import "MBProgressHUD.h"
#import "NavigationManager.h"
#import "Resources.h"
#import "CommentsViewController+ReplyInteraction.h"

#import "RedditAPI.h"
#import "RedditAPI+Messages.h"
#import "RedditAPI+Comments.h"
#import "RedditAPI+Moderation.h"
#import "RedditAPI+Account.h"

@interface ModerationNotifyViewController()
@property (strong) Post *post;
@end

@implementation ModerationNotifyViewController

- (id)initWithPost:(Post *)post;
{
  NSString *defaultGroupIdent = (post.moderationState == ModerationStateApproved) ? kTemplatePrefsGroupIdentApproval : kTemplatePrefsGroupIdentRemoval;
  self = [super initWithDefaultGroupIdent:defaultGroupIdent];
  if (self)
  {
    self.post = post;
//    NSString *modAction = (post.moderationState == ModerationStateApproved) ? @"Post Approval" : @"Post Removal";
    self.hidesBottomBarWhenPushed = YES;
    [self setNavbarTitle:@"Notify User"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = nil;
  }
  return self;
}

- (void)cancel;
{
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)enableEditMode;
{
}

- (void)disableEditMode;
{
}

- (void)loadView;
{
  [super loadView];
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 320., 136.)];
  headerView.backgroundColor = [UIColor colorForBackground];
  self.tableView.tableHeaderView = headerView;
  
  UIImage *messageButtonBgImage = [[UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    [[UIColor colorWithWhite:0. alpha:0.07] set];
    [UIView startEtchedDraw];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 2., 2.) cornerRadius:6.] fill];
    [UIView endEtchedDraw];
    UIImage *disclosureIcon = [UIImage skinImageNamed:@"icons/disclosure-arrow" withColor:[UIColor colorForAccessoryButtons]];
    [disclosureIcon drawAtPoint:CGPointMake(27., 18.)];
  } withSize:CGSizeMake(51., 51.)] jm_resizeable];
  
  UIButton *customMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
  customMessageButton.frame = CGRectMake(0., 0., 280., 40.);
  [customMessageButton setBackgroundImage:messageButtonBgImage forState:UIControlStateNormal];
  [customMessageButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
  [customMessageButton setTitle:@"Enter a custom message" forState:UIControlStateNormal];
  customMessageButton.titleLabel.font = [UIFont skinFontWithName:kBundleFontPostSubtitleBold];
  customMessageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
  customMessageButton.titleEdgeInsets = UIEdgeInsetsMake(0., 15., 0., 0.);
  [customMessageButton setTitleShadowColor:[UIColor colorForInsetDropShadow] forState:UIControlStateNormal];
  customMessageButton.titleLabel.shadowOffset = CGSizeMake(0., 1.);
  [headerView addSubview:customMessageButton];
  [customMessageButton centerHorizontallyInSuperView];
  customMessageButton.autoresizingMask = JMFlexibleHorizontalMarginMask;
  customMessageButton.top = 15.;
  [customMessageButton addTarget:self action:@selector(didTapEnterCustomMessageButton) forControlEvents:UIControlEventTouchUpInside];
  
  UILabel *orLabel = [UILabel new];
  orLabel.text = @"OR";
  orLabel.backgroundColor = [UIColor colorForBackground];
  orLabel.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
  orLabel.shadowColor = [UIColor colorForInsetDropShadow];
  orLabel.shadowOffset = CGSizeMake(0., 1.);
  orLabel.font = [UIFont skinFontWithName:kBundleFontNavigationButtonTitle];
  [orLabel sizeToFit];
  [headerView addSubview:orLabel];
  [orLabel centerHorizontallyInSuperView];
  orLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  orLabel.top = customMessageButton.bottom + 15.;
  
  UILabel *chooseTemplate = [UILabel new];
  chooseTemplate.backgroundColor = orLabel.backgroundColor;
  chooseTemplate.textColor = [UIColor grayColor];
  chooseTemplate.text = @"Choose from a template:";
  chooseTemplate.font = customMessageButton.titleLabel.font;
  chooseTemplate.shadowColor = customMessageButton.titleLabel.shadowColor;
  chooseTemplate.shadowOffset = customMessageButton.titleLabel.shadowOffset;
  [chooseTemplate sizeToFit];
  [headerView addSubview:chooseTemplate];
//  chooseTemplate.left = customMessageButton.left + 5.;
  [chooseTemplate centerHorizontallyInSuperView];
  chooseTemplate.autoresizingMask = JMFlexibleHorizontalMarginMask;
  chooseTemplate.top = orLabel.bottom + 15.;
  
  if (JMIsIphone())
  {
    chooseTemplate.left = 18;
  }
  
  UIImage *manageButtonBg = [[UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    [[UIColor grayColor] set];
    [UIView startEtchedDraw];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 2., 2.) cornerRadius:6.] fill];
    [UIView endEtchedDraw];
  } withSize:CGSizeMake(51., 21.)] jm_resizeable];
  
  UIButton *manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
  manageButton.frame = CGRectMake(0., 0., 100., 30.);
  [manageButton setBackgroundImage:manageButtonBg forState:UIControlStateNormal];
  [manageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [manageButton setTitle:@"Edit Templates" forState:UIControlStateNormal];
  manageButton.titleLabel.font = [UIFont skinFontWithName:kBundleFontPostSubtitleBold];
//  [customMessageButton setTitleShadowColor:[UIColor colorForInsetDropShadow] forState:UIControlStateNormal];
//  customMessageButton.titleLabel.shadowOffset = CGSizeMake(0., 1.);
  [headerView addSubview:manageButton];
  manageButton.right = headerView.width - 10.;
  manageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  manageButton.top = chooseTemplate.top - 5.;
  [manageButton addTarget:self action:@selector(showManageTemplates) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showManageTemplates;
{
  BSELF(ModerationNotifyViewController);
  TemplatesViewController *controller = [[TemplatesViewController alloc] initWithDefaultGroupIdent:self.group.ident];
  controller.onDismiss = ^{
    [blockSelf reloadTemplatePreferences];
  };
  ABNavigationController *navController = [[ABNavigationController alloc] initWithRootViewController:controller];
  navController.modalPresentationStyle = UIModalPresentationFormSheet;
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (TemplateNode *)generateTemplateNodeForTemplate:(Template *)tPlate;
{
  TemplateNode *tNode = [super generateTemplateNodeForTemplate:tPlate];
  [tNode collapseNode];
  return tNode;
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
  self.navigationController.toolbarHidden = YES;
}

- (void)showSendTemplateControllerForTemplate:(Template *)tPlate;
{
  BSELF(ModerationNotifyViewController);
  NSArray *tokens = [self tokensWhenEditing];
  TemplateDetailViewController *controller = [[TemplateDetailViewController alloc] initWithTemplate:tPlate mode:TemplateDetailModeExpanded tokens:tokens];
  controller.hidesNavbarTextField = YES;
  controller.useSendAsDoneButtonTitle = YES;
  controller.onTemplateEditComplete = ^(NSString *templateTitle, NSString *body, TemplateSendPreference sendPreference) {
    [MBProgressHUD showHUDAddedTo:blockSelf.navigationController.view animated:YES];
    [blockSelf sendNotificationToUserWithTitle:templateTitle body:body sendPreference:sendPreference];
  };
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)didSelectTemplate:(Template *)tPlate;
{
  [self showSendTemplateControllerForTemplate:tPlate];
}

- (void)didTapEnterCustomMessageButton;
{
  [self showSendTemplateControllerForTemplate:nil];
}

#pragma mark - Token Replacers

- (NSString *)tokenReplacerPosterUsername;
{
  return self.post.author;
}

- (NSString *)tokenReplacerLinkToPost;
{
  return [NSString stringWithFormat:@"http://www.reddit.com/%@", self.post.permalink];
}

- (NSString *)tokenReplacerLinkToSubreddit;
{
  return [NSString stringWithFormat:@"/r/%@", self.post.subreddit];
}

- (NSString *)tokenReplacerLinkToSidebar;
{
  return [NSString stringWithFormat:@"http://www.reddit.com/r/%@/about/sidebar", self.post.subreddit];
}

- (NSString *)tokenReplacerLinkToWiki;
{
  return [NSString stringWithFormat:@"http://www.reddit.com/r/%@/wiki/", self.post.subreddit];
}

- (NSString *)tokenReplacerModeratorUsername;
{
  return [RedditAPI shared].authenticatedUser;
}

#pragma mark - Sending Mod Message

- (void)didFinishSendingModNotificationWithResponse:(id)response;
{
  BSELF(ModerationNotifyViewController);
  [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
  
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
    [PromptManager addPrompt:@"Mod message is sent"];
    if (blockSelf.onModerationNotifySendComplete)
    {
      blockSelf.onModerationNotifySendComplete(response);
    }
  }];
}

- (void)didFailSendingNotification;
{
  [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
}

- (void)sendNotificationToUserViaCommentWithBody:(NSString *)commentBody;
{
  NSMutableDictionary *cDictionary = [NSMutableDictionary dictionary];
  cDictionary[@"replyText"] = commentBody;
  cDictionary[@"name"] = self.post.name;
  [[RedditAPI shared] replyToItem:cDictionary callbackTarget:self];
}

- (void)sendNotificationToUserViaMessageWithSubject:(NSString *)subject body:(NSString *)body;
{
  NSString *subj = subject;
  NSString *content = body;
  NSString *uname = self.post.author;
  
  SET_IF_EMPTY(subj, @"");
  SET_IF_EMPTY(content, @"");
  SET_IF_EMPTY(uname, @"");
  
  NSMutableDictionary * newPM = [[NSMutableDictionary alloc] init];
  [newPM setValue:content forKey:@"content"];
  [newPM setValue:subj forKey:@"subject"];
  [newPM setValue:uname forKey:@"toUsername"];
  [[RedditAPI shared] submitDirectMessage:newPM withCallBackTarget:self];
}

- (void)sendNotificationToUserWithTitle:(NSString *)title body:(NSString *)body sendPreference:(TemplateSendPreference)sendPref;
{
  if (sendPref == TemplateSendPreferenceComment)
    [self sendNotificationToUserViaCommentWithBody:body];
  else
    [self sendNotificationToUserViaMessageWithSubject:title body:body];
}

#pragma mark - API Callbacks

- (void)apiReplyResponse:(id)sender
{
	NSDictionary * newComment = (NSDictionary *) sender;
  
  if (newComment && [newComment isKindOfClass:[NSDictionary class]])
  {
    NSString *newCommentName = [newComment objectForKey:@"name"];
    [[RedditAPI shared] modDistinguishItemWithName:newCommentName distinguish:YES];
    [self didFinishSendingModNotificationWithResponse:sender];
  }
  else
  {
    [self didFailSendingNotification];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Comment Failed" message:@"reddit returned an error when trying to post this moderation comment" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
  }
}

- (void)submitResponse:(id)sender
{
  NSMutableArray * errors = (NSMutableArray *) sender;  
  if (errors && [errors count] == 0)
  {
    [self didFinishSendingModNotificationWithResponse:sender];
  }
  else
  {
    [self didFailSendingNotification];
    NSMutableString * errorMessage = [NSMutableString stringWithString:@"reddit has reported the following information:\n\n"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
  }
//  else if (errors && [errors count] > 0)
//  {
//    BOOL captchaError = NO;
//    NSMutableString * errorMessage = [NSMutableString stringWithString:@"Reddit has reported the following information:\n\n"];
//    
//    for (NSString * error in errors)
//    {
//      if ([error contains:@"captcha"])
//      {
//        captchaError = YES;
//      }
//      [errorMessage appendFormat:@"* %@\n", error];
//    }
//    
//    if ([errors count] == 1 && captchaError)
//    {
//      [self showCaptchaEntry];
//    }
//    else
//    {
//      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//      [alert show];
//    }
//  }
}

@end
