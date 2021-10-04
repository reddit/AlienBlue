#import "TemplatesViewController.h"
#import "TemplateCell.h"

#import "TemplateDetailViewController.h"
#import "TemplateToken.h"
#import "TransparentToolbar.h"
#import "BlocksKit.h"
#import "NCenteredTextCell.h"
#import "ABButton.h"
#import "SessionManager.h"

#define kTemplatesViewControllerEditButtonOffset JMIsIOS7() ? CGSizeMake(16., 3.) : CGSizeMake(0., 3.)

@interface TemplatesViewController()
@property (strong) TemplatePrefs *tPrefs;
@property (strong) TemplateGroup *group;
@end

@implementation TemplatesViewController

- (id)init;
{
  self = [super init];
  if (self)
  {
    [self commonInitializerSetup];
    self.group = [self.tPrefs removalGroup];
  }
  return self;
}

- (id)initWithDefaultGroupIdent:(NSString *)groupIdent;
{
  self = [super init];
  if (self)
  {
    [self commonInitializerSetup];
    self.group = [self.tPrefs templateGroupMatchingIdent:groupIdent];
  }
  return self;
}

- (void)commonInitializerSetup;
{
  [self setNavbarTitle:@"Manage Templates"];
  self.tPrefs = [SessionManager manager].sharedTemplatePrefs;
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.navigationItem.leftBarButtonItem = [UIBarButtonItem skinBarItemWithTitle:@"Close" target:self action:@selector(dismissMe)];
  
  
//  [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissMe)];
}

- (void)updateEditIconInCustomNavigationBar;
{
  BSELF(TemplatesViewController);
  NSString *title = self.tableView.isEditing ? @"Done" : @"Edit";
  ABCustomOutlineNavigationBar *customNavigationBar = (ABCustomOutlineNavigationBar *)self.attachedCustomNavigationBar;
  [customNavigationBar setCustomLeftButtonWithTitle:title onTapAction:^{
    if (blockSelf.tableView.isEditing)
    {
      [blockSelf.tableView setEditing:NO animated:YES];
      [blockSelf updateEditIconInCustomNavigationBar];
    }
    else
    {
      [blockSelf.tableView setEditing:YES animated:YES];
      [blockSelf updateEditIconInCustomNavigationBar];
    }
  }];
}

- (void)loadView;
{
  [super loadView];
//  [self updateEditIconInCustomNavigationBar];
}


- (void)reloadTemplatePreferences;
{
  self.tPrefs = [SessionManager manager].sharedTemplatePrefs;
  self.group = [self.tPrefs templateGroupMatchingIdent:self.group.ident];
  [self animateNodeChanges];
}

- (void)dismissMe;
{
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  if (self.onDismiss)
  {
    self.onDismiss();
  }
}

- (NSArray *)tokensWhenEditing;
{
  NSMutableArray *tokens = [NSMutableArray array];
  BSELF(TemplatesViewController);
  #define ADD_TOKEN(IDENT, TITLE, REPLACE_WITH) [tokens addObject:[[TemplateToken alloc] initWithTokenIdent:IDENT title:TITLE tokenReplacer:^NSString *{ return REPLACE_WITH; }]];
  ADD_TOKEN(@"poster_username", @"Poster's Username", blockSelf.tokenReplacerPosterUsername);
  ADD_TOKEN(@"post_url", @"Link to Post", blockSelf.tokenReplacerLinkToPost);
  ADD_TOKEN(@"subreddit_link", @"Link to Subreddit", blockSelf.tokenReplacerLinkToSubreddit);
  ADD_TOKEN(@"sidebar_link", @"Link to Sidebar", blockSelf.tokenReplacerLinkToSidebar);
  ADD_TOKEN(@"wiki_url", @"Link to Wiki", blockSelf.tokenReplacerLinkToWiki);
  ADD_TOKEN(@"moderator_username", @"My Username", blockSelf.tokenReplacerModeratorUsername);
  return tokens;
}

