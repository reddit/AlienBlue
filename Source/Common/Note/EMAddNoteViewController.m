//
//  AddNoteViewController.m
//  UITextView
//
//  Created by Ellen Miner on 3/7/09.
//  Copyright 2009 RaddOnline. All rights reserved.
//

#import "EMAddNoteViewController.h"
#import "Resources.h"
#import "AlienBlueAppDelegate.h"
#import "PhotoProcessing.h"
#import "ABBundleManager.h"
#import "RedditAPI+Imgur.h"
#import "NavigationManager+Deprecated.h"
#import "MKStoreManager.h"
#import "ViewContainerCell.h"
#import "JMOutlineViewController+CustomNavigationBar.h"

@interface EMAddNoteViewController()
@end

@implementation EMAddNoteViewController
@synthesize aNote;
@synthesize isSingleLineField;
@synthesize isNonAutocorrecting;
@synthesize isWebAddress;
@synthesize isSecure;
@synthesize	autoSaveKey;
@synthesize showPhotoTools;
@synthesize isModal;
@synthesize additionalNotes;

@synthesize actionSheet = actionSheet_;
@synthesize textView = textView_;
//@synthesize toolbarView = toolbarView_;
//@synthesize topShadowMask = topShadowMask_;
//@synthesize bottomShadowMask = bottomShadowMask_;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nil bundle:nil];
  if (self) 
	{
		NSNotificationCenter *notifc = [NSNotificationCenter defaultCenter];
		[notifc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
		[notifc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
  }
  return self;
}

//- (void)generateViewContainerNodes;
//{
//  ViewContainerNode *containerNode = [[ViewContainerNode alloc] initWithView:self.textView];
//  [self removeAllNodes];
//
//  [self addNode:containerNode];
//  [self reload];
//}

- (void)loadView
{
  [super loadView];
  
	self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0., 0., 320, 320.)];
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.textView.keyboardAppearance = JMIsNight() ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDefault;
  
  [self.tableView addSubview:self.textView];
//  [self generateViewContainerNodes];
	
//	self.toolbarView = [[NoteEntryToolbar alloc] initWithFrame:CGRectMake(0, 0, 320., 40.)];
//	[self.toolbarView sizeToFit];
//	self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//	self.toolbarView.alpha = 0.;
//	[self.view addSubview:self.toolbarView];
	
//	self.topShadowMask = [[UIImageView alloc] init];
//	self.topShadowMask.frame = CGRectMake(0, 4., 320., 10);
//	self.topShadowMask.autoresizingMask = UIViewAutoresizingFlexibleWidth;	
//	self.topShadowMask.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1., -1.);
//	[self.view addSubview:self.topShadowMask];
	
//	self.bottomShadowMask = [[UIImageView alloc] init];
//	self.bottomShadowMask.frame = CGRectMake(0, 4., 320., 10);
//	self.bottomShadowMask.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//	[self.view addSubview:self.bottomShadowMask];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
	[[NavigationManager shared] deprecated_exitFullscreenMode];

	self.view.backgroundColor = [UIColor colorForBackground];
	self.textView.textColor = [UIColor colorForText];
  self.textView.font = [UIFont skinFontWithName:kBundleFontPostTitleBold];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
  BSELF(EMAddNoteViewController);
  DO_AFTER_WAITING(0.5, ^{
    [blockSelf.textView becomeFirstResponder];
  });
}

- (CGFloat)manuallyAdjustedScreenHeightForDevice;
{
  CGFloat screenHeight = self.view.bounds.size.height;
  if ([Resources isIPAD])
  {
    screenHeight = JMLandscape() ? 706. : 770.;
    if (!JMIsIOS7())
    {
      screenHeight -= 40.;
    }
  }
  
//  if (JMIsIphone())
//  {
//    if (screenHeight == 416.)
//    {
//      screenHeight = 372.;
//    }
//    else if (screenHeight == 268.)
//    {
//      screenHeight = 238.;
//    }
//    if (JMIsIOS7())
//    {
//      screenHeight -= 40;
//    }
//  }
  return screenHeight;
}

