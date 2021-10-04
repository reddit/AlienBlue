#import "CommentEntryCoordinator.h"
#import "PhotoProcessing.h"
#import "Resources.h"
#import "SessionManager+Authentication.h"
#import "RedditAPI+Imgur.h"
#import "MKStoreManager.h"
#import "ImgurUploadRecord.h"

@interface CommentEntryCoordinator()
- (void)showDiscardActionSheet;
- (void)closeCommentView;
- (void)saveComment;
@end

@implementation CommentEntryCoordinator

@synthesize cTextView = cTextView_;
@synthesize parentCommentTextView = parentCommentTextView_;
@synthesize parentComment = parentComment_;
@synthesize parentCommentUsername = parentCommentUsername_;
@synthesize myComment = myComment_;
@synthesize isEditing = isEditing_;
@synthesize isForMessage = isForMessage_;
@synthesize responseID = responseID_;
@synthesize parentCommentUsernameLabel = parentCommentUsernameLabel_;
@synthesize callbackViewController = callbackViewController_;
@synthesize myUsernameLabel = myUsernameLabel_;
@synthesize respondingLabel = respondingLabel_;
@synthesize editingLabel = editingLabel_;
@synthesize commentEntryViewController = commentEntryViewController_;

- (void)dealloc
{
	if (cTextView_)
  {
		cTextView_.delegate = nil;
  }

  [[RedditAPI shared] resetConnectionsForImgur];

	NSNotificationCenter *notifc = [NSNotificationCenter defaultCenter];
	[notifc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[notifc removeObserver:self name:UIKeyboardWillHideNotification object:nil];

  self.callbackViewController = nil;
  self.commentEntryViewController = nil;
}

- (id)init
{
  if ((self = [super init]))
  {
    attachToView_ = [Resources isIPAD] ? [NavigationManager mainView] : [[NavigationManager shared].postsNavigation modalViewController].view;
    if (!attachToView_)
    {
      attachToView_ = [NavigationManager mainView];
    }
  }
  return self;
}

- (void)initValues
{
	[cTextView_ setText:self.myComment];
	[parentCommentTextView_ setText:parentComment_];
  [parentCommentUsernameLabel_ setText:parentCommentUsername_];
  [myUsernameLabel_ setText:[UDefaults objectForKey:@"username"]];

	if (parentComment_ && [parentComment_ length] > 5)
	{
		parentParagraphs_ = [[NSMutableArray alloc] init];
		NSMutableString * pc = [NSMutableString stringWithString:parentComment_];
		[pc replaceOccurrencesOfString:@"\n\n\n" withString:@"\n\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [pc length])];
		[pc replaceOccurrencesOfString:@"\n\n" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [pc length])];
		NSArray *paragraphs = [pc componentsSeparatedByString: @"\n"];
		for (NSString * paragraph in paragraphs)
		{
			if (paragraph && [paragraph length] > 5)
      {
				[parentParagraphs_ addObject:paragraph];
      }
		}
	}

  if (isEditing_)
  {
    respondingLabel_.hidden = YES;
    editingLabel_.hidden = NO;
    parentCommentUsernameLabel_.hidden = YES;
  }

  [SessionManager manager].switchBackToAccountUsername = [UDefaults objectForKey:@"username"];
  [SessionManager manager].shouldSwitchBackToMainAccountAfterPosting = YES;
}

- (void)cancelComment:(id)sender;
{
	[cTextView_ resignFirstResponder];
  
  if ([[cTextView_ text] length] > 0)
  {
      [self showDiscardActionSheet];
  }
  else
  {
      [self closeCommentView];
  }
}

#pragma mark Duplicates from CommentEntryBar (need to refactor to avoid code duplication)

- (void)closeCommentView
{
	SEL action = NSSelectorFromString(@"commentExited:");
	NSMutableDictionary * entered = [NSMutableDictionary dictionaryWithCapacity:0];
	[entered setValue:[NSNumber numberWithInt:responseID_] forKey:@"responseID"];
	if (callbackViewController_)
  {
		[callbackViewController_ performSelector:action withObject:entered];
  }
}

- (void)showCameraPicker
{
	if (![MKStoreManager isProUpgraded])
	{
		[MKStoreManager needProAlert];
		return;
	}

  imagePickerController_ = [[UIImagePickerController alloc] init];
  imagePickerController_.delegate = self;
  imagePickerController_.sourceType = UIImagePickerControllerSourceTypeCamera;
	[imagePickerController_ setAllowsImageEditing:[UDefaults boolForKey:kABSettingKeyCropImageUploads]];
  if ([Resources isIPAD])
  {
    popover_ = [[UIPopoverController alloc] initWithContentViewController:imagePickerController_];
    [popover_ presentPopoverFromRect:CGRectMake(commentEntryViewController_.view.bounds.size.width / 2,0,10,10) inView:commentEntryViewController_.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  }
  else
  {
    [commentEntryViewController_ presentModalViewController:imagePickerController_ animated:YES];
  }
}

- (void)showImagePicker
{
	if (![MKStoreManager isProUpgraded])
	{
		[MKStoreManager needProAlert];
		return;
	}

  imagePickerController_ = [[UIImagePickerController alloc] init];
  imagePickerController_.delegate = self;
	[imagePickerController_ setAllowsImageEditing:[UDefaults boolForKey:kABSettingKeyCropImageUploads]];
  imagePickerController_.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  if ([Resources isIPAD])
  {
    popover_ = [[UIPopoverController alloc] initWithContentViewController:imagePickerController_];
    [popover_ presentPopoverFromRect:CGRectMake(commentEntryViewController_.view.bounds.size.width / 2,0,10,10) inView:commentEntryViewController_.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  }
  else
  {
    [commentEntryViewController_ presentModalViewController:imagePickerController_ animated:YES];
  }
}

- (void)didFinishUploadingImgurWithImageUrl:(NSString *)imageUrl;
{
  self.myComment = [[cTextView_ text] stringByAppendingString:imageUrl];
  [cTextView_ setText:self.myComment];
  [self saveComment];
}

- (void)imageUploadResponse:(id)sender
{
	if (!chosenPhotoView_ || ![chosenPhotoView_ image])
		return;

	NSDictionary *imgurUpload = (NSDictionary *)sender;
	if (!imgurUpload)
		return;
  
	[PromptManager addPrompt:@"Image has been uploaded"];

  NSString *imageURL = [ImgurUploadRecord originalImageUrlFromImgurResponseDictionary:imgurUpload];
  [ImgurUploadRecord storeUploadRecordWithImgurResponseDictionary:imgurUpload];

	self.myComment = [[cTextView_ text] stringByAppendingString:imageURL];
	[cTextView_ setText:self.myComment];
	[self saveComment];

	[chosenPhotoView_ removeFromSuperview];
	[chosenPhotoView_ setAlpha:1.0];

	UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
	[chosenPhotoView_ setContentMode:UIViewContentModeScaleAspectFill];
	[chosenPhotoView_ setAlpha:1.0];
	[keyWindow addSubview:chosenPhotoView_];
	[chosenPhotoView_ setFrame:[keyWindow frame]];
	[UIView beginAnimations:@"imageFade" context:nil];
	[UIView setAnimationDuration: 1.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	[chosenPhotoView_ setFrame:CGRectMake([keyWindow bounds].size.width / 2, [keyWindow bounds].size.height / 3, 0, 0)];
	[chosenPhotoView_ setAlpha:0.0];
	[UIView commitAnimations];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[PromptManager addPrompt:@"Processing your photo..."];
	[picker dismissModalViewControllerAnimated:YES];
  if ([Resources isIPAD] && popover_)
  {
    [popover_ dismissPopoverAnimated:YES];
    popover_ = nil;
  }
  
  if (JMIsIphone() && JMIsIOS7())
  {
    [UIApplication sharedApplication].statusBarHidden = YES;
  }

	UIImage * img = [PhotoProcessing processPhotoFromInfo:info];
	if (img)
	{
		if (!chosenPhotoView_)
    {
			chosenPhotoView_ = [[UIImageView alloc] init];
    }
		[chosenPhotoView_ setImage:img];
		[[RedditAPI shared] postImageToImgur:UIImageJPEGRepresentation(img,0.8) callBackTarget:self];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}

#define SHEET_MAIN 0
#define SHEET_ACCOUNT_SWITCH 1
#define SHEET_ACCOUNT_SWITCH_AUTOBACK 2
#define SHEET_ADD_PHOTO 3
#define SHEET_QUOTE 4
#define SHEET_DISCARD 5

#define SHEET_OPTION_INSERT_QUOTE 0
#define SHEET_OPTION_ADD_PHOTO 1
#define SHEET_OPTION_SWITCH_ACCOUNTS 2
#define SHEET_OPTION_SAVE 3
#define SHEET_OPTION_LOAD 4
#define SHEET_OPTION_DISCARD 5
#define SHEET_OPTION_HIDE_OPTIONS 6

- (void)showMainOptionsActionSheet:(id)sender
{
	NSString * title = [NSString stringWithFormat:@"Commenting from account: %@", [UDefaults valueForKey:@"username"]];

	if ([Resources isIPAD] && mainOptionsPopupQuery_ && mainOptionsPopupQuery_.visible)
  {
    [mainOptionsPopupQuery_ dismissWithClickedButtonIndex:0 animated:YES];
    return;
  }

	mainOptionsPopupQuery_ = [[UIActionSheet alloc]
								 initWithTitle:title
								 delegate:self
								 cancelButtonTitle:nil
								 destructiveButtonTitle:nil
								 otherButtonTitles:
								 nil];

	if (parentParagraphs_ && [parentParagraphs_ count] > 0)
	{
		[mainOptionsPopupQuery_ addButtonWithTitle:[NSString stringWithFormat:@"Quote %@", parentCommentUsername_]];
	}

	[mainOptionsPopupQuery_ addButtonWithTitle:@"Add Photo"];
	[mainOptionsPopupQuery_ addButtonWithTitle:@"Switch Accounts"];
	[mainOptionsPopupQuery_ addButtonWithTitle:@"Save"];
	[mainOptionsPopupQuery_ addButtonWithTitle:@"Load from Saved"];
	[mainOptionsPopupQuery_ addButtonWithTitle:@"Cancel Comment"];
	[mainOptionsPopupQuery_ addButtonWithTitle:@"Hide Options"];
	[mainOptionsPopupQuery_ setTag:SHEET_MAIN];

  if (parentParagraphs_ && [parentParagraphs_ count] > 0)
  {
		[mainOptionsPopupQuery_ setCancelButtonIndex:6];
  }
  else
  {
    [mainOptionsPopupQuery_ setCancelButtonIndex:5];
  }
 
  [mainOptionsPopupQuery_ jm_showInView:attachToView_];
}

- (void)showQuoteActionSheet
{
	NSString *title;
	if (![MKStoreManager isProUpgraded])
  {
		title = @"(PRO) Choose paragraph to quote...";
  }
	else
  {
		title = @"Choose paragraph to quote...";
  }

	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:title
								 delegate:self
								 cancelButtonTitle:nil
								 destructiveButtonTitle:nil
								 otherButtonTitles:
								 nil];

  [popupQuery setTag:SHEET_QUOTE];

  for (NSString * paragraph in parentParagraphs_)
  {
		[popupQuery addButtonWithTitle:paragraph];
  }

	[popupQuery addButtonWithTitle:@"Cancel"];
	[popupQuery setCancelButtonIndex:[parentParagraphs_ count]];
	popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
	[popupQuery jm_showInView:attachToView_];
}

- (void)showSwitchAccountActionSheet
{
	NSString *title = @"Switch to another reddit / novelty account:";
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:title
								 delegate:self
								 cancelButtonTitle:nil
								 destructiveButtonTitle:nil
								 otherButtonTitles:
								 nil];
	[popupQuery setTag:SHEET_ACCOUNT_SWITCH];

	if (isEditing_)
	{
		[popupQuery addButtonWithTitle:[UDefaults valueForKey:@"username"]];
		[popupQuery setCancelButtonIndex:1];
	}
	else
  {
    for (NSDictionary * userPass in [UDefaults objectForKey:kABSettingKeyRedditAccountsList])
    {
      [popupQuery addButtonWithTitle:[userPass valueForKey:@"username"]];
    }
    [popupQuery setCancelButtonIndex:[[UDefaults objectForKey:kABSettingKeyRedditAccountsList] count]];
	}

	[popupQuery addButtonWithTitle:@"Cancel"];
	popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
	[popupQuery jm_showInView:attachToView_];
}

- (void)showSwitchAccountAutoBackActionSheet
{
	NSString *title = @"After commenting...";
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:title
								 delegate:self
								 cancelButtonTitle:nil
								 destructiveButtonTitle:nil
								 otherButtonTitles:
								 nil];
  
	[popupQuery setTag:SHEET_ACCOUNT_SWITCH_AUTOBACK];

	[popupQuery addButtonWithTitle:[NSString stringWithFormat:@"Switch back to %@.", [SessionManager manager].switchBackToAccountUsername]];
	[popupQuery addButtonWithTitle:[NSString stringWithFormat:@"Leave %@ logged in.", [UDefaults valueForKey:@"username"]]];
	popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
	[popupQuery jm_showInView:attachToView_];
}

- (void)showDiscardActionSheet
{
	NSString *title = @"Would you like Alien Blue to save your comment for later?";
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:title
								 delegate:self
								 cancelButtonTitle:nil
								 destructiveButtonTitle:nil
								 otherButtonTitles:
								 nil];
	[popupQuery setTag:SHEET_DISCARD];

  [popupQuery addButtonWithTitle:@"Save for later"];
	if (isEditing_)
  {
		[popupQuery addButtonWithTitle:@"Discard changes"];
  }
	else
  {
		[popupQuery addButtonWithTitle:@"Discard my comment"];
  }
	[popupQuery addButtonWithTitle:@"Cancel"];
  
	[popupQuery setCancelButtonIndex:2];
	popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
	[popupQuery jm_showInView:attachToView_];
}

- (void)showAddPhotoActionSheet
{
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:nil
								 delegate:self
								 cancelButtonTitle:nil
								 destructiveButtonTitle:nil
								 otherButtonTitles:
								 nil];
  
	[popupQuery setTag:SHEET_ADD_PHOTO];
	[popupQuery addButtonWithTitle:@"From Photo Library"];

	BOOL camAvail = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	if (camAvail)
	{
		[popupQuery addButtonWithTitle:@"Take a Photo"];
		[popupQuery setCancelButtonIndex:2];
	}
	else
  {
		[popupQuery setCancelButtonIndex:1];
	}

	[popupQuery addButtonWithTitle:@"Cancel"];
	popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
	[popupQuery jm_showInView:attachToView_];
}

