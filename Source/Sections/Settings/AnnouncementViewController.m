#import "AnnouncementViewController.h"
#import "Announcement.h"
#import "ABNavigationController.h"
#import "NavigationManager.h"

#import "NSectionSpacerCell.h"
#import "NSectionTitleCell.h"
#import "NBaseOptionCell.h"
#import "UIImage+JMActionMenuAssets.h"

#import "AnnouncementTextCell.h"
#import "NCenteredTextCell.h"

@interface AnnouncementViewController()
@property (strong) Announcement *announcement;
@end

@implementation AnnouncementViewController

- (id)initWithAnnouncement:(Announcement *)announcement;
{
  self = [super init];
  if (self)
  {
    self.announcement = announcement;
    self.title = @"Announcement";
    self.hidesBottomBarWhenPushed = YES;
  }
  return self;
}

- (void)closeMe;
{
  [self jm_dismiss];
}

- (void)generateNodes;
{
  [self removeAllNodes];
  NSArray *nodes = [self nodesForSettings];
  [self addNodes:nodes];
  [self reload];
}

- (void)animateNodeChanges;
{
  BSELF(AnnouncementViewController);
  [UIView jm_transition:self.tableView animations:^{
    [blockSelf generateNodes];
  } completion:nil];
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
  [self generateNodes];
}

- (NSArray *)nodesForSettings;
{
  BSELF(AnnouncementViewController);
  NSMutableArray *nodes = [NSMutableArray array];
  
  UIImage *linkIcon = [UIImage actionMenuIconWithName:@"am-icon-global-goto-last-submitted-post" fillColor:[UIColor colorForAccessoryButtons]];
  
  SectionSpacerNode *spacer = [SectionSpacerNode spacerNodeWithCustomHeight:10. decoration:SectionSpacerDecorationNone];
  
  [nodes addObject:spacer];
  
  NSString *markAsReadTitle = self.announcement.shouldShow ? @"Mark as Read" : @"You can revisit this announcement via Settings";
  
  CenteredTextNode *markAsViewed = [CenteredTextNode nodeWithTitle:markAsReadTitle];
  markAsViewed.onSelect = ^{
    [Announcement markLatestAnnouncementAsRead];
    [blockSelf animateNodeChanges];
  };
  markAsViewed.customTitleColor = [UIColor whiteColor];
  markAsViewed.customBackgroundColor = self.announcement.shouldShow ? [UIColor skinColorForConstructive] : [UIColor skinColorForDisabledIcon];
  markAsViewed.customHeight = 50.;
  markAsViewed.customTitleFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.];
  [nodes addObject:markAsViewed];
  
  [nodes addObject:[SectionSpacerNode spacerNodeWithCustomHeight:10. decoration:SectionSpacerDecorationNone]];
  

  if (!JMIsEmpty(self.announcement.title))
  {
    CenteredTextNode *titleNode = [CenteredTextNode nodeWithTitle:self.announcement.title];
    titleNode.customHeight = 50.;
    titleNode.customTitleFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.];
    titleNode.customBackgroundColor = [UIColor colorForBackground];
    titleNode.customTitleColor = [UIColor colorForHighlightedOptions];
    [nodes addObject:titleNode];
    [nodes addObject:[SectionSpacerNode spacerNodeWithCustomHeight:10. decoration:SectionSpacerDecorationLine]];
  }
  
  AnnouncementTextNode *textNode = [[AnnouncementTextNode alloc] initWithHTML:self.announcement.content];
  [nodes addObject:textNode];
  
  [nodes addObject:spacer];
  
  if (self.announcement.hasLink1)
  {
    OptionNode *linkNode = [OptionNode new];
    linkNode.title = self.announcement.link1Title;
    linkNode.onSelect = ^{
      [blockSelf openUrl:blockSelf.announcement.link1Url usingSafari:blockSelf.announcement.link1OpensInSafari];
    };
    linkNode.icon = linkIcon;
    [linkNode setDisclosureStyle:OptionDisclosureStyleArrow];
    [nodes addObject:linkNode];
  }
  
  if (self.announcement.hasLink2)
  {
    OptionNode *linkNode = [OptionNode new];
    linkNode.title = self.announcement.link2Title;
    linkNode.onSelect = ^{
      [blockSelf openUrl:blockSelf.announcement.link2Url usingSafari:blockSelf.announcement.link2OpensInSafari];
    };
    linkNode.icon = linkIcon;
    [linkNode setDisclosureStyle:OptionDisclosureStyleArrow];
    [nodes addObject:linkNode];
  }
  
  if (self.announcement.hasLink3)
  {
    OptionNode *linkNode = [OptionNode new];
    linkNode.title = self.announcement.link3Title;
    linkNode.onSelect = ^{
      [blockSelf openUrl:blockSelf.announcement.link3Url usingSafari:blockSelf.announcement.link3OpensInSafari];
    };
    linkNode.icon = linkIcon;
    [linkNode setDisclosureStyle:OptionDisclosureStyleArrow];
    [nodes addObject:linkNode];
  }
  
  if (self.announcement.hasCommentFeed)
  {
    OptionNode *commentNode = [OptionNode new];
    commentNode.icon = [UIImage actionMenuIconWithName:@"am-icon-global-goto-last-submitted-comment" fillColor:[UIColor colorForAccessoryButtons]];
    commentNode.title = @"Comments";
    commentNode.onSelect = ^{
      [blockSelf openUrl:blockSelf.announcement.commentFeedUrl usingSafari:blockSelf.announcement.commentFeedOpensInSafari];
    };
    [commentNode setDisclosureStyle:OptionDisclosureStyleArrow];
    [nodes addObject:commentNode];
  }
  
  [nodes addObject:[SectionSpacerNode spacerNodeWithCustomHeight:40. decoration:SectionSpacerDecorationDot]];
  return nodes;
}

- (void)openUrl:(NSString *)url usingSafari:(BOOL)useSafari;
{
  if (useSafari)
  {
    [[UIApplication sharedApplication] openURL:url.URL];
    return;
  }
  
  [[NavigationManager shared] dismissModalView];
  [[NavigationManager shared] handleTapOnUrl:url fromController:nil];
}

- (void)coreTextURLPressed:(NSString *)url;
{
  [self openUrl:url usingSafari:NO];
}

+ (void)showLatest;
{
  if (![Announcement latestAnnouncement])
    return;
  
  AnnouncementViewController *controller = [[UNIVERSAL(AnnouncementViewController) alloc] initWithAnnouncement:[Announcement latestAnnouncement]];
  ABNavigationController *navController = [[ABNavigationController alloc] initWithRootViewController:controller];
  navController.modalPresentationStyle = UIModalPresentationFormSheet;
  [[NavigationManager shared] dismissModalView];
  [[NavigationManager mainViewController] presentViewController:navController animated:YES completion:nil];
}

@end
