#import "SettingsViewController.h"
#import "NBaseOptionCell.h"
#import "ViewContainerCell.h"
#import "OptionCell.h"
#import "NSectionSpacerCell.h"
#import "UIImage+JMActionMenuAssets.h"

#import "JMOutlineViewController+CustomNavigationBar.h"
#import "MKStoreManager.h"
#import "Announcement.h"
#import "AnnouncementViewController.h"

@interface SettingsViewController ()
@property SettingsSection settingsSection;
@property (strong) LegacySettingsTableViewController *legacySettingsController;
@end

@implementation SettingsViewController

- (id)initWithSettingsSection:(SettingsSection)settingsSection;
{
  JM_SUPER_INIT(init);
  
  self.settingsSection = settingsSection;
  self.hidesBottomBarWhenPushed = YES;

  self.legacySettingsController = [LegacySettingsTableViewController new];
  [self addChildViewController:self.legacySettingsController];
  
  return self;
}

- (NSArray *)generateNodesForSettingSection:(SettingsSection)settingsSection;
{
  NSMutableArray *nodes = [NSMutableArray new];
  
  NSUInteger sectionIndex = settingsSection;
  NSUInteger numberOfRowsInSection = [self.legacySettingsController.tableView numberOfRowsInSection:sectionIndex];
  
  for (NSUInteger i=0; i<numberOfRowsInSection; i++)
  {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
    [nodes addObject:[self generateContainerNodeForCellAtIndexPath:indexPath]];
  }
  
  BSELF(SettingsViewController);
  NSArray *subsectionOptionNodes = [[self.legacySettingsController relatedSubsectionsForSettingSection:settingsSection] map:^id(NSNumber *relatedSectionIndexNumber) {
    SettingsSection relatedSection = relatedSectionIndexNumber.integerValue;
    return [blockSelf generateSectionSelectorNodeForSettingsSection:relatedSection];
  }];
  
  if (subsectionOptionNodes.count > 0)
  {
    [nodes addObject:[SectionSpacerNode spacerNodeWithCustomHeight:20. decoration:SectionSpacerDecorationNone]];
    [nodes addObjectsFromArray:subsectionOptionNodes];
  }
  
  return nodes;
}

- (void)generateNodes
{
  if (self.settingsSection == SettingsSectionHome)
  {
    NSArray *homeNodes = [self generateNodesForHomeScreen];
    [self removeAllNodes];
    [self addNodes:homeNodes];
    [self reload];
    return;
  }
  
  [self removeAllNodes];

  NSArray *sectionNodes = [self generateNodesForSettingSection:self.settingsSection];
  
  [self addNodes:sectionNodes];
  [self reload]; 
}

- (ViewContainerNode *)generateContainerNodeForCellAtIndexPath:(NSIndexPath *)indexPath;
{
  OptionCell *cell = (OptionCell *)[self.legacySettingsController tableView:self.legacySettingsController.tableView cellForRowAtIndexPath:indexPath];
  cell.optionCellView.height = 48.;
  ViewContainerNode *node = [[ViewContainerNode alloc] initWithView:cell.optionCellView];
  node.resizesToFitCell = YES;
  return node;
}

- (void)loadView;
{
  [super loadView];
  
  [self.legacySettingsController loadView];
  [self.legacySettingsController viewDidLoad];
  [self.legacySettingsController generateOptions];

  BSELF(SettingsViewController);
  self.legacySettingsController.onTableReloadAction = ^{
    [blockSelf generateNodes];
    [blockSelf respondToStyleChange];
  };
  
  self.legacySettingsController.onProUpgradeStopPurchaseIndicator = ^{
    [blockSelf.navigationController popToRootViewControllerAnimated:YES];
    [blockSelf generateNodes];
  };
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
  [self generateNodes];
  [self setNavbarTitle:[self.legacySettingsController legacy_titleForSection:self.settingsSection]];
}

+ (void)toggleNightTheme;
{
  [LegacySettingsTableViewController toggleNightTheme];
}