- (void)didSelectTemplate:(Template *)tPlate;
{
  BSELF(TemplatesViewController);
  NSArray *tokens = [self tokensWhenEditing];
  TemplateDetailViewController *controller = [[TemplateDetailViewController alloc] initWithTemplate:tPlate mode:TemplateDetailModeTemplateEdit tokens:tokens];
  controller.onTemplateEditComplete = ^(NSString *templateTitle, NSString *body, TemplateSendPreference sendPreference) {
    [blockSelf.navigationController popViewControllerAnimated:YES];
    tPlate.body = body;
    tPlate.title = templateTitle;
    tPlate.stockTemplate = NO;
    tPlate.sendPreference = sendPreference;
    [blockSelf.tPrefs save];
    [blockSelf animateNodeChanges];
    [blockSelf.tPrefs recommendSyncToCloud];
  };
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - View Lifecycle

- (TemplateNode *)generateTemplateNodeForTemplate:(Template *)tPlate;
{
  BSELF(TemplatesViewController);
  TemplateNode *tNode = [[TemplateNode alloc] initWithTemplate:tPlate];
  tNode.editable = YES;
  tNode.onSelect = ^{
    [blockSelf didSelectTemplate:tPlate];
  };
  return tNode;
}

- (void)generateNodes;
{
  [self removeAllNodes];
  NSMutableArray *nodes = [NSMutableArray array];
  
  BSELF(TemplatesViewController);
    
  NSArray *templateNodes = [self.group.templates map:^id(Template *tPlate) {
    return [blockSelf generateTemplateNodeForTemplate:tPlate];
  }];
  
  [nodes addObjectsFromArray:templateNodes];
  [self addNodes:nodes];
  [self reload];
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
  [self disableEditMode];
  [self updateViewWithCurrentGroupSelection];
}

#pragma mark - Switching Groups

- (void)updateViewWithCurrentGroupSelection;
{
  NSString *buttonTitle = (self.group == self.tPrefs.removalGroup) ? @" Removing Posts" : @" Approving Posts";
//  NSString *buttonTitle = [NSString stringWithFormat:@"%@ Templates", self.group.title];
  UIImage *navButtonImage = [[UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
//    [[UIColor colorWithWhite:0. alpha:0.25] set];
//    [[UIColor colorForBarButtonItem] setFill];
//    [UIView startEtchedDraw];
    [[UIColor colorForBarButtonItem] setStroke];
    CGRect bgRect = CGRectOffset(CGRectInset(bounds, 2., 2.), 0., 0.);
    UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:bgRect cornerRadius:6.];
    roundPath.lineWidth = 0.5;
    [roundPath stroke];
//    [UIView endEtchedDraw];
    
    [[UIColor colorForBarButtonItem] set];
    [[UIBezierPath bezierPathWithTriangleCenter:CGPointMake(20., 14.) sideLength:7. angle:0.] fill];
  } withSize:CGSizeMake(50., 28.)] jm_resizeable];
  UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
  [b setBackgroundImage:navButtonImage forState:UIControlStateNormal];
  [b setTitle:buttonTitle forState:UIControlStateNormal];
  [b setTitleColor:[UIColor colorForBarButtonItem] forState:UIControlStateNormal];
//  [b setTitleShadowColor:[UIColor colorWithWhite:0. alpha:0.5] forState:UIControlStateNormal];
//  b.titleLabel.shadowOffset = CGSizeMake(0., -1.);
  b.titleLabel.font = [UIFont skinFontWithName:kBundleFontNavigationButtonTitle];
  b.titleEdgeInsets = UIEdgeInsetsMake(0., 15., 0., 15.);
  b.size = CGSizeMake(200., 28.);
  [b addTarget:self action:@selector(showTemplateGroupSelection) forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *groupItem = [[UIBarButtonItem alloc] initWithCustomView:b];
//  UIBarButtonItem *addTemplateItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAddTemplateButton)];
  UIBarButtonItem *addTemplateItem = [UIBarButtonItem skinBarItemWithIcon:@"ipad-add-icon" target:self action:@selector(didTapAddTemplateButton)];
  
//  UIBarButtonItem *groupItem = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(showTemplateGroupSelection)];
//  groupItem.tintColor = [UIColor colorWithHex:0x6d9f60];
  UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  UIBarButtonItem *leftPadding = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  UIBarButtonItem *rightPadding = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  leftPadding.width = 50.;
  rightPadding.width = -10.;
//  TransparentToolbar *tBar = [[TransparentToolbar alloc] initWithFrame:CGRectMake(0., 0., 200., 44)];
  self.toolbarItems = @[leftPadding, spaceItem,groupItem, spaceItem, addTemplateItem, rightPadding];
//  self.navigationItem.titleView = tBar;
  [self generateNodes];
}

