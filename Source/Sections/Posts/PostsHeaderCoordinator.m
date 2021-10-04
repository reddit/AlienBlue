//
//  PostsHeaderCoordinator.m
//  AlienBlue
//
//  Created by J M on 10/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "PostsHeaderCoordinator.h"
#import "BarBackgroundLayer.h"
#import "UIActionSheet+BlocksKit.h"
#import "NavigationManager.h"
#import "Resources.h"
#import "PostsOrderToolbar.h"


@interface PostsHeaderCoordinator() <PostsOrderToolbarDelegate>

@property (nonatomic, strong) UIView *view;
@property (strong) JMTabView *orderSelectTabView;
@property (strong) NSString *sortOrder;
@property (strong) NSString *topTimespan;
@property (ab_block) ABAction executeOnChange;
- (JMTabView *)sortOrderSelectTabView;
- (void)layoutHeaderView;
@property (strong) PostsOrderToolbar *headerBar;

@property SubredditModFolder modFolderSelection;

// Search related properties
@property (strong) UIView *postSearchView;
@property (strong) UISearchBar *searchBar;
@property (strong) NSString *searchSortOrder;
@property (strong) NSString *searchQuery;
@property BOOL searchRestrictToSubreddit;
@property BOOL showingSearch;
@property BOOL showsModOptions;
- (UIView *)searchView;

//@property (strong) JMTabView *searchOrderSelectTabView;
//-(JMTabView *)createSearchSortOrderSelection;
@end

@implementation PostsHeaderCoordinator

@synthesize view = view_;
@synthesize orderSelectTabView = orderSelectTabView_;
@synthesize postSearchView = postSearchView_;
//@synthesize searchOrderSelectTabView = searchOrderSelectTabView_;

- (id)initWithDelegate:(id<PostsHeaderDelegate>)delegate onChange:(ABAction)executeOnChange;
{
    if ((self = [super init]))
    {
        self.delegate = delegate;
        self.executeOnChange = executeOnChange;
        self.sortOrder = kPostOrderHot;
        self.topTimespan = nil;
    }
    return self;
}

- (void)loadView
{
  self.headerBar = [[PostsOrderToolbar alloc] initWithFrame:CGRectMake(0, 0, self.delegate.tableView.bounds.size.width, 44.) delegate:self];
  self.view = self.headerBar;
//    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.delegate.tableView.bounds.size.width, 44.)];
//    self.view.backgroundColor = [UIColor clearColor];
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self.view addSubview:[self sortOrderSelectTabView]];
//    [self.view addSubview:[self searchView]];
//    [self layoutHeaderView];
}

