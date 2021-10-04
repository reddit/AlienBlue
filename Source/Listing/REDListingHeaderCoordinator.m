//  REDListingHeaderCoordinator.m
//  RedditApp

#import "RedditApp/Listing/REDListingHeaderCoordinator.h"

#import <BlocksKit/UIActionSheet+BlocksKit.h>

#import "Common/Navigation/NavigationManager.h"
#import "Helpers/Resources.h"
#import "JMTabView/JMTabView/Classes/Subviews/Layers/BarBackgroundLayer.h"
#import "RedditApp/Listing/REDListingOrderToolbar.h"

@interface REDListingHeaderCoordinator ()<REDListingOrderToolbarDelegate>

@property(nonatomic, strong) UIView *view;
@property(strong) JMTabView *orderSelectTabView;
@property(strong) NSString *sortOrder;
@property(strong) NSString *topTimespan;
@property(ab_block) ABAction executeOnChange;
- (JMTabView *)sortOrderSelectTabView;
- (void)layoutHeaderView;
@property(strong) REDListingOrderToolbar *headerBar;

@property SubredditModFolder modFolderSelection;
@property BOOL showsModOptions;

@end

@implementation REDListingHeaderCoordinator

@synthesize view = view_;
@synthesize orderSelectTabView = orderSelectTabView_;
//@synthesize searchOrderSelectTabView = searchOrderSelectTabView_;

- (id)initWithDelegate:(id<REDPostsHeaderDelegate>)delegate onChange:(ABAction)executeOnChange;
{
  if ((self = [super init])) {
    self.delegate = delegate;
    self.executeOnChange = executeOnChange;
    self.sortOrder = kPostOrderHot;
    self.topTimespan = nil;
  }
  return self;
}

- (void)loadView {
  self.headerBar = [[REDListingOrderToolbar alloc]
      initWithFrame:CGRectMake(0, 0, self.delegate.tableView.bounds.size.width, 44.)
           delegate:self];
  self.view = self.headerBar;
  //    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
  //    self.delegate.tableView.bounds.size.width, 44.)];
  //    self.view.backgroundColor = [UIColor clearColor];
  //    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  //    [self.view addSubview:[self sortOrderSelectTabView]];
  //    [self.view addSubview:[self searchView]];
  //    [self layoutHeaderView];
}

