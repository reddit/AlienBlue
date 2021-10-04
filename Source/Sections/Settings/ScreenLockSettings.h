//
//  ScreenLockSettings.h
//  AlienBlue
//
//  Created by JM on 28/09/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationManager.h"
#import "ABOutlineViewController.h"

@interface ScreenLockSettings : ABOutlineViewController <UITextFieldDelegate> {
	IBOutlet UITextField *existingCodeTextField;
	IBOutlet UITextField *nCodeTextField;
	IBOutlet UITextField *confirmCodeTextField;
	IBOutlet UISwitch *passcodeSwitch;
}

@property (nonatomic, strong) IBOutlet UITextField *existingCodeTextField;
@property (nonatomic, strong) IBOutlet UITextField *nCodeTextField;
@property (nonatomic, strong) IBOutlet UITextField *confirmCodeTextField;
@property (nonatomic, strong) IBOutlet UISwitch *passcodeSwitch;
@end
