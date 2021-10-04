//
//  ScreenLockSettings.m
//  AlienBlue
//
//  Created by JM on 28/09/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "ScreenLockSettings.h"
#import "AlienBlueAppDelegate.h"

@implementation ScreenLockSettings

@synthesize existingCodeTextField;
@synthesize nCodeTextField;
@synthesize confirmCodeTextField;
@synthesize passcodeSwitch;

- (void)passcodeSwitchChanged:(id)sender
{
	[UDefaults setBool:passcodeSwitch.on forKey:kABSettingKeyShouldPasswordProtect];
  
	if (passcodeSwitch.on)
	{
		if ([nCodeTextField.text length] == 4)
		{
			[UDefaults setValue:nCodeTextField.text forKey:kABSettingKeyPasswordCode];
			[PromptManager addPrompt:@"Passcode is now active."];
		}
		else if ([existingCodeTextField.text length] == 4)
		{
			[UDefaults setValue:existingCodeTextField.text forKey:kABSettingKeyPasswordCode];
			[PromptManager addPrompt:@"Password is now active."];
		}
	}
	else {
		[UDefaults setValue:@"" forKey:kABSettingKeyPasswordCode];
	}
	
	[UDefaults synchronize];
	[existingCodeTextField resignFirstResponder];
	[nCodeTextField resignFirstResponder];	
	[confirmCodeTextField resignFirstResponder];		
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField == nCodeTextField || textField == confirmCodeTextField)
	{
		passcodeSwitch.on = NO;
		passcodeSwitch.enabled = NO;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == existingCodeTextField)
  {
    [existingCodeTextField resignFirstResponder];
  }
  else if (textField == nCodeTextField)
  {
    [confirmCodeTextField becomeFirstResponder];
  }   
  else if (textField == confirmCodeTextField) {
    [confirmCodeTextField resignFirstResponder];
  } 
  return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  NSUInteger limit = 3;

	if (textField == existingCodeTextField && [[textField.text stringByAppendingString:string] isEqualToString:[UDefaults valueForKey:kABSettingKeyPasswordCode]])
  {
    self.passcodeSwitch.alpha = 1.0;
    self.passcodeSwitch.enabled = YES;
    existingCodeTextField.enabled = NO;
    existingCodeTextField.hidden = YES;
    nCodeTextField.enabled = YES;
    confirmCodeTextField.enabled = YES;
    nCodeTextField.alpha = 1.0;
    confirmCodeTextField.alpha = 1.0;
  }
	
	if (textField == nCodeTextField &&		
		[[textField.text stringByAppendingString:string] length] == 4 &&
		[[textField.text stringByAppendingString:string] isEqualToString:confirmCodeTextField.text])
	{
		passcodeSwitch.enabled = YES;
		passcodeSwitch.alpha = 1.0;	
	}
	else if (textField == nCodeTextField)
	{
		passcodeSwitch.enabled = NO;
		passcodeSwitch.alpha = 0.3;
	}

	
	if (textField == confirmCodeTextField &&		
		[[textField.text stringByAppendingString:string] length] == 4 &&
		[[textField.text stringByAppendingString:string] isEqualToString:nCodeTextField.text])
	{
		passcodeSwitch.enabled = YES;
		passcodeSwitch.alpha = 1.0;
	}
	else if (textField == confirmCodeTextField)
	{
		passcodeSwitch.enabled = NO;
		passcodeSwitch.alpha = 0.3;
	}
  return !([textField.text length]>limit && [string length] > range.length);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [[NavigationManager shared] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (UIView *)createWrapperViewAroundLegacyUIElements;
{
  UIView *wrapperView = [[UIView alloc] initWithFrame:self.view.bounds];
  UIView *legacyParentView = existingCodeTextField.superview;
  [[legacyParentView jm_subviewsOfClass:[UILabel class]] each:^(UILabel *label) {
    label.textColor = [UIColor colorForText];
  }];
  UISwitch *switchView = (UISwitch *)[legacyParentView jm_firstSubviewOfClass:[UISwitch class]];
  switchView.tintColor = [UIColor colorForHighlightedOptions];
  
  [wrapperView addSubview:legacyParentView];
  wrapperView.autoresizingMask = JMFlexibleSizeMask;
  return wrapperView;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Passcode Settings";
  [self.tableView addSubview:[self createWrapperViewAroundLegacyUIElements]];
	
	existingCodeTextField.delegate = self;
	nCodeTextField.delegate = self;
	confirmCodeTextField.delegate = self;
	[passcodeSwitch addTarget:self action:@selector(passcodeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
	
	existingCodeTextField.hidden = YES;
	nCodeTextField.enabled = NO;
	nCodeTextField.alpha = 0.5;
	confirmCodeTextField.enabled = NO;
	confirmCodeTextField.alpha = 0.5;
	passcodeSwitch.on = NO;
	passcodeSwitch.enabled = NO;
	passcodeSwitch.alpha = 0.3;	
	
	// lock is active
	if ([UDefaults boolForKey:kABSettingKeyShouldPasswordProtect] && [[UDefaults valueForKey:kABSettingKeyPasswordCode] length] > 0)
	{
		existingCodeTextField.hidden = NO;
		passcodeSwitch.on = YES;
	}
	else
	{
		nCodeTextField.enabled = YES;
		nCodeTextField.alpha = 1.0;
		confirmCodeTextField.enabled = YES;
		confirmCodeTextField.alpha = 1.0;
	}
}

- (void)viewDidUnload
{
  [super viewDidUnload];
	self.existingCodeTextField = nil;	
	self.nCodeTextField = nil;	
	self.confirmCodeTextField = nil;	
	self.passcodeSwitch = nil;	
}

@end
