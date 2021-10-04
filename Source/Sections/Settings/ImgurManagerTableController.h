//  Copyright 2010 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "NavigationManager.h"

@interface ImgurManagerTableController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
	UIImagePickerController *imagePickerController;
	UIImageView *chosenPhotoView;
	UIPopoverController *popover;
}

@end
