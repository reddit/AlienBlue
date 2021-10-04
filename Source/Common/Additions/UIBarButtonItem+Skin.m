//
//  UIBarButtonItem+Skin.m
//  AlienBlue
//
//  Created by JM on 10/12/12.
//
//

#import "UIBarButtonItem+Skin.h"
#import "ABNavigationBar.h"
#import "Resources.h"

#define kJMBarButtonItemTitlePadding CGSizeMake(10., 5.)

@interface UIBarButtonItem(Skin_)
@property (strong) NSString *jmSkinIconName;
@property (strong) NSString *jmSkinTitle;
@property (strong) UIColor *jmSkinTitleColor;
@property CGSize jmPositionOffset;
@property (strong) UIColor *jmForceFillColor;
@end

@implementation UIBarButtonItem (Skin)

SYNTHESIZE_ASSOCIATED_STRONG(NSString, jmSkinIconName, JmSkinIconName);
SYNTHESIZE_ASSOCIATED_STRONG(NSString, jmSkinTitle, JmSkinTitle);
SYNTHESIZE_ASSOCIATED_STRONG(NSString, jmForceFillColor, JmForceFillColor);
SYNTHESIZE_ASSOCIATED_STRONG(NSString, jmSkinTitleColor, JmSkinTitleColor);
SYNTHESIZE_ASSOCIATED_SIZE(jmPositionOffset, JmPositionOffset);

//+ (UIBarButtonItem *)skinBarItemWithIcon:(NSString *)iconName target:(id)target action:(SEL)action;
//{
//  UIImage *icon = [UIImage skinIcon:iconName];
//  UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStylePlain target:target action:action];
//  return b;
//}

+ (UIBarButtonItem *)skinBarItemWithIcon:(NSString *)iconName fillColor:(UIColor *)fillColor positionOffset:(CGSize)positionOffset target:(id)target action:(SEL)action;
{
  UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
  [b addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  b.showsTouchWhenHighlighted = YES;
  
  UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:b];
  barItem.jmSkinIconName = iconName;
  barItem.jmForceFillColor = fillColor;
  barItem.jmPositionOffset = positionOffset;
  [barItem applyThemeSettings];
  return barItem;
}

+ (UIBarButtonItem *)skinBarItemWithIcon:(NSString *)iconName fillColor:(UIColor *)fillColor target:(id)target action:(SEL)action;
{
  return [UIBarButtonItem skinBarItemWithIcon:iconName fillColor:fillColor positionOffset:CGSizeZero target:target action:action];
}

+ (UIBarButtonItem *)skinBarItemWithTitle:(NSString *)title textColor:(UIColor *)textColor fillColor:(UIColor *)fillColor positionOffset:(CGSize)positionOffset target:(id)target action:(SEL)action;
{
  UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
  [b addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  
  UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:b];
  barItem.jmSkinTitle = title;
  barItem.jmSkinTitleColor = textColor;
  barItem.jmPositionOffset = positionOffset;
  barItem.jmForceFillColor = fillColor;
  [barItem applyThemeSettings];
  return barItem;
}

+ (UIBarButtonItem *)skinBarItemWithTitle:(NSString *)title textColor:(UIColor *)textColor target:(id)target action:(SEL)action;
{
  return [UIBarButtonItem skinBarItemWithTitle:title textColor:textColor fillColor:nil positionOffset:CGSizeZero target:target action:action];
}

+ (UIBarButtonItem *)skinBarItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
{
  return [UIBarButtonItem skinBarItemWithTitle:title textColor:nil fillColor:nil positionOffset:CGSizeZero target:target action:action];
}

+ (UIBarButtonItem *)skinBarItemWithIcon:(NSString *)iconName target:(id)target action:(SEL)action;
{
  return [UIBarButtonItem skinBarItemWithIcon:iconName fillColor:nil target:target action:action];
}

- (void)applyThemeSettings;
{
  if (!self.customView)
    return;
  
  UIButton *b = JMIsKindClassOrNil(self.customView, UIButton);
  if (!b)
    return;

  if (self.jmSkinIconName)
  {
    UIImage *icon = [self generateNavbarButtonIcon];
    [b setImage:icon forState:UIControlStateNormal];
    b.imageEdgeInsets = UIEdgeInsetsMake(1. + self.jmPositionOffset.height, self.jmPositionOffset.width, 0., 0.);
    b.size = CGSizeMake(44., 40.);
  }
  
  if (self.jmSkinTitle)
  {
    UIFont *font = [UIFont skinFontWithName:kBundleFontNavigationButtonTitle];
    CGSize textSize = [self.jmSkinTitle sizeWithFont:font];
    CGSize buttonSize = CGSizeMake(textSize.width + kJMBarButtonItemTitlePadding.width * 2, textSize.height + kJMBarButtonItemTitlePadding.height * 2);
    [b setImage:[self generateButtonWithTitleForSize:buttonSize] forState:UIControlStateNormal];
//    b.imageEdgeInsets = UIEdgeInsetsMake(2. + self.jmPositionOffset.height, self.jmPositionOffset.width, 0., 0.);
    b.imageEdgeInsets = UIEdgeInsetsMake(0., self.jmPositionOffset.width, 0., 0.);
    b.imageView.contentMode = UIViewContentModeCenter;
    b.imageView.clipsToBounds = NO;
 
    CGSize bSize = CGSizeMake(buttonSize.width + b.imageEdgeInsets.top, buttonSize.width + b.imageEdgeInsets.left);
    b.size = bSize;
  }
}

- (UIImage *)generateButtonWithTitleForSize:(CGSize)buttonSize;
{
  UIColor *fillColor = self.jmForceFillColor;
  UIColor *defaultShadowColor = self.jmForceFillColor ? [UIColor clearColor] : [UIColor colorForInsetDropShadow];
  
  UIColor *textColor = self.jmSkinTitleColor ? self.jmSkinTitleColor : [UIColor colorForBarButtonItem];
  UIColor *textShadowColor = defaultShadowColor;
  
  BSELF(UIBarButtonItem);
  UIImage *buttonImage = [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
      if (fillColor)
      {
        CGRect borderRect = CGRectInset(bounds, 1., 1.);
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:3.];
        [fillColor setFill];
        [borderPath fill];
      }

    [UIView jm_drawShadowed:^{
      [textColor set];
      CGRect innerRect = CGRectInset(bounds, kJMBarButtonItemTitlePadding.width, kJMBarButtonItemTitlePadding.height);
      innerRect.origin.y += JMIsIOS7() ? -1 : 0;
      UIFont *font = [UIFont skinFontWithName:kBundleFontNavigationButtonTitle];
      [blockSelf.jmSkinTitle drawInRect:innerRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    } shadowColor:textShadowColor];
  } opaque:NO withSize:buttonSize cacheKey:nil];
  return buttonImage;
}

- (UIImage *)generateNavbarButtonIcon;
{
  UIColor *fillColor = self.jmForceFillColor ? self.jmForceFillColor : [UIColor colorForBarButtonItem];
  UIImage *rawIcon = [UIImage skinIcon:self.jmSkinIconName];
  UIImage *etched = [UIImage jm_coloredImageFromImage:rawIcon fillColor:fillColor];
  return etched;
}

@end
