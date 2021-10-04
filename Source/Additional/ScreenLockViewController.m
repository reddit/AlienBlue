//
//  ScreenLockViewController.m
//  AlienBlue
//
//  Created by JM on 28/09/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "ScreenLockViewController.h"
#import "AlienBlueAppDelegate.h"
#import "Resources.h"

@implementation ScreenLockViewController

@synthesize lockTextField;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self jm_usePreIOS7ScrollBehavior];
  
	[lockTextField setText:@""];
	lockTextField.delegate = self;
  lockTextField.keyboardAppearance = JMIsNight() ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDefault;
}

- (void)viewWillLayoutSubviews;
{
  [super viewWillLayoutSubviews];
  if (JMIsIphone() && JMIsIOS7())
  {
    [self.lockImageView centerVerticallyInSuperView];
    self.lockImageView.top -= 90.;
    self.lockTextField.top = self.lockImageView.bottom - 5.;
    
    self.view.backgroundColor = [UIColor colorForBackground];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([Resources isIPAD])
		return YES;
	
	return [[NavigationManager shared] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  int limit = 3;
	if ([[textField.text stringByAppendingString:string] isEqualToString:[UDefaults valueForKey:kABSettingKeyPasswordCode]])
  [[NavigationManager shared] dismissModalView];
  return !([textField.text length]>limit && [string length] > range.length);
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[lockTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
	self.lockTextField = nil;
}

@end
