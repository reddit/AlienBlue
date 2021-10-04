//
//  TextViewCell.h
//  PTLog
//
//  Created by Ellen Miner on 2/20/09.
//  Copyright 2009 RaddOnline. All rights reserved.
//

#import <UIKit/UIKit.h>

// cell identifier for this custom cell
extern NSString *kCellTextView_ID;

@interface TextViewCell : UITableViewCell {
	IBOutlet UITextView *textView;
}
+ (TextViewCell*) createNewTextCellFromNib;

@property (nonatomic, strong) UITextView *textView;

@end
