#import <UIKit/UIKit.h>

@class ABActionMenuHost;
@interface UIViewController (Additions)

@property (weak) ABActionMenuHost *relatedActionMenuHost;
@property CGSize ab_contentSizeForViewInPopover;

- (BOOL)isModal;
- (void)setNavbarTitle:(NSString *)title;

@end