- (void)loadComment
{
	self.myComment = [UDefaults valueForKey:@"autosave_comment_text"];
	[cTextView_ setText:self.myComment];
}

- (void)saveComment;
{
	[UDefaults setValue:[cTextView_ text] forKey:@"autosave_comment_text"];
	[UDefaults synchronize];
}

- (void)submitCommentToController:(id)sender
{
	self.myComment = [cTextView_ text];
	[self saveComment];

	SEL action = NSSelectorFromString(@"commentEntered:");
	NSMutableDictionary * entered = [NSMutableDictionary dictionaryWithCapacity:0];
	[entered setValue:[NSString stringWithString:self.myComment] forKey:@"text"];
	[entered setValue:[NSNumber numberWithInt:responseID_] forKey:@"responseID"];
	if (callbackViewController_)
  {
		[callbackViewController_ performSelector:action withObject:entered];
  }
}


- (void)displayProRequiredMessage
{
  NSString *message = [[NSString alloc] initWithFormat: @"To use this feature, please upgrade to the PRO version in the \"Settings\" panel."];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"One Tap Quoting\n(PRO Feature)"
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
  [alert show];
}

- (void)appendQuotedTextAtButtonIndex:(NSInteger)buttonIndex
{
  if (![MKStoreManager isProUpgraded])
  {
    [self displayProRequiredMessage];
    return;
  }
  
  [cTextView_ becomeFirstResponder];
  NSMutableString * quote = [NSMutableString stringWithString:@"\n>"];
  [quote appendString:[parentParagraphs_ objectAtIndex:buttonIndex]];
  [quote appendString:@"\n\n"];
  cTextView_.text = [cTextView_.text stringByAppendingString:quote];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch ([actionSheet tag])
  {
		case SHEET_MAIN:
			// if there is no parent comment, then we need to shift the button indexes up
			// as the "Insert Quote" option will not be available
			if (!parentParagraphs_ || [parentParagraphs_ count] == 0)
				buttonIndex++;
			if (buttonIndex == SHEET_OPTION_INSERT_QUOTE)
				[self showQuoteActionSheet];
			if (buttonIndex == SHEET_OPTION_SWITCH_ACCOUNTS)
				[self showSwitchAccountActionSheet];
			if (buttonIndex == SHEET_OPTION_DISCARD)
			{
				if ([[cTextView_ text] length] > 0)
					[self showDiscardActionSheet];
				else {
					[self closeCommentView];
				}
			}
			if (buttonIndex == SHEET_OPTION_SAVE)
				[self saveComment];
			if (buttonIndex == SHEET_OPTION_LOAD)
				[self loadComment];
			if (buttonIndex == SHEET_OPTION_ADD_PHOTO)
      {
        if (self.onAddPhotoTap)
        {
          self.onAddPhotoTap();
        }
//				[self showAddPhotoActionSheet];
      }
      if (buttonIndex == SHEET_OPTION_HIDE_OPTIONS)
      {
        [self.cTextView becomeFirstResponder];
      }
			break;
		case SHEET_ADD_PHOTO:
			if (buttonIndex == 0)
				[self showImagePicker];
			else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
				[self showCameraPicker];
			break;
		case SHEET_QUOTE:
			if (buttonIndex < [parentParagraphs_ count])
			{
        [self appendQuotedTextAtButtonIndex:buttonIndex];
			}
			break;
		case SHEET_ACCOUNT_SWITCH:
			if (isEditing_)
				return;
			if (buttonIndex < [(NSMutableArray *) [UDefaults objectForKey:kABSettingKeyRedditAccountsList] count])
			{
        [[SessionManager manager] switchToRedditAccountAtIndex:buttonIndex withCallBackTarget:self];
				[self showSwitchAccountAutoBackActionSheet];
			}
			break;
		case SHEET_ACCOUNT_SWITCH_AUTOBACK:
			if (buttonIndex == 0)
        [SessionManager manager].shouldSwitchBackToMainAccountAfterPosting = YES;
			else if (buttonIndex == 1)
        [SessionManager manager].shouldSwitchBackToMainAccountAfterPosting = NO;
			break;
		case SHEET_DISCARD:
			if (buttonIndex == 0)
			{
				[self saveComment];
				[self closeCommentView];
			}
			else if (buttonIndex == 1)
			{
				[self closeCommentView];
			}
			break;
		default:
			break;
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	// auto save when the user enters a new newline character.  This should hopefully
	// protect from time lost if the app crashed or the user gets a phone call.
	if ([text isEqualToString:@"\n"])
	{
		[self saveComment];
	}
  return TRUE;
}

- (void)switchAccountResponse:(id)sender
{
  [myUsernameLabel_ setText:[UDefaults objectForKey:@"username"]];
}

@end