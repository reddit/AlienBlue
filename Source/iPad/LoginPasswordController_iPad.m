//
//  LoginPasswordController_iPad.m
//  AlienBlue
//
//  Created by J M on 4/03/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "LoginPasswordController_iPad.h"
#import "JMTextField.h"
#import "OverlayViewContainer.h"
#import "RedditAlienDrawing.h"
#import "UIAlertView+BlocksKit.h"
#import "Resources.h"

#import "ABCustomOutlineNavigationBar.h"
#import "JMOutlineViewController+CustomNavigationBar.h"

@interface LoginPasswordController_iPad();

@property (weak) id callbackTarget;
@property NSInteger accountIndex;

@property (strong) NSString *username;
@property (strong) NSString *password;

@property (strong) JMTextField *usernameField;
@property (strong) JMTextField *passwordField;

@end

@implementation LoginPasswordController_iPad

- (id)initWithUsername:(NSString *)username password:(NSString *)password;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.username = username;
        self.password = password;
        
        self.navigationItem.title = @"Reddit Account";
        [self setNavbarTitle:@"Reddit Account"];
        UIBarButtonItem *cancelButton =[UIBarButtonItem skinBarItemWithTitle:@"Cancel" target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButton;
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submit)];
        UIBarButtonItem *doneButton = [UIBarButtonItem skinBarItemWithTitle:@"Done" target:self action:@selector(submit)];
        self.navigationItem.rightBarButtonItem = doneButton;
      
        [self jm_usePreIOS7ScrollBehavior];
    }
    return self;
}

- (UIView *)createViewContents;
{
  UIView *wrapperView = [[UIView alloc] initWithFrame:self.view.bounds];
  wrapperView.autoresizingMask = JMFlexibleSizeMask;

  CGFloat usernameFieldTop = [Resources isIPAD] ? 60. : 8;
  CGFloat passwordFieldTop = [Resources isIPAD] ? 140. : 56;
  CGFloat noAccountTopOffset = [Resources isIPAD] ? 70. : 58.;
  CGFloat alienTop = [Resources isIPAD] ? 120. : 86;
  CGFloat alienWidth = [Resources isIPAD] ? 400. : 200.;
  
  OverlayViewContainer *bg = [[OverlayViewContainer alloc] initWithFrame:wrapperView.bounds];
  bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [wrapperView addSubview:bg];
  
  JMViewOverlay *gradient = [JMViewOverlay overlayWithFrame:bg.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    [UIView drawGradientInRect:bounds minHeight:0. startColor:[UIColor colorForBackground] endColor:[UIColor colorForBackgroundAlt]];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect alienBounds = CGRectCenterWithSize(bounds, CGSizeMake(alienWidth, alienWidth));
    alienBounds.origin.y = alienTop;
    alienBounds.origin.x += 6.;
    
    UIColor *alienColor = [[UIColor colorForBackground] jm_darkenedWithStrength:0.1];
    [UIView startEtchedDraw];
    DrawAlienHead(context, alienBounds, alienColor.CGColor, 100., 287., 16.);
    [UIView endEtchedDraw];
    
  }];
  gradient.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  [bg addOverlay:gradient];
  
  self.usernameField = [[JMTextField alloc] initWithFrame:CGRectMake(40., usernameFieldTop, 290., 42)];
  self.passwordField = [[JMTextField alloc] initWithFrame:CGRectMake(40., passwordFieldTop, 290., 42)];
  
  self.usernameField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  self.passwordField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  
  self.usernameField.placeholder = @"username ┊ case sensitive";
  self.passwordField.placeholder = @"password";
  
  self.usernameField.text = self.username;
  self.passwordField.text = self.password;
  
  self.passwordField.secureTextEntry = YES;
  
  self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  
  self.passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  
  if ([Resources isNight])
  {
    self.usernameField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.passwordField.keyboardAppearance = UIKeyboardAppearanceDark;
  }
  
  [wrapperView addSubview:self.usernameField];
  [wrapperView addSubview:self.passwordField];
  
  [self.usernameField centerHorizontallyInSuperView];
  [self.passwordField centerHorizontallyInSuperView];
  
  CGRect noAccountFrame = CGRectOffset(self.passwordField.frame, 0., noAccountTopOffset);
  JMViewOverlay *noAccountOverlay = [JMViewOverlay overlayWithFrame:noAccountFrame drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
    NSString *message = @"Don't have an account?";
    UIFont *font = [UIFont boldSystemFontOfSize:13.];
    UIColor *textColor = highlighted ? [UIColor colorWithHex:0x4a4a4a] : [UIColor colorWithHex:0xaaaaaa];
    [textColor set];
    [message drawInRect:bounds withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
  } onTap:^(CGPoint touchPoint) {
    NSString *message = @"You need to create an account at Reddit.com prior to using Alien Blue. Would you like to do that now?";
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Create an Account" message:message];
    [alert bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [alert bk_addButtonWithTitle:@"Open Safari" handler:^{
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.reddit.com/register"]];
    }];
    [alert show];
  }];
  noAccountOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  [bg addOverlay:noAccountOverlay];
  
  return wrapperView;
}

- (void)loadView;
{
    [super loadView];
  
    BSELF(LoginPasswordController_iPad);
    ABCustomOutlineNavigationBar *customNavigationBar = (ABCustomOutlineNavigationBar *)self.attachedCustomNavigationBar;
    [customNavigationBar setCustomLeftButtonWithIcon:[ABCustomOutlineNavigationBar cancelIcon] onTapAction:^{
      [blockSelf cancel];
    }];
    [customNavigationBar setCustomRightButtonWithTitle:@"Done" onTapAction:^{
      [blockSelf submit];
    }];
  
    UIView *wrapperView = [self createViewContents];
    [self.tableView addSubview:wrapperView];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  BSELF(LoginPasswordController_iPad);
  DO_AFTER_WAITING(0.1, ^{
    [blockSelf.usernameField becomeFirstResponder];
  });
}

- (void)setCallbackTarget:(id)callbackTarget forAccountIndex:(NSInteger)accountIndex;
{
    self.callbackTarget = callbackTarget;
    self.accountIndex = accountIndex;
}

- (void)dismiss;
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submit;
{
    if (!self.callbackTarget)
        return;
    
    if ([self.usernameField.text isEmpty])
        return;

    if ([self.passwordField.text isEmpty])
        return;
    
    NSMutableDictionary *entered = [NSMutableDictionary dictionary];
    [entered setValue:self.usernameField.text forKey:@"username"];
    [entered setValue:self.passwordField.text forKey:@"password"];
    [entered setValue:[NSNumber numberWithInt:self.accountIndex] forKey:@"responseID"];
    [entered setValue:[NSNumber numberWithInt:1] forKey:@"accountTypeID"];

    [self.callbackTarget performSelector:@selector(userPassEntered:) withObject:entered];
    
    [self dismiss];
}

- (void)cancel;
{
    [self dismiss];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return YES;
}


@end
