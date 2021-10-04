//  Copyright 2010 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "RedditAPI.h"
#import "NavigationManager.h"
#import "ABTableView.h"

#define OPTION_ACTION_SHEET_TAG 1

typedef enum : NSUInteger {
  OptionActionSheetValueTypeInteger,
  OptionActionSheetValueTypeString,
  OptionActionSheetValueTypeBoolean,
} OptionActionSheetValueType;

@interface OptionTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>{
	NSMutableArray *options_;
	NSMutableArray *optionHeaderViews_;
	BOOL isScrolling;
  BOOL forceDefaultNavigationBarStyle;
}

@property (strong) NSMutableArray *actionSheetLabels;
@property (strong) NSMutableArray *actionSheetValues;
@property (copy) NSString *actionSheetPreferenceKey;
@property OptionActionSheetValueType actionSheetValueType;

@property (nonatomic,copy) ABAction doAfterChangingSetting;
@property (strong) ABTableView *tableView;
@property (nonatomic) BOOL isScrolling;

- (void)generateOptions;
- (void)refreshTable;
- (void)nightModeSwitch;

// methods to be implemented in subclasses
- (void)createInteractionForIndexPath:(NSIndexPath *)indexPath forOption:(NSMutableDictionary *) option;
- (NSInteger) calculateNumberOfRowsInSection:(NSInteger) section;
- (NSString *) createLabelForIndexPath:(NSIndexPath *)indexPath;
- (void)didChooseSecondaryOptionAtIndexPath:(NSIndexPath *)indexPath;
- (void)didChoosePrimaryOptionAtIndexPath:(NSIndexPath *)indexPath;
- (void)didHoldDownCellAtIndexPath:(NSIndexPath *)indexPath;

- (void)presentOptionsWithTitle:(NSString *)title labels:(NSMutableArray *)labels values:(NSMutableArray *)values forKey:(NSString *)prefKey ofType:(OptionActionSheetValueType)typeId doAfterChangingSetting:(ABAction)afterChangingSetting;
@end