- (void)layoutHeaderView;
{
  self.orderSelectTabView.frame = self.view.bounds;
  self.orderSelectTabView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (UIView *)view;
{
  if (!view_) {
    [self loadView];
  }
  return view_;
}

#pragma mark -
#pragma mark - Sort Order Selection

- (void)changeSortOrderTo:(NSString *)sortOrder {
  self.sortOrder = sortOrder;
  self.modFolderSelection = SubredditModFolderDefault;
  self.topTimespan = nil;
  [self.delegate updateNavbarTitle];
  [self.headerBar setButtonTitle:[self titleForREDListingOrderToolbarButton] animated:YES];
  self.executeOnChange();
}

- (void)changeTopTimespanTo:(NSString *)timespan {
  self.sortOrder = kPostOrderTop;
  self.modFolderSelection = SubredditModFolderDefault;
  self.topTimespan = timespan;
  [self.delegate updateNavbarTitle];
  [self.headerBar setButtonTitle:[self titleForREDListingOrderToolbarButton] animated:YES];
  self.executeOnChange();
}

- (void)changeModerationFolderTo:(SubredditModFolder)modFolderSelection;
{
  self.modFolderSelection = modFolderSelection;
  self.sortOrder = @"";
  NSString *buttonTitle = @"";
  switch (modFolderSelection) {
    case SubredditModFolderModQueue:
      buttonTitle = @"Mod Queue";
      break;
    case SubredditModFolderReported:
      buttonTitle = @"Reported";
      break;
    case SubredditModFolderRemoved:
      buttonTitle = @"Removed";
      break;
    case SubredditModFolderUnmoderated:
      buttonTitle = @"Unmoderated";
      break;
    default:
      break;
  }
  [self.headerBar setButtonTitle:buttonTitle animated:YES];
  [self.delegate updateNavbarTitle];
  self.executeOnChange();
}

- (JMTabView *)sortOrderSelectTabView;
{
  if (!orderSelectTabView_) {
    BSELF(REDListingHeaderCoordinator);

    JMTabItem *hotItem =
        [JMTabItem tabItemWithTitle:@"Hot"
                               icon:nil
                       executeBlock:^{ [blockSelf changeSortOrderTo:kPostOrderHot]; }];

    JMTabItem *newItem =
        [JMTabItem tabItemWithTitle:@"New"
                               icon:nil
                       executeBlock:^{ [blockSelf changeSortOrderTo:kPostOrderNew]; }];

    JMTabItem *controversialItem =
        [JMTabItem tabItemWithTitle:@"Controversial"
                               icon:nil
                       executeBlock:^{ [blockSelf changeSortOrderTo:kPostOrderControversial]; }];

    JMTabItem *topItem = [JMTabItem tabItemWithTitle:@"Top"
                                                icon:nil
                                        executeBlock:^{ [blockSelf showTopTimespanSelector]; }];

    CGRect tabViewFrame = CGRectMake(0, 0, self.delegate.tableView.bounds.size.width, 44.);
    self.orderSelectTabView.clipsToBounds = YES;
    self.orderSelectTabView = [[JMTabView alloc] initWithFrame:tabViewFrame];
    BarBackgroundLayer *barBackground = [[BarBackgroundLayer alloc] init];
    barBackground.frame = CGRectMake(0, 0, self.delegate.tableView.bounds.size.width * 2, 44.);
    [barBackground setMasksToBounds:YES];

    [self.orderSelectTabView setBackgroundLayer:barBackground];
    [self.orderSelectTabView addTabItem:hotItem];
    [self.orderSelectTabView addTabItem:newItem];
    [self.orderSelectTabView addTabItem:controversialItem];
    [self.orderSelectTabView addTabItem:topItem];

    [self.orderSelectTabView setSelectedIndex:0];
  }
  return orderSelectTabView_;
}

- (void)showSelectionSheetWithTitle:(NSString *)title
                            options:(NSArray *)options
                         onComplete:(void (^)(NSString *chosenOption))onComplete;
{
  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:title];
  [options each:^(NSString *option) {
      NSString *optionTitle = [option capitalizedString];
      [actionSheet bk_addButtonWithTitle:optionTitle handler:^{ onComplete(option); }];
  }];
  [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [actionSheet jm_showInView:[NavigationManager mainView]];
}

#pragma mark - Posts Header Toolbar Delegate

- (NSString *)titleForREDListingOrderToolbarButton;
{
  NSString *buttonTitle = self.sortOrder;
  if (!buttonTitle || [buttonTitle isEmpty]) {
    buttonTitle = @"hot";
  }

  buttonTitle = [buttonTitle capitalizedString];
  return buttonTitle;
}

- (void)showTopTimespanSelector;
{
  BSELF(REDListingHeaderCoordinator);
  NSArray *timelineOptions = @[
    kPostTopTimespanAll,
    kPostTopTimespanHour,
    kPostTopTimespanToday,
    kPostTopTimespanWeek,
    kPostTopTimespanMonth,
    kPostTopTimespanYear,
  ];
  [self showSelectionSheetWithTitle:@"Top Scoring of ..."
                            options:timelineOptions
                         onComplete:^(NSString *chosenOption) {
                             [blockSelf changeTopTimespanTo:chosenOption];
                             //    [blockSelf.headerBar setButtonTitle:[blockSelf
                             //    titleForREDListingOrderToolbarButton] animated:YES];
                         }];
}

- (void)showModFolderOptions;
{
  [UDefaults setBool:YES forKey:kREDListingOrderToolbarTrainingHasTappedModButtonPrefKey];
  [self.headerBar respondToStyleChangeNotification];

  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Moderation"];
  BSELF(REDListingHeaderCoordinator);
  [actionSheet
      bk_addButtonWithTitle:@"Mod Queue"
                    handler:^{ [blockSelf changeModerationFolderTo:SubredditModFolderModQueue]; }];

  [actionSheet
      bk_addButtonWithTitle:@"Reported"
                    handler:^{ [blockSelf changeModerationFolderTo:SubredditModFolderReported]; }];

  [actionSheet
      bk_addButtonWithTitle:@"Removed"
                    handler:^{ [blockSelf changeModerationFolderTo:SubredditModFolderRemoved]; }];

  [actionSheet bk_addButtonWithTitle:@"Unmoderated"
                             handler:^{
                                 [blockSelf changeModerationFolderTo:SubredditModFolderUnmoderated];
                             }];

  [actionSheet
      bk_addButtonWithTitle:@"Manage Templates"
                    handler:^{ [[NavigationManager shared] showModerationTemplateManagement]; }];

  [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [actionSheet jm_showInView:[NavigationManager mainView]];
}

- (void)showSortOrderOptions;
{
  BSELF(REDListingHeaderCoordinator);

  NSArray *standardSortOptions = @[ @"hot", kPostOrderNew, kPostOrderControversial, ];

  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@""];
  [standardSortOptions each:^(NSString *option) {
      NSString *optionTitle = [option capitalizedString];
      [actionSheet bk_addButtonWithTitle:optionTitle
                                 handler:^{ [blockSelf changeSortOrderTo:option]; }];
  }];

  [actionSheet bk_addButtonWithTitle:@"Top" handler:^{ [blockSelf showTopTimespanSelector]; }];

  if (self.showsModOptions) {
    [actionSheet bk_setDestructiveButtonWithTitle:@"Moderation"
                                          handler:^{ [blockSelf showModFolderOptions]; }];
  }

  [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [actionSheet jm_showInView:[NavigationManager mainView]];
}

- (BOOL)modFeaturesEnabled;
{ return self.showsModOptions; }

- (void)enableModFeatures;
{
  self.showsModOptions = YES;
  [self.headerBar setButtonTitle:[self titleForREDListingOrderToolbarButton] animated:YES];
}

- (void)listingOrderToolbarDidTapModerationButton:(REDListingOrderToolbar *)listingOrderToolbar;
{ [self showModFolderOptions]; }

- (void)listingOrderToolbar:(REDListingOrderToolbar *)listingOrderToolbar
    didTapOrderButtonWithSearchActive:(BOOL)searchActive;
{
  [self showSortOrderOptions];

  //  if (!searchActive && [chosenOption equalsString:kPostOrderTop])
  //  {
  //    [self showTopTimespanSelector];
  //  }
  //  else if (searchActive)
  //  {
  //    [self changeSearchSortOrderTo:chosenOption];
  //  }
  //  else
  //  {
  //    [self changeSortOrderTo:chosenOption];
  //  }

  //  [self showSelectionSheetWithTitle:title options:sortOptions onComplete:^(NSString
  //  *chosenOption) {
  //    if (!searchActive && [chosenOption equalsString:kPostOrderTop])
  //    {
  //      [blockSelf showTopTimespanSelector];
  //    }
  //    else if (searchActive)
  //    {
  //      [blockSelf changeSearchSortOrderTo:chosenOption];
  //    }
  //    else
  //    {
  //      [blockSelf changeSortOrderTo:chosenOption];
  //    }
  ////    [listingOrderToolbar setButtonTitle:[blockSelf titleForREDListingOrderToolbarButton]
  /// animated:YES];
  //  }];
}

- (BOOL)listingOrderToolbarShouldShowModerationIcon:(REDListingOrderToolbar *)listingOrderToolbar;
{ return self.showsModOptions; }

@end