- (void)showTemplateGroupSelection;
{
  BSELF(TemplatesViewController);
  UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"Choose template group"];
  [self.tPrefs.groups each:^(TemplateGroup *group) {
    [sheet bk_addButtonWithTitle:group.title handler:^{
      blockSelf.group = group;
      [blockSelf updateViewWithCurrentGroupSelection];
    }];
  }];
  [sheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [sheet showFromToolbar:self.navigationController.toolbar];
}

- (void)didTapAddTemplateButton;
{
  BSELF(TemplatesViewController);
  TemplateDetailViewController *controller = [[TemplateDetailViewController alloc] initWithTemplate:nil mode:TemplateDetailModeTemplateEdit tokens:[self tokensWhenEditing]];
  controller.defaultTemplateTitle = [NSString stringWithFormat:@"Template Title %d", (self.group.userCreatedTemplates.count + 1)];
  controller.onTemplateEditComplete = ^(NSString *templateTitle, NSString *body, TemplateSendPreference sendPreference)
  {
    [blockSelf.navigationController popViewControllerAnimated:YES];
    Template *t = [Template new];
    t.body = body;
    t.title = templateTitle;
    t.sendPreference = sendPreference;
    [blockSelf.tPrefs addTemplate:t toGroup:blockSelf.group];
    [blockSelf animateNodeChanges];
    [blockSelf.tPrefs recommendSyncToCloud];
  };
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Editing Support

- (void)animateNodeChanges;
{
  BSELF(TemplatesViewController);
  [UIView jm_transition:self.tableView animations:^{
    [blockSelf generateNodes];
  } completion:nil animated:YES];
}

- (void)enableEditMode;
{
  self.navigationItem.rightBarButtonItem = [UIBarButtonItem skinBarItemWithTitle:@"Done" textColor:nil fillColor:nil positionOffset:kTemplatesViewControllerEditButtonOffset target:self action:@selector(disableEditMode)];
  [self.tableView setEditing:YES animated:YES];
  [self updateEditIconInCustomNavigationBar];
}

- (void)disableEditMode;
{
  self.navigationItem.rightBarButtonItem = [UIBarButtonItem skinBarItemWithTitle:@"Edit" textColor:nil fillColor:nil positionOffset:kTemplatesViewControllerEditButtonOffset target:self action:@selector(enableEditMode)];
//  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(enableEditMode)];

  if (self.tableView.editing)
  {
    [self.tPrefs recommendSyncToCloud];
  }

  [self.tableView setEditing:NO animated:YES];
  [self updateEditIconInCustomNavigationBar];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	JMOutlineNode *node = [self nodeForRow:indexPath.row];
  return node.editable && [node isKindOfClass:[TemplateNode class]];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	JMOutlineNode *node = [self nodeForRow:indexPath.row];
  return node.editable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  TemplateNode *templateNode = (TemplateNode *)[self nodeForRow:indexPath.row];
  [self.tPrefs removeTemplate:templateNode.tPlate fromGroup:self.group];
  [self animateNodeChanges];
  [self.tPrefs recommendSyncToCloud];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TemplateNode *node = (TemplateNode *)[self nodeForRow:indexPath.row];
  if ([node isKindOfClass:[TemplateNode class]])
  {
    return UITableViewCellEditingStyleDelete;
  }
  
  return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
{
  if (proposedDestinationIndexPath.row < 0)
    return sourceIndexPath;
  
	JMOutlineNode *node = [self nodeForRow:proposedDestinationIndexPath.row];
  if (!node.editable)
  {
    return sourceIndexPath;
  }
  return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
  TemplateNode *fromNode = (TemplateNode *)[self nodeForRow:fromIndexPath.row];
  
  [self.group i_removeTemplate:fromNode.tPlate];
  
  NSUInteger moveToIndex = JM_LIMIT(0, self.nodeCount, toIndexPath.row);
  [self.group i_insertTemplate:fromNode.tPlate atIndex:moveToIndex];
  [self.tPrefs save];
  
  [self generateNodes];
  [self.tPrefs recommendSyncToCloud];
}

#pragma mark - Token Replacers

- (NSString *)tokenReplacerPosterUsername;
{
  return nil;
}

- (NSString *)tokenReplacerLinkToPost;
{
  return nil;
}

- (NSString *)tokenReplacerLinkToSubreddit;
{
  return nil;
}

- (NSString *)tokenReplacerLinkToSidebar;
{
  return nil;
}

- (NSString *)tokenReplacerLinkToWiki;
{
  return nil;
}

- (NSString *)tokenReplacerModeratorUsername;
{
  return nil;
}

@end
