#import <UIKit/UIKit.h>
#import "AlienBlueAppDelegate.h"

@interface CommentEntryCoordinator : NSObject <UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
  UIViewController *__ab_weak callbackViewController_;
	UIView *attachToView_;
  
	NSMutableArray *parentParagraphs_;

	NSString *parentComment_;
	NSString *parentCommentUsername_;
	NSString *myComment_;

	int responseID_;
	BOOL isEditing_;

	// we use this flag to let this viewcontroller know that it is for a message reply (rather
  // than a comment reply).
  BOOL isForMessage_;

	UIImagePickerController *imagePickerController_;

	UITextView *cTextView_;
	UITextView *parentCommentTextView_;
	UIImageView *chosenPhotoView_;
	UILabel *parentCommentUsernameLabel_;
	UILabel *myUsernameLabel_;

	UILabel *respondingLabel_;
	UILabel *editingLabel_;
  UIPopoverController *popover_;

  UIActionSheet *mainOptionsPopupQuery_;
  UIViewController *__ab_weak commentEntryViewController_;
}

@property (nonatomic, strong) UITextView *cTextView;
@property (nonatomic, strong) UITextView *parentCommentTextView;
@property (nonatomic, strong) UILabel *parentCommentUsernameLabel;
@property (nonatomic, strong) UILabel *myUsernameLabel;
@property (nonatomic, strong) UILabel *respondingLabel;
@property (nonatomic, strong) UILabel *editingLabel;
@property (nonatomic, copy) NSString *parentComment;
@property (nonatomic, copy) NSString *parentCommentUsername;
@property (nonatomic, copy) NSString *myComment;
@property (nonatomic, ab_weak) UIViewController *callbackViewController;
@property (nonatomic, ab_weak) UIViewController *commentEntryViewController;

@property (copy) JMAction onAddPhotoTap;

@property BOOL isEditing;
@property int responseID;
@property BOOL isForMessage;

- (void)cancelComment:(id)sender;
- (void)showMainOptionsActionSheet:(id)sender;
- (void)showAddPhotoActionSheet;
- (void)submitCommentToController:(id)sender;
- (void)initValues;

- (void)didFinishUploadingImgurWithImageUrl:(NSString *)imageUrl;

@end