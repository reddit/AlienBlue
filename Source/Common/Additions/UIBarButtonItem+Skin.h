//
//  UIBarButtonItem+Skin.h
//  AlienBlue
//
//  Created by JM on 10/12/12.
//
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Skin)

+ (UIBarButtonItem *)skinBarItemWithIcon:(NSString *)iconName target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)skinBarItemWithIcon:(NSString *)iconName fillColor:(UIColor *)fillColor target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)skinBarItemWithIcon:(NSString *)iconName fillColor:(UIColor *)fillColor positionOffset:(CGSize)positionOffset target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)skinBarItemWithTitle:(NSString *)title textColor:(UIColor *)textColor fillColor:(UIColor *)fillColor positionOffset:(CGSize)positionOffset target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)skinBarItemWithTitle:(NSString *)title textColor:(UIColor *)textColor target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)skinBarItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

- (void)applyThemeSettings;

@end
