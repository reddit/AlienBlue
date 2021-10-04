//
//  OptionCell.h
//  AlienBlue
//
//  Created by DS on 20/06/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionCellView.h"

@interface OptionCell : UITableViewCell
@property (readonly, strong) OptionCellView *optionCellView;
@property (readonly) BOOL isTicked;
- (void)setOption:(NSMutableDictionary *)option;
- (void)refreshBackground;
@end