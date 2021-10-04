//
//  SettingsViewController.h
//  Alien Blue :: http://alienblue.org
//
//  Created by Jason Morrissey on 4/04/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionTableViewController.h"
#import <MessageUI/MessageUI.h>

@interface LegacySettingsTableViewController : OptionTableViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate> {
	BOOL isOffsetAdjusted;
	BOOL backgroundSupported;
	BOOL isUpgradeInProgress;
}

@property (copy) JMAction onTableReloadAction;
@property (copy) JMAction onProUpgradeStopPurchaseIndicator;
@property (readonly) NSString *appVersion;

- (void)stopPurchaseActivityIndicator;
- (void)didChooseSecondaryOptionAtIndexPath:(NSIndexPath *)indexPath;
- (void)postStyleChangeNotification;
+ (void)toggleNightTheme;



@end
