#import "PostsActionMenuHost.h"
#import "PostsViewController+PopoverOptions.h"
#import "PostsNavigationBar.h"
#import "NavigationManager.h"

@interface PostsActionMenuHost()
@property (readonly) PostsViewController *postsViewController;
@property (readonly) PostsNavigationBar *postsNavigationBar;
@end

@implementation PostsActionMenuHost

- (Class)classForCustomNavigationBar;
{
  return [PostsNavigationBar class];
}

- (PostsViewController *)postsViewController;
{
  return (PostsViewController *)self.parentController;
}

- (PostsNavigationBar *)postsNavigationBar;
{
  return (PostsNavigationBar *)self.customNavigationBar;
}

- (void)willAttachCustomNavigationBar:(ABCustomOutlineNavigationBar *)customNavigationBar;
{
  [super willAttachCustomNavigationBar:customNavigationBar];
  self.postsViewController.tableView.tableHeaderView = nil;
}

- (void)updateCustomNavigationBar;
{
  [super updateCustomNavigationBar];
  [self.postsNavigationBar setSearchHeaderBar:self.postsViewController.headerCoordinator.view];
  self.postsViewController.tableView.tableHeaderView = nil;
}

- (NSString *)friendlyName;
{
  return @"Posts";
}

//- (void)showAddSubredditToGroup;
//- (void)showSidebar;
//- (void)showMessageModsScreen;


- (NSArray *)generateScreenSpecificActionMenuNodes;
{
  BSELF(PostsActionMenuHost);
  JMActionMenuNode *showCanvasNode = [JMActionMenuNode nodeWithIdent:@"posts-canvas" iconName:@"am-icon-posts-canvas" title:@"Gallery"];
  showCanvasNode.nodeDescription = @"Browse subreddit as an image gallery";
  showCanvasNode.color = JMHexColor(70c218);
  showCanvasNode.onTap = ^{
    [blockSelf.postsViewController showGallery];
  };
    
  JMActionMenuNode *subscribeToggleNode = [JMActionMenuNode nodeWithIdent:@"posts-subscribe" iconName:@"am-icon-posts-subscribe" title:@"Subscribe"];
  subscribeToggleNode.nodeDescription = @"Subscribe or unsubscribe from subreddit";
  subscribeToggleNode.color = JMHexColor(ff5a9c);
  subscribeToggleNode.onTap = ^{
    [blockSelf.postsViewController showAddSubredditToGroup];
  };
  subscribeToggleNode.customLabelText = [self.postsViewController isSubscribedToSubreddit] ? @"Unsubscribe" : @"Subscribe";
  subscribeToggleNode.disabled = !self.postsViewController.isNativeSubreddit;
  
  JMActionMenuNode *sidebarNode = [JMActionMenuNode nodeWithIdent:@"posts-sidebar" iconName:@"am-icon-posts-sidebar" title:@"Sidebar"];
  sidebarNode.nodeDescription = @"Information and rules for this subreddit";
  sidebarNode.color = JMHexColor(5a6aff);
  sidebarNode.onTap = ^{
    [blockSelf.postsViewController showSidebar];
  };
  sidebarNode.disabled = !self.postsViewController.isNativeSubreddit;
  
  JMActionMenuNode *messageModsNode = [JMActionMenuNode nodeWithIdent:@"posts-message-mods" iconName:@"am-icon-posts-message-mods" title:@"Message Mods"];
  messageModsNode.nodeDescription = @"Contact the moderators of this subreddit";
  messageModsNode.color = JMHexColor(ff666d);
  messageModsNode.disabled = !self.postsViewController.isNativeSubreddit;
  messageModsNode.onTap = ^{
    [blockSelf.postsViewController showMessageModsScreen];
  };

  return @[
    showCanvasNode,
    subscribeToggleNode,
    sidebarNode,
    messageModsNode
  ];
}

@end