- (void)resizeTextViewForKeyboardHeight:(CGFloat)keyboardHeight
{
  CGRect newFrame = CGRectZero;
  CGFloat screenHeight = [self manuallyAdjustedScreenHeightForDevice];
  CGFloat navbarHeight = self.attachedCustomNavigationBar != nil ? self.attachedCustomNavigationBar.defaultBarHeight : self.navigationController.navigationBar.frame.size.height;
  newFrame.size.height = screenHeight - navbarHeight - keyboardHeight - 8.;
  newFrame.size.width = self.view.bounds.size.width;
  self.textView.frame = CGRectInset(newFrame, 10., 0.);
}

- (void)redoLayoutForNewKeyboardFrame:(NSValue *)keyboardFrameValue;
{
	[UIView beginAnimations:nil context:nil];
	CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
	CGFloat keyboardHeight = keyboardFrame.size.height;

  [self resizeTextViewForKeyboardHeight:keyboardHeight];
	
//	CGRect toolbarFrame = self.toolbarView.frame;
//	toolbarFrame.origin.y = self.textView.frame.origin.y + self.textView.frame.size.height + 6.;
//	toolbarFrame.size.width = self.view.bounds.size.width;
//	self.toolbarView.frame = toolbarFrame;
	
//	CGRect bottomMaskFrame = self.bottomShadowMask.frame;
//	bottomMaskFrame.origin.y = toolbarFrame.origin.y - bottomMaskFrame.size.height;
//	self.bottomShadowMask.frame = bottomMaskFrame;

	[UIView setAnimationDuration:1.];
	[UIView commitAnimations];
}

