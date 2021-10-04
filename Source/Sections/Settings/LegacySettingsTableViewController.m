//
//  SettingsViewController.m
//  Alien Blue :: http://alienblue.org
//
//  Created by Jason Morrissey on 4/04/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "LegacySettingsTableViewController.h"
#import "LegacySettingsTableViewController+LegacyDataSource.h"
#import "Resources.h"
#import "LoginPasswordController_iPad.h"
#import "ImgurManagerTableController.h"
#import "EMAddNoteViewController.h"
#import "AlienBlueAppDelegate.h"
#import "OptionCell.h"
#import "BrowserViewController.h"
#import "ABMailComposer.h"
#import "ScreenLockSettings.h"
#import "ABBundleManager.h"
#import "SFHFKeychainUtils.h"
#import "SHK.h"
#import "UIAlertView+BlocksKit.h"
#import "UIImage+Skin.h"
#import "JMDiskCache.h"
#import "AFNetworking.h"
#import "UIApplication+ABAdditions.h"
#import "SessionManager+Authentication.h"
#import "ABWindow.h"
#import "MKStoreManager.h"
#import "ImgurManagerController.h"
#import "NSData+Zip.h"
#import "UIDeviceHardware.h"
#import "RedditAPI+OAuth.h"

@implementation LegacySettingsTableViewController

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kProUpgradeNotification object:nil];
}

- (void)postStyleChangeNotification;
{
  [[NSNotificationCenter defaultCenter] postNotificationName:kNightModeSwitchNotification object:nil];
  [self performSelector:@selector(nightModeSwitch) withObject:nil afterDelay:0.2];
  BSELF(LegacySettingsTableViewController);
  DO_AFTER_WAITING(0.5, ^{
     [blockSelf setNavbarTitle:blockSelf.navigationItem.title];
  });
}

- (void)showImgurUploadManager;
{
  ImgurManagerController *controller = [UNIVERSAL(ImgurManagerController) new];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)showScreenLockSettings;
{
  ScreenLockSettings * lockSettings = [[ScreenLockSettings alloc] initWithNibName:@"ScreenLockSettings" bundle:nil];
  [self.navigationController pushViewController:lockSettings animated:YES];
}

- (void)buyProUpgrade;
{
  isUpgradeInProgress = YES;
  [[MKStoreManager sharedManager] buyProUpgrade];
}

- (void)toggleLowContrastMode;
{
  BOOL updatedContrastModeSetting = ![UDefaults boolForKey:kABSettingKeyLowContrastMode];
  [UDefaults setBool:updatedContrastModeSetting forKey:kABSettingKeyLowContrastMode];
  if (updatedContrastModeSetting)
  {
    [ABWindow dimToAlpha:0.4];
  }
  else
  {
    [ABWindow removeDim];
  }
  [UIApplication ab_updateStatusBarTint];
}

- (void)restoreProUpgrade;
{
  if (isUpgradeInProgress)
  {
    [(AlienBlueAppDelegate *) [[UIApplication sharedApplication] delegate] stopPurchaseIndicator];
  }
  else
  {
    isUpgradeInProgress = YES;
    [[MKStoreManager sharedManager] restoreUpgrade];
  }
}

- (void)logoutFromSharingOptions;
{
  [SHK logoutOfAll];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share Options"
                                                  message:@"Your sharing logins have been cleared from Alien Blue."
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
  [alert setTag:90];
  [alert show];
}

- (void)clearCache;
{
  [PromptManager addPrompt:@"Clearing cache. Please wait."];
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in [cookieStorage cookies])
    {
      [cookieStorage deleteCookie:each];
    }
    
    [UIImage jm_clearCachedImages];
    [[AFImageCache sharedImageCache] removeAllObjects];
    [[JMDiskCache shared] clearCache];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    DO_IN_MAIN(^{
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cache Cleared"
                                                      message:@"Alien Blue's cache and browser cookies have been cleared."
                                                     delegate:nil
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
      [alert setTag:90];
      [alert show];
    });
  });
}

