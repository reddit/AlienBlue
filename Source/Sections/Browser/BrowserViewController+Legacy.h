#import "BrowserViewController.h"

@interface BrowserViewController (Legacy)

- (void)showLegacyExtraOptionsActionSheet:(id)sender;
- (void)dismissLegacyExtraOptionsActionSheet;

- (BOOL)isImageLink:(NSString *)link;
- (void)saveImageToPhotoLibrary;
- (void)showShareOptions;
@end
