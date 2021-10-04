#import "BrowserViewController+Legacy.h"
#import "Resources.h"
#import "ABMailComposer.h"
#import <MessageUI/MessageUI.h>
#import "RedditAPI+ElementInteraction.h"
#import "RedditAPI+Account.h"
#import "NavigationManager+Deprecated.h"
#import "JMSiteMedia.h"
#import "UIActionSheet+JMAdditions.h"
#import "LinkShareCoordinator.h"

@interface BrowserViewController (Legacy_) <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (strong) UIActionSheet *popupQuery;
@property (weak) UIBarButtonItem *popupOptionsBarItem;
@end

@implementation BrowserViewController (Legacy)

SYNTHESIZE_ASSOCIATED_STRONG(UIActionSheet, popupQuery, PopupQuery);
SYNTHESIZE_ASSOCIATED_WEAK(UIBarButtonItem, popupOptionsBarItem, PopupOptionsBarItem);

- (NSMutableDictionary *)postDictionary;
{
  return [NavigationManager shared].deprecated_legacyPostDictionary;
}

- (void)saveImageToPhotoLibrary;
{
  BSELF(BrowserViewController);
  [PromptManager addPrompt:@"Saving image ..."];
  [JMSiteMedia deeplinkedImageURLForLinkURL:self.currentURL.URL onComplete:^(NSURL *deepURL) {
    NSData *imageData = [NSData dataWithContentsOfURL:deepURL];
    UIImage *theImage = [UIImage imageWithData:imageData];
    UIImageWriteToSavedPhotosAlbum(theImage, blockSelf, nil, nil);
    [PromptManager addPrompt:@"Saved"];
  } onFailure:^{
    [PromptManager addPrompt:@"Save Failed"];
  }];
}

- (void)dismissLegacyExtraOptionsActionSheet;
{
  if (JMIsIpad() && self.popupQuery && self.popupQuery.visible)
  {
    [self.popupQuery dismissWithClickedButtonIndex:0 animated:YES];
  }
}

- (void)showLegacyExtraOptionsActionSheet:(id)sender;
{
	if ([Resources isIPAD] && self.popupQuery && self.popupQuery.visible)
  {
    [self.popupQuery dismissWithClickedButtonIndex:0 animated:YES];
    return;
  }
  
	self.popupQuery = [[UIActionSheet alloc]
                initWithTitle:nil
                delegate:self
                cancelButtonTitle:nil
                destructiveButtonTitle:nil
                otherButtonTitles:
                @"Open in Safari",
                @"Send To ...",
                nil];
	  
	NSMutableDictionary * ps = [self postDictionary];
  
  // for post links, we can give an option to save
  if (ps && !self.shouldHideVoteIcons && [ps isKindOfClass:[NSDictionary class]])
  {
    if ([[ps valueForKey:@"saved"] boolValue])
      [self.popupQuery addButtonWithTitle:@"Un-Save from Reddit"];
    else
      [self.popupQuery addButtonWithTitle:@"Save to Reddit"];
  }
  
  if ([self isImageLink:self.currentURL])
    [self.popupQuery addButtonWithTitle:@"Save to Photos"];
  
	[self.popupQuery addButtonWithTitle:@"Cancel"];
	[self.popupQuery setCancelButtonIndex:self.popupQuery.numberOfButtons - 1];
  
	if ([Resources isIPAD])
  {
    self.popupOptionsBarItem = sender;
    [self.popupQuery jm_showFromBarButtonItem:sender animated:YES];
  }
	else
  {
    [self.popupQuery setBackgroundColor:[UIColor blackColor]];
    self.popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [self.popupQuery jm_showInView:self.navigationController.view];
  }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 5 && buttonIndex == 1)
	{
    //	NSLog(@"launch safari in()");
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentURL]];
	}
  
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  [[NavigationManager mainViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void) showEmailModalView {
	
  NavigationManager *nc = [NavigationManager shared];
	ABMailComposer *picker = [[ABMailComposer alloc] init];
	picker.mailComposeDelegate = self;
	if (nc.deprecated_legacyPostDictionary && [nc.deprecated_legacyPostDictionary isKindOfClass:[NSDictionary class]] && [nc.deprecated_legacyPostDictionary objectForKey:@"title"])
		[picker setSubject:[nc.deprecated_legacyPostDictionary valueForKey:@"title"]];
	else
		[picker setSubject:@""];
	
	[picker setMessageBody:self.currentURL isHTML:NO];
	
	picker.navigationBar.barStyle = UIBarStyleDefault;
  if (picker)
  {
    [[NavigationManager mainViewController] presentViewController:picker animated:YES completion:nil];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
  NavigationManager *nc = [NavigationManager shared];
  
  if (actionSheet.cancelButtonIndex == buttonIndex)
    return;
	
  if (buttonIndex == 0)
	{
		//	NSLog(@"launch safari in()");
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentURL]];
	}
	else if (buttonIndex == 1)
	{
    [self showShareOptions];
	}
  else if (buttonIndex == 2)
  {
    if (nc.deprecated_legacyPostDictionary && !self.shouldHideVoteIcons)
      [self toggleSavePost:nc.deprecated_legacyPostDictionary];
    else if ([self isImageLink:self.currentURL])
      [self saveImageToPhotoLibrary];
  }
  else if (buttonIndex == 3 && [self isImageLink:self.currentURL])
  {
    [self saveImageToPhotoLibrary];
  }
}

- (void) toggleSavePost:(NSMutableDictionary *) ps
{
  REQUIRES_REDDIT_AUTHENTICATION;
  
  RedditAPI *redAPI = [RedditAPI shared];
  
  // paranoia is a good thing
  if (!ps || self.shouldHideVoteIcons)
    return;
  
	if ([[ps valueForKey:@"saved"] boolValue])
	{
		[redAPI unsavePostWithID:[ps valueForKey:@"name"]];
		[ps setValue:[NSNumber numberWithBool:NO] forKey:@"saved"];
	}
	else
	{
		[redAPI savePostWithID:[ps valueForKey:@"name"]];
		[ps setValue:[NSNumber numberWithBool:YES] forKey:@"saved"];
	}
}

- (BOOL)isImageLink:(NSString *)link;
{
  BOOL containsDirectImageExtension = ([link rangeOfString:@".png" options:NSCaseInsensitiveSearch].location != NSNotFound	||
                                       [link rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound	||
                                       [link rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound );
  
  BOOL containsAlbumUrlPattern = [link rangeOfString:@"imgur.com/a/" options:NSCaseInsensitiveSearch].location != NSNotFound || [link rangeOfString:@"imgur.com/gallery/" options:NSCaseInsensitiveSearch].location != NSNotFound;
  
  BOOL isDeeplinkable = [JMSiteMedia hasDeeplinkedImageForURL:link.URL];
  return (containsDirectImageExtension || isDeeplinkable) && !containsAlbumUrlPattern;
}

- (void)showShareOptions;
{
  NSString *title = @"";
  NSDictionary *legacyDictionary = [NavigationManager shared].deprecated_legacyPostDictionary;
  if (legacyDictionary && [legacyDictionary isKindOfClass:[NSDictionary class]] && [legacyDictionary objectForKey:@"title"])
  {
    title = [legacyDictionary valueForKey:@"title"];
  }
  
  [LinkShareCoordinator presentLinkShareSheetFromViewController:self barButtonItemOrNil:self.popupOptionsBarItem withAddress:self.currentURL title:title];
}

@end