- (void)chooseSkinTheme;
{
	NSMutableArray * labels = [[NSMutableArray alloc] initWithCapacity:0];
	NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSString * prefKey = kABSettingKeySkinTheme;
	NSString * title = @"Theme";
	OptionActionSheetValueType typeId = OptionActionSheetValueTypeString;
	
	[labels addObject:@"Classic Blue"];
	[values addObject:[NSNumber numberWithInt:SkinThemeClassic]];

  if ([Resources isIPAD])
  {
    [labels addObject:@"Lion - Wood"];
    [values addObject:[NSNumber numberWithInt:SkinThemeLion]];

    [labels addObject:@"Lion - Slate"];
    [values addObject:[NSNumber numberWithInt:SkinThemeLionAlt]];
  }
  else
  {
    [labels addObject:@"Lion"];
    [values addObject:[NSNumber numberWithInt:SkinThemeLionAlt]];
  }
    
	[labels addObject:@"Blossom"];
	[values addObject:[NSNumber numberWithInt:SkinThemeBlossom]];

	[labels addObject:@"Fire"];
	[values addObject:[NSNumber numberWithInt:SkinThemeFire]];
  
  BSELF(LegacySettingsTableViewController);
  [self presentOptionsWithTitle:title labels:labels values:values forKey:prefKey ofType:typeId doAfterChangingSetting:^{
    SkinTheme theme = (SkinTheme) [[UDefaults objectForKey:kABSettingKeySkinTheme] intValue];
    if (theme == SkinThemeLionAlt)
    {
      [UDefaults setInteger:SkinThemeLion forKey:kABSettingKeySkinTheme];
      [UDefaults setBool:YES forKey:kABSettingKeyIpadLionThemeShowsLinen];
      [UDefaults synchronize];
    }
    else if (theme == SkinThemeLion)
    {
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kABSettingKeyIpadLionThemeShowsLinen];
    }
    [blockSelf postStyleChangeNotification];
  }];
}

- (void)chooseResizeImages;
{
	NSMutableArray * labels = [[NSMutableArray alloc] initWithCapacity:0];
	NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSString * prefKey = kABSettingKeyResizeImageUploads;
	NSString * title = @"Should Alien Blue resize/compress your photos before uploading?";
  OptionActionSheetValueType typeId = OptionActionSheetValueTypeBoolean;
	
	[labels addObject:@"Resize Photos"];
	[values addObject:[NSNumber numberWithBool:YES]];
	
	[labels addObject:@"Use Full Resolution"];
	[values addObject:[NSNumber numberWithBool:NO]];
  
  [self presentOptionsWithTitle:title labels:labels values:values forKey:prefKey ofType:typeId doAfterChangingSetting:nil];
}

- (void)chooseCropImages;
{
	NSMutableArray * labels = [[NSMutableArray alloc] initWithCapacity:0];	
	NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSString * prefKey = kABSettingKeyCropImageUploads;
	NSString * title = @"Do you want to crop images before uploading?";
  OptionActionSheetValueType typeId = OptionActionSheetValueTypeBoolean;
	
	[labels addObject:@"Crop images first"];
	[values addObject:[NSNumber numberWithBool:YES]];
	
	[labels addObject:@"Upload without cropping"];
	[values addObject:[NSNumber numberWithBool:NO]];
	
  [self presentOptionsWithTitle:title labels:labels values:values forKey:prefKey ofType:typeId doAfterChangingSetting:nil];
}

- (void)chooseCommentThreshold;
{
	NSMutableArray * labels = [[NSMutableArray alloc] initWithCapacity:0];	
	NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSString * prefKey = kABSettingKeyCommentScoreThreshold;
	NSString * title = @"Hide Comments With Score";
  OptionActionSheetValueType typeId = OptionActionSheetValueTypeInteger;
	
	[labels addObject:@"Less Than +5"];
	[values addObject:[NSNumber numberWithInt:5]];
	
	[labels addObject:@"Less Than 0"];
	[values addObject:[NSNumber numberWithInt:0]];
	
	[labels addObject:@"Less Than -5"];
	[values addObject:[NSNumber numberWithInt:-5]];
	
	[labels addObject:@"Less Than -10"];
	[values addObject:[NSNumber numberWithInt:-10]];
	
	[labels addObject:@"Show All Comments"];
	[values addObject:[NSNumber numberWithInt:-5000]];
	
  [self presentOptionsWithTitle:title labels:labels values:values forKey:prefKey ofType:typeId doAfterChangingSetting:nil];
}

