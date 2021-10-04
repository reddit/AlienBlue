//  REDDiscoverViewController.h
//  RedditApp

#import <UIKit/UIKit.h>

#import "RedditApp/REDTabbedViewController.h"

#import "Common/Navigation/ABNavigationController.h"

@interface REDDiscoverViewController : REDTabbedViewController

@property(nonatomic, readonly) ABNavigationController *abNavigationController;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end
