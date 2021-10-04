//
//  JMViewOverlay+NavigationButton.m
//  AlienBlue
//
//  Created by J M on 17/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMViewOverlay+NavigationButton.h"

@implementation JMViewOverlay (NavigationButton)

+ (JMViewOverlay *)buttonWithIcon:(NSString *)iconName highlightColor:(UIColor *)highlightColor;
{
    JMViewOverlay *overlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., 40., 40.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [UIView startEtchedDraw];

        UIColor *iconColor = (highlighted || selected) ? highlightColor : [UIColor colorWithHex:0xAAAAAA];
        UIImage *icon = [UIImage skinImageNamed:iconName withColor:iconColor];
        CGRect iconFrame = CGRectCenterWithSize(bounds, icon.size);
        [icon drawAtPoint:iconFrame.origin];
        [UIView endEtchedDraw];
    }];
    return overlay;
}

+ (JMViewOverlay *)buttonWithIcon:(NSString *)iconName iconDimension:(CGFloat)iconDimension title:(NSString *)title titleOffset:(CGSize)titleOffset standardColor:(UIColor *)standardColor titleFont:(UIFont *)titleFont;
{
    CGFloat width = iconDimension + [title widthWithFont:titleFont];
    width = JM_LIMIT(iconDimension, kTitledButtonWidthLimit, width);
    JMViewOverlay *overlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., width, iconDimension) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [UIView startEtchedDraw];
        UIColor *highlightColor = [UIColor darkGrayColor];
        UIColor *iconColor = (highlighted || selected) ? highlightColor : standardColor;
        UIImage *icon = [UIImage skinImageNamed:iconName withColor:iconColor];
        CGRect iconFrame = CGRectCenterWithSize(bounds, icon.size);
        iconFrame.origin.x = 0.;
        [icon drawAtPoint:iconFrame.origin];
        [iconColor set];
        [title drawInRect:CGRectMake(titleOffset.width, titleOffset.height, width - iconDimension, 20.) withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation];
        [UIView endEtchedDraw];
    }];
    overlay.allowTouchPassthrough = NO;
    return overlay;
}

+ (JMViewOverlay *)buttonWithIcon:(NSString *)iconName title:(NSString *)title titleOffset:(CGFloat)titleOffset;
{
  return [JMViewOverlay buttonWithIcon:iconName
                         iconDimension:40.
                                 title:title
                           titleOffset:CGSizeMake(titleOffset, 13.)
                         standardColor:[UIColor colorWithHex:0xb6b6b6]
                             titleFont:[UIFont skinFontWithName:kBundleFontNavigationButtonTitle]];
}

+ (JMViewOverlay *)buttonWithIcon:(NSString *)iconName title:(NSString *)title;
{
    return [JMViewOverlay buttonWithIcon:iconName title:title titleOffset:36.];
}

+ (JMViewOverlay *)buttonWithTitle:(NSString *)title;
{
    CGFloat width = [title widthWithFont:[UIFont skinFontWithName:kBundleFontNavigationButtonTitle]];
    width = JM_LIMIT(0., kTitledButtonWidthLimit, width);
    JMViewOverlay *overlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 0., width, 40.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [UIView startEtchedDraw];
        UIColor *highlightColor = [UIColor darkGrayColor];
        UIColor *iconColor = (highlighted || selected) ? highlightColor : [UIColor colorWithHex:0xb6b6b6];
        [iconColor set];
        [title drawInRect:CGRectMake(0., 13., width, 20.) withFont:[UIFont skinFontWithName:kBundleFontNavigationButtonTitle] lineBreakMode:UILineBreakModeTailTruncation];
        [UIView endEtchedDraw];
    }];
    return overlay;    
}


+ (JMViewOverlay *)buttonWithIcon:(NSString *)iconName;
{
    return [JMViewOverlay buttonWithIcon:iconName highlightColor:[UIColor darkGrayColor]];
}

#pragma mark - iPhone sized buttons

+ (JMViewOverlay *)tinyButtonWithIcon:(NSString *)iconName title:(NSString *)title color:(UIColor *)color;
{
  return [JMViewOverlay buttonWithIcon:iconName
                         iconDimension:30.
                                 title:title
                           titleOffset:CGSizeMake(27., 9.)
                         standardColor:color
                             titleFont:[UIFont skinFontWithName:kBundleFontCommentHeaderToolbarFontRegular]];
}


+ (JMViewOverlay *)tinyButtonWithIcon:(NSString *)iconName title:(NSString *)title;
{
  return [JMViewOverlay buttonWithIcon:iconName
                         iconDimension:30.
                                 title:title
                           titleOffset:CGSizeMake(27., 9.)
                         standardColor:[UIColor colorWithHex:0x7d7d7d]
                             titleFont:[UIFont skinFontWithName:kBundleFontCommentHeaderToolbarFontRegular]];
}

+ (JMViewOverlay *)tinyBoldButtonWithIcon:(NSString *)iconName title:(NSString *)title;
{
  return [JMViewOverlay buttonWithIcon:iconName
                         iconDimension:30.
                                 title:title
                           titleOffset:CGSizeMake(27., 8.)
                         standardColor:[UIColor colorWithHex:0x7d7d7d]
                             titleFont:[UIFont skinFontWithName:kBundleFontCommentHeaderToolbarFontBold]];  
}



@end
