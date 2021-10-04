#import "LinkShareCoordinator.h"

#import <TUSafariActivity/TUSafariActivity.h>

#import "LinkShareActivityTitleItemProvider.h"
#import "LinkShareActivityImageItemProvider.h"
#import "NavigationManager.h"

@implementation LinkShareCoordinator

+ (void)presentLinkShareSheetFromViewController:(UIViewController *)presentFromController barButtonItemOrNil:(UIBarButtonItem *)barButtonItemOrNil withAddress:(NSString *)address title:(NSString *)title;
{
  NSString *escapedAddress = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *sharedURL = [escapedAddress URL];
  LinkShareActivityTitleItemProvider *titleItemProvider = [[LinkShareActivityTitleItemProvider alloc] initWithTitle:title];
  LinkShareActivityImageItemProvider *imageItemProvider = [[LinkShareActivityImageItemProvider alloc] initWithURL:sharedURL];

  TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
  UIActivityViewController *activityViewController =
  [[UIActivityViewController alloc] initWithActivityItems:@[ titleItemProvider, sharedURL, imageItemProvider ]
                                    applicationActivities:@[ safariActivity ]];
  [activityViewController setValue:title forKey:@"subject"];
  
  // AirDrop support vastly slows down first present of the view controller, so remove it.
  activityViewController.excludedActivityTypes = @[ UIActivityTypeAirDrop ];
  
  if (JMIsIpad() && [activityViewController respondsToSelector:@selector(popoverPresentationController)])
  {
    activityViewController.popoverPresentationController.barButtonItem = barButtonItemOrNil;
  }
  
  if (JMIsIpad() && JM_SYSTEM_VERSION_LESS_THAN(@"8.0"))
  {
    // todo: remove this patch after we drop iOS 7 compatibility - it currently fixes
    // an issue that causes the top of the application to clip under the statusbar
    // when the activity controller is dismissed
    [activityViewController jm_observeSelector:@selector(viewDidDisappear:) doAfter:^{
      [[NavigationManager mainView] setNeedsLayout];
    }];
  }
  
  [presentFromController presentViewController:activityViewController animated:YES completion:nil];
}

@end