- (void)chooseMessageCheckFrequency;
{
	NSMutableArray * labels = [[NSMutableArray alloc] initWithCapacity:0];	
	NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSString * prefKey = kABSettingKeyMessageCheckFrequencyIndex;
	NSString * title = @"Check New Messages";
  OptionActionSheetValueType typeId = OptionActionSheetValueTypeInteger;
	
	[labels addObject:@"Manually"];
	[values addObject:[NSNumber numberWithInt:0]];
	
	[labels addObject:@"Every 5 Minutes"];
	[values addObject:[NSNumber numberWithInt:1]];
	
	[labels addObject:@"Every 10 Minutes"];
	[values addObject:[NSNumber numberWithInt:2]];
	
	[labels addObject:@"Every 20 Minutes"];
	[values addObject:[NSNumber numberWithInt:3]];
		
  [self presentOptionsWithTitle:title labels:labels values:values forKey:prefKey ofType:typeId doAfterChangingSetting:nil];
}

- (void)chooseTextSize;
{
	NSMutableArray * labels = [[NSMutableArray alloc] initWithCapacity:0];	
	NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSString * prefKey = kABSettingKeyTextSizeIndex;
	NSString * title = @"Text Size";
  OptionActionSheetValueType typeId = OptionActionSheetValueTypeInteger;
	
	[labels addObject:@"Tiny"];
	[values addObject:[NSNumber numberWithInt:0]];
	
	[labels addObject:@"Small"];
	[values addObject:[NSNumber numberWithInt:1]];
	
	[labels addObject:@"Medium"];
	[values addObject:[NSNumber numberWithInt:2]];

	[labels addObject:@"Large"];
	[values addObject:[NSNumber numberWithInt:3]];

	[labels addObject:@"Extra Large"];
	[values addObject:[NSNumber numberWithInt:4]];
	
	[[ABBundleManager sharedManager] resetFontCaches];
  
  BSELF(LegacySettingsTableViewController)
  [self presentOptionsWithTitle:title labels:labels values:values forKey:prefKey ofType:typeId doAfterChangingSetting:^{
     [blockSelf postStyleChangeNotification];
  }];
}

- (void)chooseCommentLoadCount;
{
	NSMutableArray * labels = [[NSMutableArray alloc] initWithCapacity:0];	
	NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSString * prefKey = kABSettingKeyCommentFetchCount;
	NSString * title = @"Comments to Fetch";
  OptionActionSheetValueType typeId = OptionActionSheetValueTypeInteger;
	
	[labels addObject:@"200"];
	[values addObject:[NSNumber numberWithInt:200]];

	[labels addObject:@"500"];
	[values addObject:[NSNumber numberWithInt:500]];

	[labels addObject:@"1000 (Reddit Gold)"];
	[values addObject:[NSNumber numberWithInt:1000]];
	
  [self presentOptionsWithTitle:title labels:labels values:values forKey:prefKey ofType:typeId doAfterChangingSetting:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 1 && buttonIndex == 1)
	{
		NSString *url = @"mailto:support@reddit.zendesk.com?subject=AlienBlue%20Fault";
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
	}
	if(alertView.tag == 2 && buttonIndex == 1)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://alienblue.org"]];
	}
}

- (void)removeFilterAtIndex:(NSUInteger)removeIndex;
{
	NSMutableArray * filterList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyFilterList]];
	[filterList removeObjectAtIndex:removeIndex];
	[UDefaults setObject:filterList forKey:kABSettingKeyFilterList];
	[UDefaults synchronize];
