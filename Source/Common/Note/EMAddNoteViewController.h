//
//  AddNoteViewController.h
//  UITextView
//
//  Created by Ellen Miner on 3/7/09.
//  Copyright 2009 RaddOnline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationManager.h"
#import "NoteEntryToolbar.h"
#import "AlienBlueAppDelegate.h"
#import "ABOutlineViewController.h"

typedef void (^NoteCompleteAction)(NSString *enteredText);

@interface EMAddNoteViewController : ABOutlineViewController <UIActionSheetDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	NSString *aNote;
	id callBackTarget;
	NSString *callBackAction;
	NSString *autoSaveKey;
	UIImagePickerController *imagePickerController;
	UIImageView *chosenPhotoView;
	
	BOOL isModal;
	int responseID;
	BOOL isSingleLineField;
	BOOL isWebAddress;
	BOOL isNonAutocorrecting;	
	BOOL isSecure;	
	BOOL showPhotoTools;
	
  UIPopoverController *popover;
  NSString *additionalNotes;
  UIButton *imageButton;
  UIButton *cameraButton;
	
  UIActionSheet *actionSheet_;
  UIBarButtonItem *actionSheetBarItem_;
	
	UITextView * textView_;
//	NoteEntryToolbar * toolbarView_;
//	UIImageView * topShadowMask_;
//	UIImageView * bottomShadowMask_;
}

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UITextView *textView;
//@property (nonatomic, strong) NoteEntryToolbar *toolbarView;
//@property (nonatomic, strong) UIImageView *topShadowMask;
//@property (nonatomic, strong) UIImageView *bottomShadowMask;

@property (nonatomic, strong) NSString *aNote;
@property (nonatomic, strong) NSString *autoSaveKey;
@property (nonatomic, strong) NSString *additionalNotes;
@property (nonatomic) BOOL isSingleLineField;
@property (nonatomic) BOOL isModal;
@property (nonatomic) BOOL isWebAddress;
@property (nonatomic) BOOL isNonAutocorrecting;
@property (nonatomic) BOOL isSecure;
@property (nonatomic) BOOL showPhotoTools;

@property (copy) NoteCompleteAction onComplete;

- (void)save:(id)sender;
- (void)setCallBackTarget:(id) cbt withAction:(NSString *)act forResponseID:(int)rID;

@end