- (NSMutableArray *)generateNodesForHomeScreen;
{
  NSMutableArray *nodes = [NSMutableArray new];

  CGFloat spacerHeight = 20.;
  #define ADD_SECTION_SPACING [nodes addObject:[SectionSpacerNode spacerNodeWithCustomHeight:spacerHeight decoration:SectionSpacerDecorationNone]];
  
  OptionNode *proUpgradeNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionUpgradePro];
  OptionNode *redditAccountsNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionRedditAccounts];
  OptionNode *appearanceNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionDisplay];
  OptionNode *behaviorNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionBehavior];
  OptionNode *postsNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionPosts];
  OptionNode *commentsNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionComments];
  OptionNode *messagesNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionMessages];
  OptionNode *imgurNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionImgur];
  OptionNode *advancedNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionAdvanced];
  OptionNode *contactNode = [self generateSectionSelectorNodeForSettingsSection:SettingsSectionContact];
  
  if (![MKStoreManager isProUpgraded])
  {
    [nodes addObject:proUpgradeNode];
    proUpgradeNode.hidesDivider = YES;
    proUpgradeNode.bold = YES;
    UIColor *highlightColor = [UIColor colorForHighlightedOptions];
    proUpgradeNode.titleColor = highlightColor;
    proUpgradeNode.icon = [UIImage jm_coloredImageFromImage:proUpgradeNode.icon fillColor:highlightColor];
    if (!JMIsEmpty([MKStoreManager proUpgradePriceInfo]))
    {
      proUpgradeNode.valueTitle = [MKStoreManager proUpgradePriceInfo];
    }
    ADD_SECTION_SPACING;
  }
  
  [nodes addObject:redditAccountsNode];
  [nodes addObject:appearanceNode];
  [nodes addObject:behaviorNode];
  behaviorNode.hidesDivider = YES;
  ADD_SECTION_SPACING;
  
  [nodes addObject:postsNode];
  [nodes addObject:commentsNode];
  [nodes addObject:messagesNode];
  messagesNode.hidesDivider = YES;
  ADD_SECTION_SPACING;
  
  [nodes addObject:imgurNode];
  [nodes addObject:advancedNode];
  
  [nodes addObject:contactNode];
  contactNode.hidesDivider = YES;
  
  ADD_SECTION_SPACING;
  
  if ([Announcement latestAnnouncement] != nil)
  {
    OptionNode *announcementNode = [OptionNode new];
    announcementNode.title = @"Latest Announcement";
    announcementNode.icon = [UIImage actionMenuIconWithName:@"am-icon-posts-sidebar" fillColor:[UIColor colorForAccessoryButtons]];
    [announcementNode setDisclosureStyle:OptionDisclosureStyleArrow];
    BSELF(SettingsViewController);
    announcementNode.onSelect = ^{
      [blockSelf showLatestAnnouncement];
    };
    announcementNode.hidesDivider = YES;
    [nodes addObject:announcementNode];
    ADD_SECTION_SPACING;
  }
  
  return nodes;
}

- (OptionNode *)generateSectionSelectorNodeForSettingsSection:(SettingsSection)settingsSection;
{
  OptionNode *sectionSelectorNode = [OptionNode new];
  sectionSelectorNode.title = [self.legacySettingsController legacy_titleForSection:settingsSection];
  sectionSelectorNode.icon = [UIImage skinIcon:[self.legacySettingsController iconNameForSettingSection:settingsSection] withColor:[UIColor colorForAccessoryButtons]];
  [sectionSelectorNode setDisclosureStyle:OptionDisclosureStyleArrow];
  BSELF(SettingsViewController);
  sectionSelectorNode.onSelect = ^{
    [blockSelf navigateToSettingsSection:settingsSection];
  };
  return sectionSelectorNode;
}

- (void)showLatestAnnouncement;
{
  AnnouncementViewController *controller = [[AnnouncementViewController alloc] initWithAnnouncement:[Announcement latestAnnouncement]];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)navigateToSettingsSection:(SettingsSection)settingsSection;
{
  SettingsViewController *controller = [[SettingsViewController alloc] initWithSettingsSection:settingsSection];
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Cell Editing Support

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSIndexPath *legacyIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.settingsSection];
  return [self.legacySettingsController legacy_canEditRowAtIndexPath:legacyIndexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSIndexPath *legacyIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.settingsSection];
  return [self.legacySettingsController legacy_commitEditingStyle:editingStyle forRowAtIndexPath:legacyIndexPath];
}

@end
