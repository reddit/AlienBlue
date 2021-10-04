//  Copyright 2010 __MyCompanyName__. All rights reserved.

#import "OptionTableViewController.h"
#import "AlienBlueAppDelegate.h"
#import "OptionCell.h"
#import "Resources.h"
#import "TransparentCell.h"
#import "OptionCellView_iPad.h"

@interface OptionTableViewController()
@end

@implementation OptionTableViewController

@synthesize isScrolling;

#pragma mark -
#pragma mark Initialization

- (void)generateOptions
{
  [self releaseOptions];
  optionHeaderViews_ = [[NSMutableArray alloc] initWithCapacity:50];
  
  int numSections = [self numberOfSectionsInTableView:self.tableView];
	options_ = [[NSMutableArray alloc] initWithCapacity:numSections + 5];
	for (int section=0; section<numSections; section++)
	{
		int numRows = [self calculateNumberOfRowsInSection:section];
		NSMutableArray * rows = [[NSMutableArray alloc] initWithCapacity:numRows + 5];
		for (int row=0; row<numRows; row++)
		{
			NSMutableDictionary * option = [[NSMutableDictionary alloc] init];
			[option setObject:self forKey:kOptionCellKeyParentController];
			NSIndexPath * ip = [NSIndexPath indexPathForRow:row inSection:section];
			[option setValue:[self createLabelForIndexPath:ip] forKey:kOptionCellKeyLabel];
			[self createInteractionForIndexPath:ip forOption:option];
			[rows addObject:option];
		}
		[options_ addObject:rows];
	}
}

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([Resources isIPAD])
		return YES;
	
	return [[NavigationManager shared] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)loadView;
{
  [super loadView];
  self.tableView = [[ABTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	[[self tableView] setRowHeight:38];
  [self generateOptions];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[[self tableView] reloadData];
}

- (void)refreshTable
{
	[self generateOptions];
	[[self tableView] reloadData];	
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
  return 10.;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
{
  UIView * footerView = [[UIView alloc] init];
  footerView.backgroundColor = [UIColor colorForBackground];
  return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  BOOL hasSectionTitle = [self tableView:tableView titleForHeaderInSection:section] != nil;
  return hasSectionTitle ? 48. : 0.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
  if (!sectionTitle)
      return nil;
	
  Class cellViewClass = [Resources isIPAD] ? NSClassFromString(@"OptionCellView_iPad") : NSClassFromString(@"OptionCellView");
	OptionCellView * optionCellView = [[cellViewClass alloc] init];
	[optionCellView setBackgroundColor:[UIColor colorForBackground]];

  NSMutableDictionary * option = [[NSMutableDictionary alloc] initWithCapacity:5];
	[option setObject:self forKey:kOptionCellKeyParentController];
	[option setValue:sectionTitle forKey:kOptionCellKeyTitle];
	[optionCellView setNewOption:option];
    
  [optionHeaderViews_ addObject:optionCellView];
	return optionCellView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self calculateNumberOfRowsInSection:section];
}

- (UITableViewCell *)blankCell;
{
	OptionCell * cell = [[OptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BlankOptionCell"];
	NSMutableDictionary * option = [NSMutableDictionary dictionary];
	[option setObject:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kOptionCellKeyIndexPath];
	[option setObject:self forKey:kOptionCellKeyParentController];
	[cell setOption:option];
	[cell refreshBackground];
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!options_)
	{
		return [self blankCell];
	}
	
  static NSString *CellIdentifier = @"FastOptionCell";
	
	OptionCell *cell = (OptionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
  {
		cell = [[OptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

		cell.frame = CGRectMake(0.0, 0.0, 320.0, 100);
        
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressOnCell:)];
    longPressGesture.minimumPressDuration = 1.3;
    [cell addGestureRecognizer:longPressGesture];
	}
	[cell setTag:indexPath.row];
	NSMutableDictionary *option = [[options_ objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[option setObject:indexPath forKey:kOptionCellKeyIndexPath];
	[option setObject:self forKey:kOptionCellKeyParentController];
	[cell setOption:option];
	[cell refreshBackground];

  return cell;
}

- (void)didLongPressOnCell:(UILongPressGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		UITableViewCell *cell = (UITableViewCell *)[gesture view];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self didHoldDownCellAtIndexPath:indexPath];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [[self tableView] reloadRowsAtIndexPaths:[[self tableView] indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)nightModeSwitch
{
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.backgroundColor = [UIColor colorForBackground];
  self.tableView.superview.backgroundColor = [UIColor colorForBackground];

  [self refreshTable];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
	[self nightModeSwitch];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [self releaseOptions];
  [super viewDidDisappear:animated];
}

- (void)createInteractionForIndexPath:(NSIndexPath *)indexPath forOption:(NSMutableDictionary *)option;
{
	// implement in subclass
}

- (NSInteger)calculateNumberOfRowsInSection:(NSInteger)section;
{
	// implement in subclass
	return 0;
}

- (NSString *)createLabelForIndexPath:(NSIndexPath *)indexPath;
{
	// implement in subclass
	return @"";
}

- (void)didHoldDownCellAtIndexPath:(NSIndexPath *)indexPath;
{
    // implement in subclass
}

- (void) didChooseSecondaryOptionAtIndexPath:(NSIndexPath *)indexPath;
{
	// implement in subclass
}

- (void) didChoosePrimaryOptionAtIndexPath:(NSIndexPath *)indexPath;
{
	// implement in subclass
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
{
	isScrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
	isScrolling = NO;
}

- (void)presentOptionsWithTitle:(NSString *)title labels:(NSMutableArray *)labels values:(NSMutableArray *)values forKey:(NSString *)prefKey ofType:(OptionActionSheetValueType)typeId doAfterChangingSetting:(ABAction)afterChangingSetting;
{
	if (!values || !labels)
		return;
	
	// this will take care of mismatches
	if ([values count] != [labels count])
		return;
	
	if ([values count] == 0)
		return;
	
	if (!prefKey || [prefKey length] == 0)
		return;
	
	if (!title || [title length] == 0)
		return;
	
	self.actionSheetLabels = labels;
	self.actionSheetValues = values;
	self.actionSheetPreferenceKey = prefKey;
	self.actionSheetValueType = typeId;
  self.doAfterChangingSetting = afterChangingSetting;
	
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:title
								 delegate:self
								 cancelButtonTitle:nil
								 destructiveButtonTitle:nil
								 otherButtonTitles:
								 nil];
	[popupQuery setTag:OPTION_ACTION_SHEET_TAG];
	
	for (NSString * label in labels)
	{
		[popupQuery addButtonWithTitle:label];
	}
	
	[popupQuery addButtonWithTitle:@"Cancel"];
	[popupQuery setCancelButtonIndex:[labels count]];
	
	popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
//  [popupQuery showInView:[NavigationManager mainView]];
  [popupQuery jm_showInView:self.parentViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  switch ([actionSheet tag]) {
    case OPTION_ACTION_SHEET_TAG:
      if (buttonIndex < [self.actionSheetValues count])
      {
        if (self.actionSheetValueType == OptionActionSheetValueTypeInteger)
          [UDefaults setInteger:[[self.actionSheetValues objectAtIndex:buttonIndex] intValue] forKey:self.actionSheetPreferenceKey];
        else if (self.actionSheetValueType == OptionActionSheetValueTypeBoolean)
          [UDefaults setBool:[[self.actionSheetValues objectAtIndex:buttonIndex] boolValue] forKey:self.actionSheetPreferenceKey];
        else if (self.actionSheetValueType == OptionActionSheetValueTypeString)
          [UDefaults setValue:[self.actionSheetValues objectAtIndex:buttonIndex] forKey:self.actionSheetPreferenceKey];
      }
      [UDefaults synchronize];
      [self refreshTable];
      if (self.doAfterChangingSetting)
      {
        self.doAfterChangingSetting();
      }
      break;
    default:
      break;
  }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
  cell.backgroundColor = [UIColor clearColor];
}

- (void)dealloc
{
  [self releaseOptions];
}

- (void)releaseOptionHeaderViews
{
  if (!optionHeaderViews_)
    return;
  
  for (OptionCellView * cv in optionHeaderViews_)
  {
    NSMutableDictionary * option = [cv option];
    if (option)
    {
      [option removeAllObjects];
    }
  }
  [optionHeaderViews_ removeAllObjects];
  optionHeaderViews_ = nil;
}

- (void)releaseOptions
{
  [self releaseOptionHeaderViews];
  if (!options_)
    return;
  
  for (NSMutableArray *rowArr in options_)
  {
    for (NSMutableDictionary *option in rowArr)
    {
      if (option)
      {
        [option removeAllObjects];
      }
    }
    [rowArr removeAllObjects];
  }
  
  [options_ removeAllObjects];
  options_ = nil;
}

@end

