//
//  NBaseSubredditCell.h
//  AlienBlue
//
//  Created by J M on 7/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMOutlineCell.h"

typedef enum {
   OptionDisclosureStyleNone = 0,
   OptionDisclosureStyleArrow,
} OptionDisclosureStyle;

@interface OptionNode : JMOutlineNode
@property (strong) UIImage *icon;
@property (strong) NSString *title;
@property (strong) UIColor *titleColor;
@property (strong) UIColor *backgroundColor;

@property (strong) NSString *valueTitle;
@property (strong) UIColor *valueColor;

@property (strong) UIImage *secondaryIcon;
@property (copy) ABAction secondaryAction;

@property BOOL disabled;
@property BOOL bold; 
@property BOOL hidesDivider;
@property BOOL stickyHighlight;
@property BOOL hidesTitleShadow;

- (void)setDisclosureStyle:(OptionDisclosureStyle)style;

@end

@interface NBaseOptionCell : JMOutlineCell
@property (strong) JMViewOverlay *titleOverlay;
@property (strong) JMViewOverlay *valueOverlay;
@property (strong) JMViewOverlay *iconOverlay;
@property (strong) JMViewOverlay *iconSeparatorOverlay;
@property (strong) JMViewOverlay *secondaryButtonOverlay;
- (void)drawDivider;
@end
