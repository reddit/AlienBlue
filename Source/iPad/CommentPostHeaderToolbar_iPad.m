#import "CommentPostHeaderToolbar_iPad.h"
#import "PostModerationControlView.h"
#import "NavigationManager_iPad.h"
#import "ModButtonOverlay.h"

@interface CommentPostHeaderToolbar()
@property (strong, readonly) ModButtonOverlay *modButtonOverlay;
@property (strong, readonly) JMViewOverlay *subredditLinkOverlay;
@property (strong, readonly) JMViewOverlay *scoreOverlay;
- (void)updateOverlays;
@end

@interface CommentPostHeaderToolbar_iPad()
@property (strong) UIPopoverController *modToolsPopover;
@end

@implementation CommentPostHeaderToolbar_iPad

SYNTHESIZE_ASSOCIATED_STRONG(UIPopoverController, modToolsPopover, ModToolsPopover);

- (void)updateOverlays;
{
  [super updateOverlays];
  
//  self.subredditLinkOverlay.left += 5.;
//  
//  self.modButtonOverlay.left = self.subredditLinkOverlay.right + 8.;
//  self.modButtonOverlay.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//  
//  self.scoreOverlay.left -= 5;
}
  
- (void)presentModToolsView:(PostModerationControlView *)modToolsView;
{
  UIViewController *modToolsController = [UIViewController new];
  UIView *view = modToolsController.view;
  view.backgroundColor = JMHexColor(d6d7d8);
  modToolsView.backgroundColor = JMHexColor(d6d7d8);
  
//  UIImage *bgImage = [[UIImage skinImageNamed:@"backgrounds/drawer-stretchable.png"] jm_resizableImageWithCapInsets:UIEdgeInsetsMake(30., 130., 30., 130.) resizingMode:UIImageResizingModeTile];
//  UIImageView *bgView = [[UIImageView alloc] initWithImage:bgImage];
//  bgView.frame = view.bounds;
//  bgView.autoresizingMask = JMFlexibleSizeMask;
//  [view addSubview:bgView];

  modToolsView.frame = view.bounds;
  modToolsView.autoresizingMask = JMFlexibleSizeMask;
  [view addSubview:modToolsView];
  modToolsView.top = 15.;
  
  BSELF(CommentPostHeaderToolbar_iPad);
  modToolsView.onModerationWillShowTemplateSelectionScreen = ^{
    [blockSelf.modToolsPopover dismissPopoverAnimated:NO];
  };
  
  modToolsController.ab_contentSizeForViewInPopover = CGSizeMake(320., 67.);
  UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:modToolsController];
  
  [popover presentPopoverFromRect:self.modButtonOverlay.jm_globalFrame inView:[NavigationManager mainView] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  self.modToolsPopover = popover;
}

- (void)dismissModToolsView:(PostModerationControlView *)modToolsView;
{
  [self.modToolsPopover dismissPopoverAnimated:YES];
}

@end
