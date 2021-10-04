#import "PhotoUploadViewController.h"
#import "UIImage+Skin.h"
#import "ABButton.h"
#import "MBProgressHUD.h"
#import "PhotoProcessing.h"
#import "UIColor+Hex.h"
#import "Resources.h"
#import "RedditAPI+Imgur.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "ABCustomOutlineNavigationBar.h"
#import "ImgurUploadRecord.h"

#define kPhotoUploadDidShowImgurTOSDialogPrefKey @"kPhotoUploadDidShowImgurTOSDialogPrefKey"

@interface PhotoUploadViewController()
@property (nonatomic,strong) ABButton *uploadButton;
@property (nonatomic,strong) UIImage *photo;
@property (nonatomic,strong) UIImageView *photoView;
@property (nonatomic,strong) UIImageView *photoFrameView;
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic,strong) UIPopoverController *popover;
- (void)releaseViews;
- (void)dismiss;
- (void)showCameraPicker;
- (void)showImagePicker;
- (void)uploadImageToImgur;
@end

@implementation PhotoUploadViewController

@synthesize uploadButton = uploadButton_;
@synthesize photoView = photoView_;
@synthesize photoFrameView = photoFrameView_;
@synthesize imagePicker = imagePicker_;
@synthesize popover = popover_;

@synthesize photo = photo_;
@synthesize delegate = delegate_;
@synthesize propertyKey = propertyKey_;

- (void)dealloc;
{
    [[RedditAPI shared] resetConnectionsForImgur];
    [self releaseViews];
    self.delegate = nil;
}

- (id)initWithDelegate:(id<PhotoUploadDelegate>)delegate propertyKey:(NSString *)propertyKey;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        [self jm_usePreIOS7ScrollBehavior];
        [self setNavbarTitle:@"Upload Photo"];
      
        self.delegate = delegate;
        self.propertyKey = propertyKey;
        
        self.photo = nil;
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsImageEditing = [[NSUserDefaults standardUserDefaults] boolForKey:kABSettingKeyCropImageUploads];
        
        if ([Resources isIPAD])
        {
//            UIBarButtonItem * sendItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload Photo" style:UIBarButtonItemStyleBordered target:self action:@selector(uploadPhoto)];
            UIBarButtonItem * sendItem = [UIBarButtonItem skinBarItemWithTitle:@"Upload Photo" textColor:JMHexColor(5085d8) fillColor:nil positionOffset:CGSizeZero target:self action:@selector(uploadPhoto)];
            self.navigationItem.rightBarButtonItem = sendItem;
        }

    }
    return self;
}

#pragma mark -
#pragma mark - View Lifecycle

- (void)releaseViews;
{
    self.uploadButton = nil;
    self.photoView = nil;
    self.photoFrameView = nil;
}

- (UIView *)createPhotoUploadWrapperView;
{
  UIView *wrapperView = [[UIView alloc] initWithFrame:self.view.bounds];
  wrapperView.autoresizingMask = JMFlexibleSizeMask;
  
  CGRect innerFrame = CGRectInset(wrapperView.bounds, 20., 24.);
  CGPoint takePhotoButtonOrigin = innerFrame.origin;
  CGPoint cameraRollButtonOrigin = CGPointMake(CGRectGetMaxX(innerFrame) - 112, innerFrame.origin.y - 6.);
  CGFloat photoFrameHeight = [Resources isIPAD] ? 330 : 212.;
  CGFloat photoFrameVerticalOffset = 130.;
  CGRect photoFrameRect = CGRectMake(innerFrame.origin.x, innerFrame.origin.y + photoFrameVerticalOffset, innerFrame.size.width, photoFrameHeight);
  
//  UIImage *background = [UIImage skinImageNamed:@"section/upload-photo/photo-upload-background.png"];
//  UIImageView *backgroundView = [[UIImageView alloc] initWithImage:background];
//  backgroundView.frame = wrapperView.bounds;
//  backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//  [wrapperView addSubview:backgroundView];
  
  ABButton *takePhotoButton = [ABButton buttonWithImageName:@"section/upload-photo/take-photo-normal.png" target:self action:@selector(takePhoto)];
  
  ABButton *cameraRollButton = [ABButton buttonWithImageName:@"section/upload-photo/camera-roll-normal.png" target:self action:@selector(pickPhoto)];
  cameraRollButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  
  takePhotoButton.left = takePhotoButtonOrigin.x;
  takePhotoButton.top = takePhotoButtonOrigin.y;
  
  cameraRollButton.left = cameraRollButtonOrigin.x;
  cameraRollButton.top = cameraRollButtonOrigin.y;
  
  [wrapperView addSubview:takePhotoButton];
  [wrapperView addSubview:cameraRollButton];
  
  if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
  {
    takePhotoButton.enabled = NO;
  }
  
  UIImageView *orView = [[UIImageView alloc] initWithImage:[UIImage skinImageNamed:@"section/upload-photo/photo-or.png"]];
  orView.top = innerFrame.origin.y + 50.;
  orView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  [wrapperView addSubview:orView];
  [orView centerHorizontallyInSuperView];
  
  self.photoFrameView = [UIImageView new];
  self.photoFrameView.frame = photoFrameRect;
  self.photoFrameView.alpha = 1.;
  self.photoFrameView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.photoFrameView.layer.borderWidth = 1.;
  self.photoFrameView.layer.borderColor = [UIColor colorForDivider].CGColor;
  
  self.photoView = [[UIImageView alloc] init];
  self.photoView.backgroundColor = [UIColor whiteColor];
  self.photoView.frame = self.photoFrameView.bounds;
  self.photoView.contentMode = UIViewContentModeScaleAspectFit;
  self.photoView.image = self.photo;
  self.photoView.autoresizingMask = JMFlexibleSizeMask;
  
  [self.photoFrameView addSubview:self.photoView];
  [wrapperView addSubview:self.photoFrameView];
  
  if (JMIsIphone())
  {
    self.uploadButton = [ABButton buttonWithImageName:@"section/upload-photo/button-upload-normal.png" target:self action:@selector(uploadPhoto)];
    self.uploadButton.bottom = wrapperView.bounds.size.height - 30.;
    [wrapperView addSubview:self.uploadButton];
    [self.uploadButton centerHorizontallyInSuperView];
    self.uploadButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | JMFlexibleHorizontalMarginMask;
  }
  
  if (!self.photo)
  {
    self.uploadButton.enabled = NO;
    self.photoView.hidden = YES;
  }
  return wrapperView;
}