//	NSIndexPath * ip = [NSIndexPath indexPathForRow:removeIndex inSection:self.legacy_sectionIndexForFilter];
//	NSArray * arr = [NSArray arrayWithObject:ip];
//	[[self tableView] deleteRowsAtIndexPaths:arr withRowAnimation:YES];
	[self refreshTable];
}

- (void)donePressed:(id)sender
{
  [[NavigationManager shared] dismissModalView];
}

- (void)viewWillDisappear:(BOOL)animated;
{
  [super viewWillDisappear:animated];
  [[SessionManager manager] resetSwitchAccountCallback];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self jm_usePreIOS7ScrollBehavior];
  [self setNavbarTitle:@"Settings"];
	isUpgradeInProgress = NO;
	
	UIDevice* device = [UIDevice currentDevice];
	
	if ([device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported])
  {
		backgroundSupported = YES;
	}
	else
  {
		backgroundSupported = NO;
	}

  UIBarButtonItem *doneButton = [UIBarButtonItem skinBarItemWithTitle:@"Done" target:self action:@selector(donePressed:)];
  self.navigationItem.rightBarButtonItem = doneButton;

	if (![Resources isIPAD])
	{
    UIBarButtonItem *helpButton = [UIBarButtonItem skinBarItemWithTitle:@"Help" target:self action:@selector(showUpgradeHelpPage:)];
		self.navigationItem.leftBarButtonItem = helpButton;
	}
    
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPurchaseActivityIndicator) name:kProUpgradeNotification object:nil];
}

// this is called from the AppDelegate once the purchase is finished.
- (void)stopPurchaseActivityIndicator
{
	isUpgradeInProgress	= NO;
//	[self refreshTable];
  if (self.onProUpgradeStopPurchaseIndicator)
  {
    self.onProUpgradeStopPurchaseIndicator();
  }
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProUpgradeNotification object:nil];
    [super viewDidUnload];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self legacy_numberOfSettingsSections];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [self legacy_titleForSection:section];
}

- (void)removeRedditAccountAtIndex:(NSUInteger)removeIndex;
{
	NSMutableArray * redditAccountsList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyRedditAccountsList]];
	NSDictionary *accountDetailsToBeDeleted = redditAccountsList[removeIndex];
	NSString *usernameToDelete = accountDetailsToBeDeleted[@"username"];
	[redditAccountsList removeObjectAtIndex:removeIndex];
	[UDefaults setObject:redditAccountsList forKey:kABSettingKeyRedditAccountsList];
	[UDefaults synchronize];

	[[SessionManager manager] userDidDeleteAccountWithUsername:usernameToDelete];

	if ([redditAccountsList count] == 1)
	{
		[[SessionManager manager] switchToRedditAccountAtIndex:0 withCallBackTarget:self];
	}
	else if ([redditAccountsList count] == 0)
	{
		// logged out user should now see default subreddits
		[[NavigationManager shared] refreshUserSubreddits];
	}

  [self refreshTable];
}

- (void)addRedditAccount;
{	
	if (![MKStoreManager isProUpgraded] && [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count] > 0)
	{
		[MKStoreManager needProAlert];
		return;
	}		

  LoginPasswordController_iPad *controller = [[LoginPasswordController_iPad alloc] initWithUsername:nil password:nil];
  [controller setCallbackTarget:self forAccountIndex:-1];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)userDidAddNewRedditAccount:(NSMutableDictionary *)userPassEntered
{
  if (JMIsEmpty([userPassEntered valueForKey:@"password"]))
    return;
  
  NSMutableArray * redditAccountsList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyRedditAccountsList]];
  NSMutableDictionary * userPass = [NSMutableDictionary dictionaryWithCapacity:2];
  NSString *username = [userPassEntered valueForKey:@"username"];
  NSString *password = [userPassEntered valueForKey:@"password"];
  [[RedditAPI shared] deleteLegacyKeychainItemForUsername:username];
  
  [userPass setObject:username forKey:@"username"];
  [redditAccountsList addObject:userPass];
  [UDefaults setObject:redditAccountsList forKey:kABSettingKeyRedditAccountsList];
  [UDefaults synchronize];
  
  BSELF(LegacySettingsTableViewController);
  [[RedditAPI shared] authenticateAndPersistTokensWithUsername:username password:password onComplete:^{
    NSUInteger accountIndexToAuthenticate = [[UDefaults objectForKey:kABSettingKeyRedditAccountsList] count] -1 ;
    [[SessionManager manager] switchToRedditAccountAtIndex:accountIndexToAuthenticate withCallBackTarget:blockSelf];
  } onFailure:^(NSString *errorMessage) {
    [UIAlertView bk_showAlertViewWithTitle:@"Login Failed" message:errorMessage cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
  }];
}

