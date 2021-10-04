#import "CommentEntryViewController.h"
#import "CommentEntryCoordinator.h"
#import "SubredditManager.h"
#import "NavigationManager.h"
#import "PhoneCommentEntryView.h"
#import "Resources.h"
#import "GTMNSString+HTML.h"
#import "NavigationManager+Deprecated.h"
#import "PhotoUploadViewController.h"

@interface CommentEntryViewController() <PhotoUploadDelegate>
@property (nonatomic,strong) CommentEntryView * commentEntryView;
@property (nonatomic,strong) CommentEntryCoordinator *coordinator;
@property (nonatomic,copy) NSMutableDictionary *comment;
@property (nonatomic,ab_weak) NSObject<CommentEntryDelegate> *delegate;
@property (nonatomic,assign) BOOL editingComment;
@property (nonatomic,assign) BOOL forMessage;
- (void) setupCoordinator;
@end

@implementation CommentEntryViewController

@synthesize delegate = delegate_;
@synthesize commentEntryView = commentEntryView_;
@synthesize coordinator = coordinator_;
@synthesize comment = comment_;
@synthesize editingComment = editingComment_;
@synthesize forMessage = forMessage_;

- (void)dealloc
{
    self.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
  JM_SUPER_INIT(initWithNibName:nibNameOrNil bundle:nibBundleOrNil);
  [self jm_usePreIOS7ScrollBehavior];
  return self;
}

- (void)loadView;
{
    [super loadView];

    self.coordinator = [[CommentEntryCoordinator alloc] init];
    BSELF(CommentEntryViewController)
    self.coordinator.onAddPhotoTap = ^{
      [blockSelf showAddImagePopup];
    };
    
    Class commentEntryClass = [Resources isIPAD] ? [CommentEntryView class] : [PhoneCommentEntryView class];

    self.commentEntryView = [[commentEntryClass alloc] initWithFrame:self.view.bounds delegate:self];

    [self.view addSubview:self.commentEntryView];
    
    [self setupCoordinator];

}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self.coordinator action:@selector(submitCommentToController:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.coordinator action:@selector(cancelComment:)];
    
    if (![Resources isIPAD])
    {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
	if ([Resources isIPAD])
		return YES;
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return NO;
	
	if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) && ![UDefaults boolForKey:kABSettingKeyAllowRotation])
		return NO;
	
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [self.commentEntryView setForceReposition:YES];
    [self.commentEntryView setNeedsLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
    [self.commentEntryView setForceReposition:YES];
    [self.commentEntryView setNeedsLayout];
    
    [self.commentEntryView externalSwitchToMyComment];
}

- (void) setupCoordinator;
{
    self.coordinator.callbackViewController = self;
    self.coordinator.commentEntryViewController = self;
    self.coordinator.isEditing = self.editingComment;
    self.coordinator.isForMessage = self.forMessage;
    self.coordinator.responseID = [[self.comment valueForKey:@"comment_index"] intValue];
    self.coordinator.myComment = [self.comment valueForKey:@"replyText"];
    self.coordinator.cTextView = self.commentEntryView.commentTextView;
    self.coordinator.parentCommentTextView = self.commentEntryView.parentTextView;
    self.coordinator.parentCommentUsername = [self.comment valueForKey:@"author"];
    self.coordinator.parentComment = [[self.comment valueForKey:@"originalBody"] gtm_stringByUnescapingFromHTML];
    [self.coordinator initValues];
}


+ (CommentEntryViewController *) viewControllerForDelegate:(id<CommentEntryDelegate>)delegate withComment:(NSMutableDictionary *)comment editing:(BOOL)editing message:(BOOL)message;
{
    CommentEntryViewController * viewController = [[CommentEntryViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = delegate;
    viewController.comment = comment;
    viewController.editingComment = editing;
    viewController.forMessage = message;
    return viewController;
}

+ (UINavigationController *) viewControllerWithNavigationForDelegate:(id<CommentEntryDelegate>)delegate withComment:(NSMutableDictionary *)comment editing:(BOOL)editing message:(BOOL)message;
{
    CommentEntryViewController * viewController = [CommentEntryViewController viewControllerForDelegate:delegate withComment:comment editing:editing message:message];
    UINavigationController * navController = [[ABNavigationController alloc] initWithRootViewController:viewController];
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    return navController;
}

- (void) exitCommentEntry;
{
    //  todo: unhackify this. iOS 7 flashes the bar items momentarily after this
    // has been dismissed
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;

    if (![Resources isIPAD])
    {
        if (![Resources isIPAD] && ![[NavigationManager shared] deprecated_isFullscreen])
        {
            PhoneCommentEntryView *iPhoneCommentEntryView = (PhoneCommentEntryView *)self.commentEntryView;
            iPhoneCommentEntryView.drawer.hidden = YES;

            [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
        }

        if (self.forMessage)
        {

          if (JMIsIphone())
          {
            PhoneCommentEntryView *iPhoneCommentEntryView = (PhoneCommentEntryView *)self.commentEntryView;
            iPhoneCommentEntryView.hidden = YES;
//            [self.navigationController setNavigationBarHidden:NO animated:YES];
          }
          
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self.navigationController dismissModalViewControllerAnimated:YES];
        }
    }
    else
    {
        if (self.forMessage)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [[NavigationManager shared] dismissModalView];
        }
    }
}

#pragma Mark -
#pragma Mark - Entry View Delegate

- (NSString *)assetFolder;
{
    if (![[self.comment objectForKey:@"subreddit"] isKindOfClass:[NSString class]])
        return nil;
    
    if([[SubredditManager sharedSubredditManager] doesSubredditHaveAssets:[self.comment objectForKey:@"subreddit"]])
    {
        return [self.comment objectForKey:@"subreddit"];
    }
    return nil;
}

- (BOOL)isSmallWindow;
{
    return self.forMessage;
}

#pragma Mark -
#pragma Mark - Coordinator Proxy

-(void) showPopup;
{
    [self.commentEntryView.commentTextView resignFirstResponder];
    [self.coordinator showMainOptionsActionSheet:nil];
}

-(void) showAddImagePopup;
{
  PhotoUploadViewController *controller = [[UNIVERSAL(PhotoUploadViewController) alloc] initWithDelegate:self propertyKey:nil];
  ABNavigationController *nav = [[ABNavigationController alloc] initWithRootViewController:controller];
  nav.modalPresentationStyle = UIModalPresentationFormSheet;
  nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  nav.toolbarHidden = YES;
  [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)didUploadToImgurImage:(UIImage *)image withUrl:(NSString *)url;
{
  [self.coordinator didFinishUploadingImgurWithImageUrl:url];
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
  if (JMIsIpad())
  {
    self.navigationController.navigationBarHidden = NO;
  }
}

#pragma Mark -
#pragma Mark - Coordinator Callbacks

-(void) commentExited:(NSDictionary *)dictionary;
{
    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [responseDictionary setObject:self.comment forKey:@"elementDictionary"];
    [self.delegate performSelector:@selector(commentExited:) withObject:responseDictionary];
    [self exitCommentEntry];
}

-(void) commentEntered:(NSDictionary *)dictionary;
{
    NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [responseDictionary setObject:self.comment forKey:@"elementDictionary"];
    [self.delegate performSelector:@selector(commentEntered:) withObject:responseDictionary afterDelay:0.5];
    [self exitCommentEntry];
}

- (id)commentCoordinator;
{
    return self.coordinator;
}

@end
