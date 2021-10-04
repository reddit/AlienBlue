#import "UIViewController+Additions.h"
#import "AlienBlueAppDelegate.h"
#import "Resources.h"
#import "JMOutlineViewController+CustomNavigationBar.h"
#import "ABCustomOutlineNavigationBar.h"

@interface UIViewController (Additions_)
@property (weak) ABActionMenuHost *relatedActionMenuHost;
@end

@implementation UIViewController (Additions)

SYNTHESIZE_ASSOCIATED_WEAK(ABActionMenuHost, relatedActionMenuHost, RelatedActionMenuHost);

- (BOOL)isModal;
{
  NavigationManager * nc = [NavigationManager shared];
  if (self.navigationController == nc.postsNavigation)
  {
      return NO;
  }
  return (self.parentViewController.parentViewController.parentViewController == nil);
}

- (void)setNavbarTitle:(NSString *)title
{
  self.title = title;
  
  JMOutlineViewController *outlineController = JMCastOrNil(self, JMOutlineViewController);
  ABCustomOutlineNavigationBar *customNavbar = JMCastOrNil(outlineController.attachedCustomNavigationBar, ABCustomOutlineNavigationBar);
  if (customNavbar)
  {
    [customNavbar setTitleLabelText:title];
    return;
  }
  
  if (self.navigationController == [NavigationManager shared].postsNavigation)
  {
    [[NavigationManager shared].postsNavigation replaceNavigationItemWithCustomBackButton:self.navigationItem];
  }
  else
  {
    CGRect labelRect = CGRectMake(0, 0, 10., 44.);
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont skinFontWithName:kBundleFontNavigationTitle];
    label.textAlignment = UITextAlignmentCenter;
    BOOL useDarkTitle = !JMIsNight();
    label.textColor = [UIColor colorForBarButtonItem];
    label.shadowColor = useDarkTitle ? [UIColor whiteColor] : [UIColor blackColor];
    label.shadowOffset = useDarkTitle ? CGSizeMake(0, 1) : CGSizeMake(0, 1);
    [label sizeToFit];
    UIView *containerView = [UIView new];
    containerView.frame = label.frame;
    [containerView addSubview:label];
    label.top -= 5.;
    self.navigationItem.titleView = containerView;
  }
}

- (CGSize)ab_contentSizeForViewInPopover;
{
  return JMIsIOS8() ? self.preferredContentSize : self.contentSizeForViewInPopover;
}

- (void)setAb_contentSizeForViewInPopover:(CGSize)ab_contentSizeForViewInPopover;
{
  if (JMIsIOS8())
  {
    self.preferredContentSize = ab_contentSizeForViewInPopover;
  }
  else
  {
    self.contentSizeForViewInPopover = ab_contentSizeForViewInPopover;
  }
}

@end