- (void)userDidModifyRedditAccountAtIndex:(NSInteger)accountIndex userPassEntered:(NSMutableDictionary *)userPassEntered
{
  NSMutableArray * redditAccountsList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyRedditAccountsList]];
  NSMutableDictionary * userPass = [NSMutableDictionary dictionaryWithDictionary:[redditAccountsList objectAtIndex:accountIndex]];
  
  NSString *username = [userPassEntered valueForKey:@"username"];
  NSString *password = [userPassEntered valueForKey:@"password"];
  [userPass setObject:username forKey:@"username"];
  [redditAccountsList replaceObjectAtIndex:accountIndex withObject:userPass];
  [UDefaults setObject:redditAccountsList forKey:kABSettingKeyRedditAccountsList];
  [UDefaults synchronize];
  
  BSELF(LegacySettingsTableViewController);
  [[RedditAPI shared] authenticateAndPersistTokensWithUsername:username password:password onComplete:^{
    [[SessionManager manager] switchToRedditAccountAtIndex:accountIndex withCallBackTarget:blockSelf];
  } onFailure:^(NSString *errorMessage) {
    [UIAlertView bk_showAlertViewWithTitle:@"Login Failed" message:errorMessage cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
  }];
}

- (void)userPassEntered:(id)sender
{
  NSMutableDictionary *userPassEntered = (NSMutableDictionary *)sender;
  NSInteger accountIndex = [[userPassEntered valueForKey:@"responseID"] intValue];
  if (JMIsEmpty([userPassEntered valueForKey:@"username"]))
    return;
  
  if (accountIndex < 0)
  {
    [self userDidAddNewRedditAccount:userPassEntered];
  }
  else
  {
    [self userDidModifyRedditAccountAtIndex:accountIndex userPassEntered:userPassEntered];
  }
  
  [self refreshTable];
}


