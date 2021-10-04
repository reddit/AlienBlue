#import "BrowserActionMenuHost.h"
#import "BrowserViewController_iPhone.h"
#import "BrowserNavigationBar.h"
#import "JMOptimalToolbarCoordinator.h"
#import "CommentsActionMenuHost.h"
#import "BrowserViewController+Legacy.h"

@interface BrowserActionMenuHost()
@property (readonly) BrowserViewController_iPhone *browserViewController;
@property (readonly) BrowserNavigationBar *browserNavigationBar;
@end

@interface BrowserViewController()
@property (strong) JMOptimalToolbarCoordinator *toolbarCoordinator;
@end

@implementation BrowserActionMenuHost

- (NSString *)friendlyName;
{
  return @"Browser";
}

- (BrowserViewController_iPhone *)browserViewController;
{
  return (BrowserViewController_iPhone *)self.parentController;
}

- (Class)classForCustomNavigationBar;
{
  return [BrowserNavigationBar class];
}

- (BrowserNavigationBar *)browserNavigationBar;
{
  return (BrowserNavigationBar *)self.customNavigationBar;
}

- (void)updateCustomNavigationBar;
{
  [super updateCustomNavigationBar];
  
  BOOL hidesOptimalBar = JMIsEmpty(self.browserViewController.currentURL);
  [self.browserNavigationBar updateWithWithToolbarCoordinator:self.browserViewController.toolbarCoordinator forPost:self.browserViewController.post displaysOptimalByDefault:[self.browserViewController contentDisplaysOptimalByDefault] hidesOptimalBar:hidesOptimalBar];
  self.browserNavigationBar.onCommentButtonTap = ^{
    [[NavigationManager shared] switchToCommentsWithPost:self.browserViewController.post];
  };
  BSELF(BrowserActionMenuHost);
  self.browserNavigationBar.onOptimalSwitchChange = ^(BOOL didChangeToOptimal){
    [blockSelf.browserViewController userDidToggleOptimalSwitch:didChangeToOptimal];
  };
}

- (NSArray *)generateScreenSpecificActionMenuNodes;
{
  if (JMIsEmpty(self.browserViewController.currentURL))
    return @[];
  
  BSELF(BrowserActionMenuHost);
  Post *post = self.browserViewController.post;
  
  JMActionMenuNode *upvoteNode = [CommentsActionMenuHost generateContentUpvoteNode];
  JMActionMenuNode *downvoteNode = [CommentsActionMenuHost generateContentDownvoteNode];
  JMActionMenuNode *saveNode = [CommentsActionMenuHost generateContentSaveNode];
  JMActionMenuNode *hideNode = [CommentsActionMenuHost generateContentHideNode];
  JMActionMenuNode *reportNode = [CommentsActionMenuHost generateContentReportNode];

  JMActionMenuNode *showCommentsNode = [JMActionMenuNode nodeWithIdent:@"browser-switch-to-comments" iconName:@"am-icon-browser-switch-to-comments" title:@"View Comments"];
  showCommentsNode.nodeDescription = @"Shows comment threads for this link";
  showCommentsNode.color = JMHexColor(ff666d);
  showCommentsNode.hiddenByDefault = YES;
  showCommentsNode.onTap = ^{
    [[NavigationManager shared] switchToComments];
  };
  
  if (!post)
  {
    upvoteNode.disabled = YES;
    downvoteNode.disabled = YES;
    saveNode.disabled = YES;
    hideNode.disabled = YES;
    reportNode.disabled = YES;
    showCommentsNode.disabled = YES;
  }

  JMActionMenuNode *openInSafariNode = [JMActionMenuNode nodeWithIdent:@"browser-open-in-safari" iconName:@"am-icon-browser-open-in-safari" title:@"Safari"];
  openInSafariNode.nodeDescription = @"Open this link in the Safari browser";
  openInSafariNode.color = JMHexColor(5a6aff);
  openInSafariNode.onTap = ^{
    NSString *escapedUrl = [blockSelf.browserViewController.currentURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:escapedUrl]];
  };
  
  JMActionMenuNode *shareNode = [JMActionMenuNode nodeWithIdent:@"content-share" iconName:@"am-icon-content-share" title:@"Share"];
  shareNode.nodeDescription = @"Share a link with friends";
  shareNode.color = JMHexColor(ff666d);
  shareNode.onTap = ^{
    [blockSelf.browserViewController showShareOptions];
  };
  shareNode.showsBadgeForTraining = YES;
  
  JMActionMenuNode *browserBackNode = [JMActionMenuNode nodeWithIdent:@"browser-back" iconName:@"am-icon-browser-back" title:@"Back"];
  browserBackNode.nodeDescription = @"Navigates to the previous web page";
  browserBackNode.color = JMHexColor(31a888);
  browserBackNode.hiddenByDefault = YES;
  browserBackNode.onTap = ^{
    [blockSelf.browserViewController browserBack];
  };
  browserBackNode.disabled = !self.browserViewController.browserCanGoBack;
  
  JMActionMenuNode *browserForwardNode = [JMActionMenuNode nodeWithIdent:@"browser-forward" iconName:@"am-icon-browser-forward" title:@"Forward"];
  browserForwardNode.nodeDescription = @"Navigates to the next web page";
  browserForwardNode.color = JMHexColor(70c218);
  browserForwardNode.hiddenByDefault = YES;
  browserForwardNode.onTap = ^{
    [blockSelf.browserViewController browserForward];
  };
  browserForwardNode.disabled = !self.browserViewController.browserCanGoForward;
  
  JMActionMenuNode *browserRefreshNode = [JMActionMenuNode nodeWithIdent:@"browser-refresh" iconName:@"am-icon-browser-refresh" title:@"Refresh"];
  browserRefreshNode.nodeDescription = @"Reloads the current web page";
  browserRefreshNode.color = JMHexColor(5abbff);
  browserRefreshNode.hiddenByDefault = YES;
  browserRefreshNode.onTap = ^{
    [blockSelf.browserViewController browserRefresh];
  };

  JMActionMenuNode *saveImageNode = [JMActionMenuNode nodeWithIdent:@"browser-save-image" iconName:@"am-icon-browser-save-image" title:@"Save Image"];
  saveImageNode.nodeDescription = @"Saves an image to the device";
  saveImageNode.color = JMHexColor(f38085);
  saveImageNode.disabled = ![blockSelf.browserViewController isImageLink:blockSelf.browserViewController.currentURL];
  saveImageNode.onTap = ^{
    [blockSelf.browserViewController saveImageToPhotoLibrary];
  };

  return @[
      upvoteNode,
      downvoteNode,
      showCommentsNode,
      openInSafariNode,
      shareNode,
      saveNode,
      hideNode,
      reportNode,
      browserBackNode,
      browserForwardNode,
      browserRefreshNode,
      saveImageNode
   ];
}

@end