- (void)moveToolbarForKeyboard:(NSNotification*)aNotification up:(BOOL)up;
{
	NSDictionary* userInfo = [aNotification userInfo];
	
	NSTimeInterval animationDuration;
	UIViewAnimationCurve animationCurve;
	CGRect keyboardEndFrame;
	
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

	if (&UIKeyboardFrameEndUserInfoKey)
  {
		[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
  }
	else
  {
		[[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardEndFrame];
  }
	
	CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];	
	NSValue * newKeyboardFrameValue = [NSValue valueWithCGRect:keyboardFrame];
	[self performSelector:@selector(redoLayoutForNewKeyboardFrame:) withObject:newKeyboardFrameValue afterDelay:1.0];
}

- (void)keyboardWillShow:(NSNotification *)aNotification 
{
  [self moveToolbarForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification *)aNotification 
{
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.textView resignFirstResponder];
//	self.toolbarView.alpha = 0.;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self.textView becomeFirstResponder];
}

- (void)cancel:(id)sender
{
	NSNotificationCenter *notifc = [NSNotificationCenter defaultCenter];
	[notifc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[notifc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
  if (isModal)
  {
    [[NavigationManager shared] dismissModalView];
  }
  else
  {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void)setCallBackTarget:(id)cbt withAction:(NSString *)act forResponseID:(int)rID
{
	callBackTarget = cbt;
	callBackAction = act;
	responseID = rID;
}

- (void)save:(id)sender
{
	NSNotificationCenter *notifc = [NSNotificationCenter defaultCenter];
	[notifc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[notifc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
	self.aNote = [self.textView text];
    
  if (self.onComplete)
  {
    self.onComplete(self.aNote);
  }
  else if (callBackTarget)
	{
		SEL action = NSSelectorFromString(callBackAction);
		NSMutableDictionary * entered = [NSMutableDictionary dictionaryWithCapacity:5];
		[entered setValue:self.aNote forKey:@"text"];
		[entered setValue:[NSNumber numberWithInt:responseID] forKey:@"responseID"];
		[callBackTarget performSelector:action withObject:entered];
	}
    	
  if (isModal)
  {
    [[NavigationManager shared] dismissModalView];
  }
  else
  {
    [self.navigationController popViewControllerAnimated:YES];
  }
}


- (void)initTextView
{
	[self.textView setContentMode:UIViewContentModeScaleToFill];
  [self.textView setBackgroundColor:[UIColor clearColor]];
	[self.textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	if (isNonAutocorrecting)
	{
		[self.textView setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self.textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	}
	else
	{
		[self.textView setAutocorrectionType:UITextAutocorrectionTypeYes];
		[self.textView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
	}
	
	if (isSingleLineField)
	{
		[self.textView setReturnKeyType:UIReturnKeyDone];
		[self.textView setEnablesReturnKeyAutomatically:NO];
	}
	
	if (isWebAddress)
	{
		[self.textView setKeyboardType:UIKeyboardTypeURL];
	}
	
	if (isSecure)
  {
		[self.textView setSecureTextEntry:YES];
  }
	else
  {
		[self.textView setSecureTextEntry:NO];
  }
	
	[self.textView setDelegate:self];
	[self.textView setFont:[UIFont skinFontForText]];
  
  [self resizeTextViewForKeyboardHeight:0.];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

	// provide a Save button to dismiss the keyboard
  UIBarButtonItem *saveItem = [UIBarButtonItem skinBarItemWithTitle:@"Save" target:self action:@selector(save:)];
  UIBarButtonItem *cancelItem = [UIBarButtonItem skinBarItemWithTitle:@"Cancel" target:self action:@selector(cancel:)];
  
	if (!isSingleLineField || [Resources isIPAD])
  {
		self.navigationItem.rightBarButtonItem = saveItem;
  }
  
	self.navigationItem.leftBarButtonItem = cancelItem;

	[self initTextView];

  if (additionalNotes && [additionalNotes length] > 0)
  {
//		[self.toolbarView addTextMessage:additionalNotes];
  }
	
	if (showPhotoTools)
	{	
//		[self.toolbarView addPhotoOptions];
	}

	self.textView.text = self.aNote;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
  if (chosenPhotoView)
  {
    [chosenPhotoView removeFromSuperview];
  }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([Resources isIPAD])
		return YES;
	
	return [[NavigationManager shared] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
  textView.keyboardAppearance = JMIsNight() ? UIKeyboardAppearanceAlert : UIKeyboardAppearanceDefault;
  return YES;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView
{
	[textView resignFirstResponder];
	return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  if ([text isEqualToString:@"\n"] && isSingleLineField)
  {
    [textView resignFirstResponder];
    [self save:nil];
    // Return FALSE so that the final '\n' character doesn't get added
    return FALSE;
  }
	else if ([text isEqualToString:@"\n"] && autoSaveKey && [autoSaveKey length] > 0)
	{
		[UDefaults setValue:[textView text] forKey:autoSaveKey];
		[UDefaults synchronize];
	}
  return TRUE;
}

- (void)showCameraPicker:(id)sender
{
  REQUIRES_PRO;
  if (self.textView)
  {
    [self.textView resignFirstResponder];
  }
  
  imagePickerController = [[UIImagePickerController alloc] init];
  imagePickerController.delegate = self;
  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[imagePickerController setAllowsImageEditing:[UDefaults boolForKey:kABSettingKeyCropImageUploads]];
	[self presentModalViewController:imagePickerController animated:YES];
}

- (void)showImagePicker:(id)sender
{
	if (![MKStoreManager isProUpgraded])
	{
		[MKStoreManager needProAlert];
		return;
	}

  if (self.textView)
  {
    [self.textView resignFirstResponder];
  }
	
  imagePickerController = [[UIImagePickerController alloc] init];
  imagePickerController.delegate = self;
	[imagePickerController setAllowsImageEditing:[UDefaults boolForKey:kABSettingKeyCropImageUploads]];
  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  if ([Resources isIPAD])
  {
    popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
    [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2,0,10,10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  }
  else
  {
    [self presentModalViewController:imagePickerController animated:YES];
  }
}

- (void)imageUploadResponse:(id)sender
{
	if (!chosenPhotoView || ![chosenPhotoView image])
		return;

	NSDictionary * imgurUpload = (NSDictionary *) sender;
	if (!imgurUpload)
		return;
  
	[PromptManager addPrompt:@"Image has been uploaded"];
	
	NSString * imageURL = [imgurUpload valueForKey:@"original_image"];
	NSMutableArray * imgurList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyImgurUploadsList]];
	[imgurList addObject:[NSDictionary dictionaryWithDictionary:imgurUpload]];
	[UDefaults setObject:imgurList forKey:kABSettingKeyImgurUploadsList];
	[UDefaults synchronize];

	self.aNote = [[self.textView text] stringByAppendingString:imageURL];
	[self.textView setText:self.aNote];
	
	// Good time to auto-save...
	if (autoSaveKey && [autoSaveKey length] > 0)
	{
		[UDefaults setValue:self.aNote forKey:autoSaveKey];
		[UDefaults synchronize];
	}
	
	[chosenPhotoView removeFromSuperview];
	[chosenPhotoView setAlpha:1.0];

	UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
	[chosenPhotoView setContentMode:UIViewContentModeScaleAspectFill];
	[chosenPhotoView setAlpha:1.0];

	[chosenPhotoView setFrame:[keyWindow frame]];
	[UIView beginAnimations:@"imageFade" context:nil];
	[UIView setAnimationDuration: 1.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	[chosenPhotoView setFrame:CGRectMake([keyWindow bounds].size.width / 2, [keyWindow bounds].size.height / 3, 0, 0)];
	[chosenPhotoView setAlpha:0.0];

	[keyWindow addSubview:chosenPhotoView];	
  [UIView commitAnimations];

	[self.textView becomeFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[PromptManager addPrompt:@"Processing your photo..."];

  [picker dismissModalViewControllerAnimated:YES];
  if ([Resources isIPAD] && popover)
  {
    [popover dismissPopoverAnimated:YES];
    popover = nil;
  }

	UIImage *img = [PhotoProcessing processPhotoFromInfo:info];
	if (img)
	{
		if (!chosenPhotoView)
    {
			chosenPhotoView = [[UIImageView alloc] init];
    }
		[chosenPhotoView setImage:img];
		[PromptManager addPrompt:@"Uploading to Imgur..."];
		[[RedditAPI shared] postImageToImgur:UIImageJPEGRepresentation(img,0.9) callBackTarget:self];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
	[self.textView becomeFirstResponder];
}

#pragma mark Add Photo - Action Sheet

- (void)showAddPhotoActionSheet:(id)sender;
{	
	if ([Resources isIPAD] && self.actionSheet && self.actionSheet.visible)
  {
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    return;
  }

	self.actionSheet = [[UIActionSheet alloc]
                  initWithTitle:@"Add Photo"
                  delegate:self
                  cancelButtonTitle:nil
                  destructiveButtonTitle:nil
                  otherButtonTitles:
                  nil];

	[self.actionSheet addButtonWithTitle:@"From Photo Library"];

	BOOL camAvail = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];	
	if (camAvail)
	{
		[self.actionSheet addButtonWithTitle:@"From Camera"];
	}
	
	[self.actionSheet addButtonWithTitle:@"Cancel"];
	[self.actionSheet setCancelButtonIndex:[self.actionSheet numberOfButtons] - 1];
	[self.actionSheet setTag:0];
    
	if ([Resources isIPAD] && sender)
  {
		if ([sender isKindOfClass:[UIBarButtonItem class]])
		{
			actionSheetBarItem_ = sender;
			[self.actionSheet showFromBarButtonItem:actionSheetBarItem_ animated:YES];
		}
  }
	else
  {
    self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[self.actionSheet jm_showInView:self.navigationController.view];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == [actionSheet numberOfButtons] - 1)
		return;
  
  if (actionSheet.tag != 0)
    return;
	
  if (buttonIndex == 0)
  {
    [self showImagePicker:nil];
  }
  else if (buttonIndex == 1)
  {
    [self showCameraPicker:nil];
  }
}

#pragma mark UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
}

- (void)viewDidUnload 
{
	[self.textView resignFirstResponder];
  [super viewDidUnload];
}

- (void)dealloc
{
	NSNotificationCenter *notifc = [NSNotificationCenter defaultCenter];
	[notifc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[notifc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  [[RedditAPI shared] resetConnectionsForImgur];
}

@end
