//  REDTabbedViewController.h
//  RedditApp

#import <UIKit/UIKit.h>

@interface REDTabbedViewController : UIViewController

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)setTabBarIconWithImageName:(NSString *)imageName
                 selectedImageName:(NSString *)selectedImageName;

@end
