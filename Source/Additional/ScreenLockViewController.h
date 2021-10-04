//
//  ScreenLockViewController.h
//  AlienBlue
//
//  Created by JM on 28/09/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationManager.h"

@interface ScreenLockViewController : UIViewController <UITextFieldDelegate>
{
	IBOutlet UITextField * lockTextField;
}

@property (nonatomic, strong) IBOutlet UITextField *lockTextField;
@property (nonatomic, strong) IBOutlet UIImageView *lockImageView;

@end