- (void)loadView;
{
    [super loadView];
  
    BSELF(PhotoUploadViewController);
    ABCustomOutlineNavigationBar *customNavigationBar = (ABCustomOutlineNavigationBar *)self.attachedCustomNavigationBar;
    [customNavigationBar setCustomLeftButtonWithIcon:[ABCustomOutlineNavigationBar cancelIcon] onTapAction:^{
      [blockSelf jm_dismiss];
    }];
  
    if (JMIsIpad())
    {
      [customNavigationBar setCustomRightButtonWithTitle:@"Done" onTapAction:^{
        [blockSelf uploadPhoto];
      }];
    }
  
    UIView *wrapperView = [self createPhotoUploadWrapperView];
    [self.tableView addSubview:wrapperView];
}

- (void)viewDidUnload;
{
    [super viewDidUnload];
    [self releaseViews];
}

- (void)dismiss;
{
    [self.navigationController popViewControllerAnimated:YES];    
}

#pragma mark -
#pragma mark - Notify Delegates

- (void)finishWithUrl:(NSString *)url;
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    
    if (url && [url length] > 0)
    {
        [self.delegate performSelector:@selector(didUploadToImgurImage:withUrl:) withObject:self.photo withObject:url];
        [self jm_dismiss];
    }
}

#pragma mark -
#pragma mark - UI Response

- (void)takePhoto;
{
    [self showCameraPicker];
}

- (void)pickPhoto;
{
    [self showImagePicker];
}

- (void)uploadPhoto;
{
    if (!self.photo)
        return;
  
    BSELF(PhotoUploadViewController);
    JMAction photoUploadAction = ^{
      MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
      [hud setLabelText:@"Uploading. Please wait."];
      [blockSelf uploadImageToImgur];
    };
  
    if (![UDefaults boolForKey:kPhotoUploadDidShowImgurTOSDialogPrefKey])
    {
      NSString *imgurTOSMessage = @"You are about to upload a photo to Imgur. Imgur has rules about what you can upload. Be sure to read Imgur’s privacy policy and terms of use.";
      UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Imgur Terms & Privacy" message:imgurTOSMessage];
      [alertView bk_addButtonWithTitle:@"Read Terms & Privacy Policy" handler:^{
        [[UIApplication sharedApplication] openURL:[@"http://imgur.com/tos" URL]];
      }];
      [alertView bk_addButtonWithTitle:@"Continue Upload" handler:^{
        [UDefaults setBool:YES forKey:kPhotoUploadDidShowImgurTOSDialogPrefKey];
        photoUploadAction();
      }];
      [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
      [alertView show];
    }
    else
    {
      photoUploadAction();
    }
}

#pragma mark -
#pragma mark - Take Photo

- (void)showPicker;
{
    if ([Resources isIPAD])
    {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
        [self.popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2,0,10,10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        [self presentModalViewController:self.imagePicker animated:YES];    
    }
}

- (void)showCameraPicker
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self showPicker];
}

- (void)showImagePicker
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self showPicker];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([Resources isIPAD])
    {
      [self.popover dismissPopoverAnimated:YES];
    }
    else
    {
      [picker dismissModalViewControllerAnimated:YES];
    }
  
    UIImage * img = [PhotoProcessing processPhotoFromInfo:info];
    self.photo = img;
    self.photoView.image = self.photo;
    self.photoView.hidden = NO;
    self.uploadButton.enabled = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - Image Uploading

- (void)uploadImageToImgur;
{
    [[RedditAPI shared] postImageToImgur:UIImageJPEGRepresentation(self.photo,0.8) callBackTarget:self];
}

- (void) imageUploadResponse: (id) sender
{
    if (!self.photo)
        return;
    
	NSDictionary *imgurUpload = (NSDictionary *) sender;
	if (!imgurUpload)
		return;
  
  NSString *imageURL = [ImgurUploadRecord originalImageUrlFromImgurResponseDictionary:imgurUpload];
  [ImgurUploadRecord storeUploadRecordWithImgurResponseDictionary:imgurUpload];
  
  if (!JMIsEmpty(self.propertyKey))
  {
    [[NSUserDefaults standardUserDefaults] setValue:imageURL forKey:self.propertyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
  
  [self finishWithUrl:imageURL];
}

#pragma Mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return [Resources isIPAD];
}

@end
