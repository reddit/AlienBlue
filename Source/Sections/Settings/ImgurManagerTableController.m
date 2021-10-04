//  Copyright 2010 __MyCompanyName__. All rights reserved.

#import "ImgurManagerTableController.h"
#import "AlienBlueAppDelegate.h"
#import "PhotoProcessing.h"
#import "Resources.h"
#import "UIApplication+ABAdditions.h"
#import "RedditAPI+Imgur.h"
#import "MKStoreManager.h"

@implementation ImgurManagerTableController

- (void)dealloc
{
  [[RedditAPI shared] resetConnectionsForImgur];
}

- (id)initWithStyle:(UITableViewStyle)style
{
  if (self = [super initWithStyle:style])
  {
    [self jm_usePreIOS7ScrollBehavior];
  }
  return self;
}

- (void)drawPhotoSegment
{
  UIBarButtonItem *uploadItem = [UIBarButtonItem skinBarItemWithTitle:@"Upload" target:self action:@selector(showImagePicker)];
  self.navigationItem.rightBarButtonItem = uploadItem;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  if (popover)
  {
    [popover dismissPopoverAnimated:NO];
    [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2,self.tableView.contentOffset.y,10,10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  }
}

- (void)showCameraPicker
{
  REQUIRES_PRO;
  imagePickerController = [[UIImagePickerController alloc] init];
  imagePickerController.delegate = self;
  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[imagePickerController setAllowsImageEditing:[UDefaults boolForKey:kABSettingKeyCropImageUploads]];
	[self presentModalViewController:imagePickerController animated:YES];
}

- (void)showImagePicker
{
  REQUIRES_PRO;
  imagePickerController = [[UIImagePickerController alloc] init];
  imagePickerController.delegate = self;
	[imagePickerController setAllowsImageEditing:[UDefaults boolForKey:kABSettingKeyCropImageUploads]];
  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

  if ([Resources isIPAD])
  {
    popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
    [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2,self.tableView.contentOffset.y,10,10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
		
	NSMutableArray * imgurList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyImgurUploadsList]];
	[imgurList addObject:[NSDictionary dictionaryWithDictionary:imgurUpload]];
	[UDefaults setObject:imgurList forKey:kABSettingKeyImgurUploadsList];
	[UDefaults synchronize];
	
	[chosenPhotoView removeFromSuperview];
	[chosenPhotoView setAlpha:1.0];
	
	UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
	[chosenPhotoView setContentMode:UIViewContentModeScaleAspectFill];
	[chosenPhotoView setAlpha:1.0];
	[keyWindow addSubview:chosenPhotoView];
	[chosenPhotoView setFrame:[keyWindow frame]];
	[UIView beginAnimations:@"imageFade" context:nil];
	[UIView setAnimationDuration: 1.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	[chosenPhotoView setFrame:CGRectMake([keyWindow bounds].size.width / 2, [keyWindow bounds].size.height / 3, 0, 0)];
	[chosenPhotoView setAlpha:0.0];
	[UIView commitAnimations];
	
 	[[self tableView] reloadData];
	[[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([imgurList count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
	[PromptManager addPrompt:@"Please wait"];
	
	UIImage * img = [PhotoProcessing processPhotoFromInfo:info];
	[PromptManager addPrompt:@"Uploading to Imgur..."];
	if (img)
	{
		if (!chosenPhotoView)
    {
			chosenPhotoView = [[UIImageView alloc] init];
    }
		[chosenPhotoView setImage:img];
		[[RedditAPI shared] postImageToImgur:UIImageJPEGRepresentation(img,0.8) callBackTarget:self];
	}
  picker = nil;
  [UIApplication ab_updateStatusBarTint];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [UIApplication ab_updateStatusBarTint];
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)extraOptionsChosen:(id)sender
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	if ([segmentedControl selectedSegmentIndex] == 0)
	{
		[self showImagePicker];
	}
	else if ([segmentedControl selectedSegmentIndex] == 1)
	{
		[self showCameraPicker];
	}
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.tableView.backgroundColor = [UIColor colorForBackground];	
	
  [self setNavbarTitle:@"imgur"];
	[self drawPhotoSegment];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [[NavigationManager shared] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (![UDefaults objectForKey:kABSettingKeyImgurUploadsList])
		return 1;
	
	if ([[UDefaults objectForKey:kABSettingKeyImgurUploadsList] count] == 0)
		return 1;	
	
	return [[UDefaults objectForKey:kABSettingKeyImgurUploadsList] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 100;
}

- (UITableViewCell *)createNothingHereCell
{
	UITableViewCell * nCell = [[UITableViewCell alloc] init];
	UILabel * nothingHereLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 25, 230, 40)];
	[nothingHereLabel setTextAlignment:UITextAlignmentCenter];
	[nothingHereLabel setText:@"No images uploaded."];
	[nothingHereLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
	[nothingHereLabel setBackgroundColor:[UIColor colorForBackground]];
	[nothingHereLabel setTextColor:[UIColor colorForText]];
	[nothingHereLabel setFont:[UIFont systemFontOfSize:19]];
	[nCell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[nCell addSubview:nothingHereLabel];
	[nCell setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
  nCell.backgroundColor = [UIColor colorForBackground];
	return nCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (![UDefaults objectForKey:kABSettingKeyImgurUploadsList])
		return [self createNothingHereCell];
	
	if ([[UDefaults objectForKey:kABSettingKeyImgurUploadsList] count] == 0)
		return [self createNothingHereCell];	
    
  static NSString *CellIdentifier = @"ImgurCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

	for (UIView * subview in [cell.contentView subviews])
	{
		[subview removeFromSuperview];
	}		

	NSDictionary * imgurUpload = [[UDefaults objectForKey:kABSettingKeyImgurUploadsList] objectAtIndex:indexPath.row];

	if (!imgurUpload)
		return [self createNothingHereCell];

	UIImageView * thumbImg = [UIImageView new];
	[thumbImg setContentMode:UIViewContentModeLeft];
	[thumbImg setFrame:CGRectMake(5, 5, 90, 90)];
	[thumbImg setClipsToBounds:YES];
	[cell.contentView addSubview:thumbImg];
  NSURL *imageURL = [[imgurUpload valueForKey:@"small_thumbnail"] URL];
  [thumbImg jm_setRemoteImageWithURL:imageURL placeholder:nil decorator:nil onProgress:nil onComplete:nil onFailure:nil];
  thumbImg.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	
	UILabel * hash = [[UILabel alloc] initWithFrame:CGRectMake(115, 55, cell.contentView.size.width - 133, 30)];
	[hash setText:[imgurUpload valueForKey:@"original_image"]];
	[hash setTextAlignment:UITextAlignmentRight];
  [hash setTextColor:[UIColor colorForText]];
	[cell.contentView addSubview:hash];
	[hash setFont:[UIFont systemFontOfSize:12]];
  hash.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  hash.backgroundColor = [UIColor clearColor];
  
	UIButton * copyToClipboard = [UIButton buttonWithType:UIButtonTypeCustom];
	[copyToClipboard setImage:[UIImage imageNamed:@"copy-to-clipboard-icon.png"] forState:UIControlStateNormal];
	[copyToClipboard setFrame:CGRectMake(cell.contentView.size.width - 45, 15, 30, 30)];
	[copyToClipboard setTag:indexPath.row];
	[copyToClipboard addTarget:self action:@selector(copyToClipboard:) forControlEvents:UIControlEventTouchUpInside];
  copyToClipboard.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[cell.contentView addSubview:copyToClipboard];

	UIButton * removeAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];				
	[removeAccountButton setFrame:CGRectMake(cell.contentView.size.width - 100 ,16,25,25)];
	[removeAccountButton setBackgroundColor:[UIColor clearColor]];
	[removeAccountButton setBackgroundImage:[UIImage imageNamed:@"delete-icon.png"] forState:UIControlStateNormal];
	[removeAccountButton setTag:indexPath.row];
	[removeAccountButton addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
  removeAccountButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[cell.contentView addSubview:removeAccountButton];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
  cell.contentView.backgroundColor = [UIColor colorForBackground];
  cell.backgroundColor = [UIColor colorForBackground];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return NO;
}

- (void)removeImage:(id)sender
{
	if (![UDefaults objectForKey:kABSettingKeyImgurUploadsList])
		return;
	
	if ([[UDefaults objectForKey:kABSettingKeyImgurUploadsList] count] == 0)
		return;	
	
	UIButton *b = (UIButton *)sender;
	NSUInteger row = [b tag];
	
	NSMutableArray *imgurList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyImgurUploadsList]];
	NSDictionary *imgurUpload = [imgurList objectAtIndex:row];

	if (!imgurUpload)
		return;

	[[RedditAPI shared] removeImageFromImgurWithDeleteHash:[imgurUpload valueForKey:@"delete_hash"]];
	[PromptManager addPrompt:@"Deleted image from Imgur.com"];
	[imgurList removeObjectAtIndex:row];
	[UDefaults setObject:imgurList forKey:kABSettingKeyImgurUploadsList];
	[UDefaults synchronize];
	NSIndexPath * ip = [NSIndexPath indexPathForRow:row inSection:0];
	if (row > 0)
  {
		[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:YES];
  }
	[[self tableView] reloadData];
}

- (void)copyToClipboard:(id)sender;
{
	if (![UDefaults objectForKey:kABSettingKeyImgurUploadsList])
		return;
	
	if ([[UDefaults objectForKey:kABSettingKeyImgurUploadsList] count] == 0)
		return;	
	
	UIButton * b = (UIButton *) sender;
	NSUInteger row = [b tag];

	NSDictionary * imgurUpload = [[UDefaults objectForKey:kABSettingKeyImgurUploadsList] objectAtIndex:row];
	
	if (!imgurUpload)
		return;
	
	[[UIPasteboard generalPasteboard] setString:[imgurUpload valueForKey:@"original_image"]];
	[PromptManager addPrompt:@"Image URL copied to clipboard"];
}

@end
