@interface LinkShareCoordinator : NSObject

+ (void)presentLinkShareSheetFromViewController:(UIViewController *)presentFromController barButtonItemOrNil:(UIBarButtonItem *)barButtonItemOrNil withAddress:(NSString *)address title:(NSString *)title;

@end