- (void)layoutHeaderView;
{
    if (self.showingSearch)
    {
        self.orderSelectTabView.frame = CGRectOffset(self.view.bounds, -self.view.width, 0);
        self.orderSelectTabView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.postSearchView.frame = self.view.bounds;
        self.postSearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    else
    {
        self.postSearchView.frame = CGRectOffset(self.view.bounds, self.view.width, 0);
        self.postSearchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.orderSelectTabView.frame = self.view.bounds;
        self.orderSelectTabView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
}

- (UIView *)view;
{
    if (!view_)
    {
        [self loadView];
    }
    return view_;
}

#pragma mark -
#pragma mark - Sort Order Selection

- (void)changeSortOrderTo:(NSString *)sortOrder
{
    self.sortOrder = sortOrder;
    self.modFolderSelection = SubredditModFolderDefault;
    self.topTimespan = nil;
    [self.delegate updateNavbarTitle];
    [self.headerBar setButtonTitle:[self titleForPostsOrderToolbarButton] animated:YES];
    self.executeOnChange();
}

- (void)changeTopTimespanTo:(NSString *)timespan
{
    self.sortOrder = kPostOrderTop;
    self.modFolderSelection = SubredditModFolderDefault;
    self.topTimespan = timespan;
    [self.delegate updateNavbarTitle];
    [self.headerBar setButtonTitle:[self titleForPostsOrderToolbarButton] animated:YES];
    self.executeOnChange();
}

- (void)changeSearchSortOrderTo:(NSString *)searchSortOrder;
{
  self.searchSortOrder = searchSortOrder;
  self.modFolderSelection = SubredditModFolderDefault;
  [self.headerBar setButtonTitle:[self titleForPostsOrderToolbarButton] animated:YES];
  if (self.searchQuery && ![self.searchQuery isEmpty])
  {
    self.executeOnChange();
  }
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

-(JMTabView *)sortOrderSelectTabView;
{
    if (!orderSelectTabView_)
    {
        BSELF(PostsHeaderCoordinator);
        
        JMTabItem * hotItem = [JMTabItem tabItemWithTitle:@"Hot" icon:nil executeBlock:^{
            [blockSelf changeSortOrderTo:kPostOrderHot];
        }];
        
        JMTabItem * newItem = [JMTabItem tabItemWithTitle:@"New" icon:nil executeBlock:^{
            [blockSelf changeSortOrderTo:kPostOrderNew];
        }];
        
        JMTabItem * controversialItem = [JMTabItem tabItemWithTitle:@"Controversial" icon:nil executeBlock:^{
            [blockSelf changeSortOrderTo:kPostOrderControversial];
        }];
        
        JMTabItem * topItem = [JMTabItem tabItemWithTitle:@"Top" icon:nil executeBlock:^{
            [blockSelf showTopTimespanSelector];
        }];
        
        CGRect tabViewFrame = CGRectMake(0, 0, self.delegate.tableView.bounds.size.width, 44.);
        self.orderSelectTabView.clipsToBounds = YES;
        self.orderSelectTabView = [[JMTabView alloc] initWithFrame:tabViewFrame];
        BarBackgroundLayer * barBackground = [[BarBackgroundLayer alloc] init];
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

- (UIView *)searchView;
{
    if (!postSearchView_)
    {
        self.postSearchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.delegate.tableView.bounds.size.width, 44.)];
        self.postSearchView.backgroundColor = [UIColor lightGrayColor];
        self.postSearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        self.searchBar = [[UISearchBar alloc] initWithFrame:self.postSearchView.bounds];
        self.searchBar.tintColor = [UIColor colorForTint];
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.postSearchView addSubview:self.searchBar];
        self.searchBar.delegate = self;
        
        self.searchBar.showsSearchResultsButton = YES;
    }
    return postSearchView_;
}

#pragma mark -
#pragma mark - Search Bar Delegates

- (void)handleScrolling;
{
  if (self.showingSearch)
  {
    [self.headerBar cancelActiveSearch];
  }
//    if (self.showingSearch && self.searchBar.isFirstResponder)
//    {
//        if ([self.searchBar.text isEmpty])
//            [self hideSearch];
//        else
//            [self.searchBar resignFirstResponder];
//    }
}

- (void)hideSearch;
{
    self.showingSearch = NO;
//    BSELF(PostsHeaderCoordinator);
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        blockSelf.postSearchView.height = 44.;
//        blockSelf.searchBar.height = 44.;
//        [blockSelf.searchBar layoutSubviews];
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.7 animations:^{
//            blockSelf.searchBar.showsCancelButton = NO;
//            [blockSelf.searchBar resignFirstResponder];
//            [blockSelf layoutHeaderView];
//        }];
//    }];
  
  [self.delegate updateNavbarTitle];
  [self.delegate updateNavbarIcons];
}

- (void)showSearch;
{
    self.showingSearch = YES;
//    BSELF(PostsHeaderCoordinator);
//    [UIView animateWithDuration:0.7 animations:^{
//        [blockSelf layoutHeaderView];
//    } completion:^(BOOL finished) {
//        [blockSelf.searchBar becomeFirstResponder];
//    }];
  
    [self.headerBar focusOnSearchField];
    [self.delegate updateNavbarTitle];
    [self.delegate updateNavbarIcons];
}

- (void)setShowSearchScopeBar:(BOOL)show;
{
    BSELF(PostsHeaderCoordinator);
    
    if ([blockSelf.searchBar.scopeButtonTitles count] < 2)
        return;
  
    CGFloat searchBarHeight = show ? 88. : 44.;
    [blockSelf.searchBar setShowsScopeBar:show];
    [UIView animateWithDuration:0.3 animations:^{
        blockSelf.searchBar.height = searchBarHeight;
        blockSelf.postSearchView.height =  blockSelf.searchBar.height;
        blockSelf.view.height = blockSelf.searchBar.height;
        [blockSelf.searchBar layoutSubviews];
    } completion:^(BOOL finished) {
//        [blockSelf.searchBar sizeToFit];
    }];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar;
{
//    searchSortOrder
    BSELF(PostsHeaderCoordinator);
    UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"Search by"];

    [sheet bk_addButtonWithTitle:@"Relevance" handler:^{
        blockSelf.searchSortOrder = kPostSearchOrderRelevance;
    }];
    
    [sheet bk_addButtonWithTitle:@"Newest" handler:^{
        blockSelf.searchSortOrder = kPostSearchOrderNew;
    }];
    
    [sheet bk_addButtonWithTitle:@"Top Scoring" handler:^{
        blockSelf.searchSortOrder = kPostSearchOrderTop;
    }];
    
    if ([Resources isIPAD])
    {
        [sheet showFromRect:CGRectMake(searchBar.right - 106., -1., 30., searchBar.height - 12.) inView:self.view animated:YES];
    }
    else
    {
        [searchBar resignFirstResponder];
        [sheet jm_showInView:[NavigationManager mainView]];
    }
}

- (void)searchBar:(UISearchBar *)sbar textDidChange:(NSString *)searchText;
{
    [self setShowSearchScopeBar:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)sbar
{
    sbar.showsCancelButton = YES;

    // initialise scope selector
    sbar.showsScopeBar = YES;
    NSMutableArray *scopes = [NSMutableArray array];
    [scopes addObject:@"All Subreddits"];
    if (![self.delegate.subreddit isEmpty] && ![self.delegate.subreddit equalsString:@"/r/all/"] && ![self.delegate.subreddit contains:@"/user/"])
    {
        [scopes addObject:self.delegate.subredditTitle];
//        [scopes addObject:[self.delegate.subreddit convertToSubredditTitle]];
    }
	[sbar setScopeButtonTitles:scopes];

    if (![sbar.text isEmpty])
    {
        [self setShowSearchScopeBar:YES];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)sbar
{
    [self setShowSearchScopeBar:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sbar
{
    [self hideSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sbar
{
    [sbar resignFirstResponder];
    if (!self.searchSortOrder || [self.searchSortOrder isEmpty])
    {
        self.searchSortOrder = kPostSearchOrderRelevance;
    }
    self.searchQuery = sbar.text;
    self.searchRestrictToSubreddit = sbar.selectedScopeButtonIndex > 0;
    self.executeOnChange();
}

//-(JMTabView *)createSearchSortOrderSelection;
//{
//    if (!searchOrderSelectTabView_)
//    {
//        
//        JMTabItem * relevanceItem = [JMTabItem tabItemWithTitle:@"Relevance" icon:nil executeBlock:^{
//            [blockSelf changeSortOrderTo:kPostSearchOrderRelevance];
//        }];
//        
//        JMTabItem * newItem = [JMTabItem tabItemWithTitle:@"New" icon:nil executeBlock:^{
//            [blockSelf changeSortOrderTo:kPostSearchOrderNew];
//        }];
//        
//        JMTabItem * topItem = [JMTabItem tabItemWithTitle:@"Top" icon:nil executeBlock:^{
//            [blockSelf changeSortOrderTo:kPostSearchOrderTop];
//        }];
//        
//        CGRect tabViewFrame = CGRectMake(0, 0, self.delegate.tableView.bounds.size.width, 48.);
//        self.searchOrderSelectTabView.clipsToBounds = YES;
//        self.searchOrderSelectTabView = [[JMTabView alloc] initWithFrame:tabViewFrame];
//        BarBackgroundLayer * barBackground = [[BarBackgroundLayer alloc] init];
//        barBackground.frame = CGRectMake(0, 0, self.delegate.tableView.bounds.size.width * 2, 48.);
//        [barBackground setMasksToBounds:YES];
//        
//        [self.searchOrderSelectTabView setBackgroundLayer:barBackground];
//        [self.searchOrderSelectTabView addTabItem:relevanceItem];
//        [self.searchOrderSelectTabView addTabItem:newItem];
//        [self.searchOrderSelectTabView addTabItem:topItem];
//        
//        [self.searchOrderSelectTabView setSelectedIndex:0];
//    }
//    return searchOrderSelectTabView_;
//}


- (void)showSelectionSheetWithTitle:(NSString *)title options:(NSArray *)options onComplete:(void(^)(NSString *chosenOption))onComplete;
{
  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:title];
  [options each:^(NSString *option) {
    NSString *optionTitle = [option capitalizedString];
    [actionSheet bk_addButtonWithTitle:optionTitle handler:^{
      onComplete(option);
    }];
  }];
  [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [actionSheet jm_showInView:[NavigationManager mainView]];
}

#pragma mark - Posts Header Toolbar Delegate

- (NSString *)titleForPostsOrderToolbarButton;
{
  NSString *buttonTitle = self.showingSearch ? self.searchSortOrder : self.sortOrder;
  if (!buttonTitle || [buttonTitle isEmpty])
  {
    buttonTitle = self.showingSearch ? kPostSearchOrderRelevance : @"hot";
  }
  
  buttonTitle = [buttonTitle capitalizedString];
  return buttonTitle;
}

- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar willChangeSearchActive:(BOOL)searchActive animated:(BOOL)animated;
{
  self.searchQuery = nil;
  self.showingSearch = searchActive;
  [postsOrderToolbar setButtonTitle:[self titleForPostsOrderToolbarButton] animated:animated];
}

- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar didChangeSearchActive:(BOOL)searchActive animated:(BOOL)animated;
{
  if (searchActive)
  {
    [self showSearch];
  }
  else
  {
    [self hideSearch];
  }
}

- (void)showTopTimespanSelector;
{
  BSELF(PostsHeaderCoordinator);
  NSArray *timelineOptions = @[kPostTopTimespanAll,
                               kPostTopTimespanHour,
                               kPostTopTimespanToday,
                               kPostTopTimespanWeek,
                               kPostTopTimespanMonth,
                               kPostTopTimespanYear,
                               ];
  [self showSelectionSheetWithTitle:@"Top Scoring of ..." options:timelineOptions onComplete:^(NSString *chosenOption) {
    [blockSelf changeTopTimespanTo:chosenOption];
//    [blockSelf.headerBar setButtonTitle:[blockSelf titleForPostsOrderToolbarButton] animated:YES];
  }];
}

- (void)showModFolderOptions;
{
  [UDefaults setBool:YES forKey:kPostsOrderToolbarTrainingHasTappedModButtonPrefKey];
  [self.headerBar respondToStyleChangeNotification];
  
  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Moderation"];
  BSELF(PostsHeaderCoordinator);
  [actionSheet bk_addButtonWithTitle:@"Mod Queue" handler:^{
    [blockSelf changeModerationFolderTo:SubredditModFolderModQueue];
  }];
  
  [actionSheet bk_addButtonWithTitle:@"Reported" handler:^{
    [blockSelf changeModerationFolderTo:SubredditModFolderReported];
  }];

  [actionSheet bk_addButtonWithTitle:@"Removed" handler:^{
    [blockSelf changeModerationFolderTo:SubredditModFolderRemoved];
  }];

  [actionSheet bk_addButtonWithTitle:@"Unmoderated" handler:^{
    [blockSelf changeModerationFolderTo:SubredditModFolderUnmoderated];
  }];
  
  [actionSheet bk_addButtonWithTitle:@"Manage Templates" handler:^{
    [[NavigationManager shared] showModerationTemplateManagement];
  }];

  [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [actionSheet jm_showInView:[NavigationManager mainView]];
}

- (void)showSortOrderOptions;
{
  BSELF(PostsHeaderCoordinator);
  
  NSArray *standardSortOptions = @[@"hot",
                                   kPostOrderNew,
                                   kPostOrderControversial,
                                   ];
  
  UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@""];
  [standardSortOptions each:^(NSString *option) {
    NSString *optionTitle = [option capitalizedString];
    [actionSheet bk_addButtonWithTitle:optionTitle handler:^{
      [blockSelf changeSortOrderTo:option];
    }];
  }];
  
  [actionSheet bk_addButtonWithTitle:@"Top" handler:^{
    [blockSelf showTopTimespanSelector];
  }];
  
  if (self.showsModOptions)
  {
    [actionSheet bk_setDestructiveButtonWithTitle:@"Moderation" handler:^{
      [blockSelf showModFolderOptions];
    }];
  }
  
  [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
  [actionSheet jm_showInView:[NavigationManager mainView]];
}

- (void)showSearchOptions;
{
  BSELF(PostsHeaderCoordinator);
  NSArray *options = @[kPostSearchOrderRelevance, kPostSearchOrderNew, kPostSearchOrderTop, kPostSearchOrderComments];
  [self showSelectionSheetWithTitle:@"Sort by..." options:options onComplete:^(NSString *chosenOption) {
    [blockSelf changeSearchSortOrderTo:chosenOption];
  }];
}

- (BOOL)modFeaturesEnabled;
{
  return self.showsModOptions;
}

- (void)enableModFeatures;
{
  self.showsModOptions = YES;
  [self.headerBar setButtonTitle:[self titleForPostsOrderToolbarButton] animated:YES];
}

- (void)postsOrderToolbarDidTapModerationButton:(PostsOrderToolbar *)postsOrderToolbar;
{
  [self showModFolderOptions];
}

- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar didTapOrderButtonWithSearchActive:(BOOL)searchActive;
{
  if (searchActive)
  {
    [self showSearchOptions];
  }
  else
  {
    [self showSortOrderOptions];
  }
  
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
  
  
//  [self showSelectionSheetWithTitle:title options:sortOptions onComplete:^(NSString *chosenOption) {
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
////    [postsOrderToolbar setButtonTitle:[blockSelf titleForPostsOrderToolbarButton] animated:YES];
//  }];
}

- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar didEnterSearchQuery:(NSString *)searchQuery;
{
  if (!self.searchSortOrder || [self.searchSortOrder isEmpty])
  {
    self.searchSortOrder = kPostSearchOrderRelevance;
  }
  
  if ([Resources safeFilter])
  {
    if (
        [searchQuery contains:@"sex"] ||
        [searchQuery contains:@"tits"] ||
        [searchQuery contains:@"fuck"] ||
        [searchQuery contains:@"vagina"] ||
        [searchQuery contains:@"penis"] ||
        [searchQuery contains:@"nsfw"] ||
        [searchQuery contains:@"anal"] ||
        [searchQuery contains:@"nude"] ||
        [searchQuery contains:@"cock"] ||
        [searchQuery contains:@"boobs"] ||
        [searchQuery contains:@"naked"] ||
        [searchQuery contains:@"porn"] ||
        [searchQuery contains:@"xxx"]
        )
    {
      searchQuery = @"";
    }
  }
  
  self.searchQuery = searchQuery;
  self.executeOnChange();
}

- (BOOL)postsOrderToolbarShouldShowScopeIcon:(PostsOrderToolbar *)postsOrderToolbar;
{
  return (![self.delegate.subreddit isEmpty] && ![self.delegate.subreddit equalsString:@"/r/all/"] && ![self.delegate.subreddit contains:@"/user/"]);
}

- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar didChangeScopeRestriction:(BOOL)restrictScope;
{
  self.searchRestrictToSubreddit = restrictScope;
  [self.delegate updateNavbarTitle];
  if (self.searchQuery && ![self.searchQuery isEmpty])
  {
    self.executeOnChange();
  }
}

- (BOOL)postsOrderToolbarShouldShowModerationIcon:(PostsOrderToolbar *)postsOrderToolbar;
{
  return self.showsModOptions;
}

@end
