#import "ImgurManagerController.h"
#import "PhotoUploadViewController.h"
#import "ImgurUploadCell.h"
#import "NavigationManager.h"
#import "RedditAPI+Imgur.h"
#import "PromptManager.h"
#import <ShareKit/SHK.h>

@interface ImgurManagerController() <PhotoUploadDelegate>
@property (strong) ImgurUploadRecord *potentiallyDeletedRecord;
@property (strong) UILabel *nothingHereLabel;
@end

@implementation ImgurManagerController

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (id)init;
{
  JM_SUPER_INIT(init);
  self.hidesBottomBarWhenPushed = YES;
  self.title = @"Manage Imgur Uploads";
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleComingBackFromSafariAfterDeleteIfNecessary) name:UIApplicationDidBecomeActiveNotification object:nil];
  return self;
}

- (void)loadView;
{
  [super loadView];
  BSELF(ImgurManagerController);
  [self.navigationBar setCustomRightButtonWithIcon:[ABCustomOutlineNavigationBar addIcon] onTapAction:^{
    [blockSelf showPhotoUploadController];
  }];
  
  self.nothingHereLabel = [UILabel new];
  self.nothingHereLabel.text = @"No images uploaded";
  self.nothingHereLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.];
  self.nothingHereLabel.textColor = [UIColor colorForHighlightedOptions];
  [self.nothingHereLabel sizeToFit];
  [self.view addSubview:self.nothingHereLabel];
  [self.nothingHereLabel centerInSuperView];
  self.nothingHereLabel.autoresizingMask = JMFlexibleMarginMask;
}

- (void)generateNodes;
{
  BSELF(ImgurManagerController);
  
  [self removeAllNodes];
  NSArray *orderedUploadRecords = [[ImgurUploadRecord imgurUploadRecords] reverseObjectEnumerator].allObjects;
  NSArray *imgurRecordNodes = [orderedUploadRecords map:^id(ImgurUploadRecord *record) {
    ImgurUploadNode *uploadNode = [[ImgurUploadNode alloc] initWithUploadRecord:record];
    __block __weak ImgurUploadNode *weakUploadNode = uploadNode;
    uploadNode.onGearIconTapAction = ^{
      [blockSelf showOptionsForUploadNode:weakUploadNode];
    };
    return uploadNode;
  }];
  
  [self addNodes:imgurRecordNodes];
  [self reload];
  
  self.nothingHereLabel.hidden = self.nodeCount > 0;
}

- (void)showOptionsForUploadNode:(ImgurUploadNode *)uploadNode;
{
  ImgurUploadRecord *record = uploadNode.uploadRecord;
  BSELF(ImgurManagerController);
  UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"Uploaded Photo"];
  [sheet bk_setDestructiveButtonWithTitle:@"Delete Photo" handler:^{
    [blockSelf showDeletePhotoAlertForRecord:record];;
  }];
  [sheet bk_addButtonWithTitle:@"Copy to Clipboard" handler:^{
    [[UIPasteboard generalPasteboard] setString:record.originalImageUrl];
    [PromptManager addPrompt:@"Image URL copied to clipboard"];
  }];
  [sheet bk_addButtonWithTitle:@"Share" handler:^{
    [blockSelf showShareOptionsForAddress:record.originalImageUrl];
  }];
  [sheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [sheet jm_showInView:[NavigationManager mainView]];
}

- (void)showDeletePhotoAlertForRecord:(ImgurUploadRecord *)uploadRecord;
{
  BSELF(ImgurManagerController);

  UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"Delete Photo" message:@"Are you sure you want to delete this photo from imgur.com?"];
  [alert bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [alert bk_addButtonWithTitle:@"Delete" handler:^{
    NSString *deleteUrl = [[NSString alloc] initWithFormat:@"http://imgur.com/delete/%@", uploadRecord.deleteHash];
    blockSelf.potentiallyDeletedRecord = uploadRecord;
    [[UIApplication sharedApplication] openURL:deleteUrl.URL];
  }];
  [alert show];
}

- (void)handleComingBackFromSafariAfterDeleteIfNecessary;
{
  if (!self.potentiallyDeletedRecord)
    return;
  
  __block __weak ImgurUploadRecord *weakUploadRecord = self.potentiallyDeletedRecord;

  BSELF(ImgurManagerController);
  
  [self.potentiallyDeletedRecord.originalImageUrl.URL jm_determineFileSizeOnComplete:^(long long fileSizeBytes) {
    if (fileSizeBytes <= 700)
    {
      [ImgurUploadRecord removeStoredUploadRecordForRecord:weakUploadRecord];
      [PromptManager addPrompt:@"Image Deleted"];
      [blockSelf generateNodesAnimated:YES];
    }
  }];
  
  self.potentiallyDeletedRecord = nil;
}

- (void)generateNodesAnimated:(BOOL)animated;
{
  BSELF(ImgurManagerController);
  [UIView jm_transition:self.tableView animations:^{
    [blockSelf generateNodes];
  } completion:nil animated:animated];
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
  [self generateNodesAnimated:NO];
}

- (void)showPhotoUploadController;
{
  PhotoUploadViewController *controller = [[UNIVERSAL(PhotoUploadViewController) alloc] initWithDelegate:self propertyKey:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)didUploadToImgurImage:(UIImage *)image withUrl:(NSString *)url;
{
  [self generateNodesAnimated:YES];
}

- (void)showShareOptionsForAddress:(NSString *)address;
{
  NSURL *url = [NSURL URLWithString:address];
  SHKItem *item = [SHKItem URL:url title:nil];
  SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
  [SHK setRootViewController:[NavigationManager shared].postsNavigation];
  [actionSheet setBackgroundColor:[UIColor blackColor]];
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
  [actionSheet jm_showInView:self.navigationController.view];
}

@end