- (void)editAccountAtIndex:(NSUInteger)index;
{
  NSMutableDictionary * userPass = (NSMutableDictionary *) [[[NSUserDefaults standardUserDefaults] objectForKey:kABSettingKeyRedditAccountsList] objectAtIndex:index];
  NSString *username = [userPass valueForKey:@"username"];
  NSString *password = nil;
  
  LoginPasswordController_iPad *controller = [[LoginPasswordController_iPad alloc] initWithUsername:username password:password];
  [controller setCallbackTarget:self forAccountIndex:index];
    
	[self.navigationController pushViewController:controller animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self legacy_canEditRowAtIndexPath:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self legacy_commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

- (NSInteger)calculateNumberOfRowsInSection:(NSInteger)section;
{
  return [self legacy_numberOfRowsForSection:section];
}

- (NSString *)appVersion;
{
    return [NSString stringWithFormat:@"%@ %@",
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"],
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

- (NSString *)createLabelForIndexPath:(NSIndexPath *)indexPath
{
  return [self legacy_labelForIndexPath:indexPath];
}

- (void)addFilter;
{
	EMAddNoteViewController * addNoteController = [[EMAddNoteViewController alloc] initWithNibName:nil bundle:nil];
	[addNoteController setCallBackTarget:self withAction:@"noteEntered:" forResponseID:0];
	addNoteController.isNonAutocorrecting = YES;
	addNoteController.isSingleLineField = YES;
	[self.navigationController pushViewController:addNoteController animated:YES];
  [addNoteController setNavbarTitle:@"Exclude keyword/phrase"];
}

- (void)noteEntered:(id)sender
{
	NSMutableDictionary *entered = (NSMutableDictionary *)sender;
	NSString *enteredText = [entered valueForKey:@"text"];
	NSUInteger tag = [[entered valueForKey:@"responseID"] intValue];
	switch (tag) {
		case 0:
			if ([enteredText length] > 2)
			{
				NSMutableArray * filterList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyFilterList]];
				[filterList addObject:enteredText];
				[UDefaults setObject:filterList forKey:kABSettingKeyFilterList];
			}
			break;
		default:
			break;
	}
	[UDefaults synchronize];
	[self refreshTable];
}

- (void)createInteractionForIndexPath:(NSIndexPath *)indexPath forOption:(NSMutableDictionary *)option
{
  [self legacy_decorateForIndexPath:indexPath forOption:option];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	[self dismissModalViewControllerAnimated:YES];
}

- (void)showAcknowledgements;
{
	NSMutableString * str = [NSMutableString stringWithString:@"\n"];
  [str appendString:@"Alien Blue is made possible thanks to:\n\n"];
  [str appendString:@"AFNetworking (github/AFNetworking)\n"];
  [str appendString:@"BlocksKit (github/zwaldowski)\n"];
  [str appendString:@"iCarousel (github/nicklockwood)\n"];
	[str appendString:@"JSONKit (github/johnezang)\n"];
  [str appendString:@"MBProgressHUD (github/matej)\n"];
	[str appendString:@"MKStoreKit (github/MugunthKumar)\n"];
	[str appendString:@"ShareKit (github/ShareKit)\n"];
	[str appendString:@"UsefulBits (github/kevinoneill)\n"];
  [str appendString:@"WebViewJavascriptBridge (github/marcuswestin)\n"];
  
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Acknowledgements"
													message:str
												   delegate:nil
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles:nil];
	[alert setTag:101];
	[alert show];
}

- (void)showEmailModalView;
{
  if (![MFMailComposeViewController canSendMail])
  {
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"No Mail Accounts" message:@"Please set up a Mail account in order to send email."];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    return;
  }
  
  ABMailComposer * picker = [[ABMailComposer alloc] init];
	picker.mailComposeDelegate = self;
  NSString *subject = [NSString stringWithFormat:@"%@ : %@ : iOS %@", [self appVersion], [UIDeviceHardware platformString], [[UIDevice currentDevice] systemVersion]];
	[picker setSubject:subject];
	[picker setToRecipients:[NSArray arrayWithObject:@"support@reddit.zendesk.com"]];
	[picker setMessageBody:@"" isHTML:NO];
	picker.navigationBar.barStyle = UIBarStyleDefault;
  if (picker)
  {
    [self presentModalViewController:picker animated:YES];
  }
}

- (void)openExternalWithAlertForUrl:(NSString *)url;
{
  UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"Do you want to launch this link outside of Alien Blue?" message:nil];
  [alert bk_setCancelButtonWithTitle:@"No" handler:nil];
  [alert bk_addButtonWithTitle:@"Yes" handler:^{
    [[UIApplication sharedApplication] openURL:[url URL]];
  }];
  [alert show];
}

- (void)showUpgradeHelpPage;
{
	BrowserViewController * browserView = [[BrowserViewController alloc] initWithUrl:@"http://alienblue.org/faq.html"];
  [browserView setNavbarTitle:@"Help"];
	[self.navigationController pushViewController:browserView animated:YES];
}

+ (void)toggleNightTheme;
{
  [UDefaults setBool:![UDefaults boolForKey:kABSettingKeyNightMode] forKey:kABSettingKeyNightMode];
  if (![UDefaults boolForKey:kABSettingKeyNightMode])
  {
    [ABWindow removeDim];
    [UDefaults setBool:NO forKey:kABSettingKeyLowContrastMode];
  }
  
  [UDefaults synchronize];
  [UIApplication ab_updateStatusBarTint];
  [[NSNotificationCenter defaultCenter] postNotificationName:kNightModeSwitchNotification object:nil];
}

