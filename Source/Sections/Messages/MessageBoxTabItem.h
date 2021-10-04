//
//  MessageBoxTabItem.h
//  AlienBlue
//
//  Created by JM on 31/12/12.
//
//

#import "JMTabItem.h"

@interface MessageBoxTabItem : JMTabItem

@property (strong) UIColor *forceHighlightColor;

- (id)initWithTitle:(NSString *)title skinIconName:(NSString *)iconName;

@end
