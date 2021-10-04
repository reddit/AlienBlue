//
//  NCenteredTextCell.h
//  AlienBlue
//
//  Created by J M on 26/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMOutlineCell.h"


@interface CenteredTextNode : JMOutlineNode
+ (CenteredTextNode *)nodeWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle;
+ (CenteredTextNode *)nodeWithTitle:(NSString *)title;
@property (strong) NSString *title;
@property (strong) NSString *selectedTitle;

@property (strong) UIColor *customBackgroundColor;
@property (strong) UIColor *customTitleColor;
@property (strong) UIFont *customTitleFont;
@property CGFloat customHeight;
@end


@interface NCenteredTextCell : JMOutlineCell

@end