- (void)didChoosePrimaryOptionAtIndexPath:(NSIndexPath *)indexPath;
{
  [self legacy_didChoosePrimaryOptionAtIndexPath:indexPath];
}

- (void)didChooseSecondaryOptionAtIndexPath:(NSIndexPath *)indexPath;
{
  [self legacy_didChooseSecondaryOptionAtIndexPath:indexPath];
}

- (void)switchAccountResponse:(id)sender;
{
  [self refreshTable];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
  return YES;
}

- (void)refreshTable;
{
  [super refreshTable];
  if (self.onTableReloadAction)
  {
    self.onTableReloadAction();
  }
}

- (void)exportSettingsToClipboard;
{
  NSMutableDictionary *defaultsDictionary = [NSMutableDictionary dictionaryWithDictionary:[UDefaults dictionaryRepresentation]];
  NSArray *settingsToInclude = @[
                                kABSettingKeyFilterList,
                                kABSettingKeyImgurUploadsList,
                                @"JMActionMenu",
                                @"subreddit_preferences",
                                kABSettingKeyNightMode,
                                ];
  
  [defaultsDictionary bk_performSelect:^BOOL(NSString *key, id obj) {
    return [settingsToInclude match:^BOOL(NSString *pattern) {
      return [key jm_contains:pattern];
    }] != nil;
  }];
  [defaultsDictionary setObject:@"ab-settings" forKey:@"ab-settings"];
  NSData *stateArchive = [NSKeyedArchiver archivedDataWithRootObject:defaultsDictionary];
  NSData *zippedArchive = [stateArchive zlibDeflate];
  
  [[UIPasteboard generalPasteboard] setData:zippedArchive forPasteboardType:@"ab-settings"];
  [defaultsDictionary.allKeys each:^(NSString *key) {
//    DLog(@"exporting key : %@", key);
  }];
  [PromptManager showMomentaryHudWithMessage:@"Exported to Clipboard" minShowTime:2];
}

- (void)importSettingsFromClipboard;
{
  BSELF(LegacySettingsTableViewController);
  UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Warning" message:@"This will override your existing Subreddit Groups, Filters and Imgur uploads. Are you sure you want to override your settings?"];
  [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [alertView bk_addButtonWithTitle:@"Override" handler:^{
    NSData *zippedArchive = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"ab-settings"];

    if (!zippedArchive)
    {
      [PromptManager showMomentaryHudWithMessage:@"Settings not found in clipboard" minShowTime:2];
      return;
    }
    
    NSData *stateArchive = [zippedArchive zlibInflate];
    if (!stateArchive)
    {
      [PromptManager showMomentaryHudWithMessage:@"Settings not found in clipboard" minShowTime:2];
      return;
    }
    
    NSDictionary *defaultsDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:stateArchive];
    
    if (![defaultsDictionary objectForKey:@"ab-settings"])
    {
      [PromptManager showMomentaryHudWithMessage:@"Settings not found in clipboard" minShowTime:2];
      return;
    }
    
    [defaultsDictionary.allKeys each:^(NSString *key) {
      [UDefaults setObject:[defaultsDictionary objectForKey:key] forKey:key];
    }];
    
    [PromptManager showMomentaryHudWithMessage:@"Settings are imported" minShowTime:2];
    [[NavigationManager shared] refreshUserSubreddits];
    [blockSelf postStyleChangeNotification];
  }];
  [alertView show];
//  UIPasteboard *sharedPasteboard = [UIPasteboard pasteboardWithName:@"alienblue-settings.sharedpasteboard" create:YES];
//  sharedPasteboard.persistent = YES;
//  [sharedPasteboard setData:zippedArchive forPasteboardType:@"ab-settings"];
//  [defaultsDictionary.allKeys each:^(NSString *key) {
//    DLog(@"exporting key : %@", key);
//  }];
  
}

@end
