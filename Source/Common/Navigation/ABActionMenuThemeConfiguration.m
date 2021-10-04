#import "ABActionMenuThemeConfiguration.h"
#import "Resources.h"

@implementation ABActionMenuThemeConfiguration

- (UIColor *)themeBaseColor;
{
  return [UIColor colorForTint];
}

- (UIColor *)ribbonColor;
{
  return [Resources isNight] ? [[UIColor colorForBackground] colorWithAlphaComponent:0.6] : [[UIColor whiteColor] colorWithAlphaComponent:0.6];
}

- (UIColor *)colorForHandSwitch;
{
  return [Resources isNight] ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
}

- (CGFloat)blurRadius;
{
  return [Resources isNight] ? 24. : 27;
}

- (UIColor *)snapshopTintColor;
{
  return [[UIColor colorForBackground] colorWithAlphaComponent:0.4];
}

- (UIColor *)themeTextColor;
{
  return [UIColor colorForHighlightedText];
}

- (UIColor *)themeBackgroundColor;
{
  return [UIColor colorForBackground];
}

- (UIColor *)themeForegroundColor;
{
  return self.themeBaseColor;
}

- (UIColor *)softStrokeColor;
{
  return [UIColor colorForDivider];
}

- (NSString *)defaultFontFamilyName;
{
  return @"HelveticaNeue-Light";
}

- (UIFont *)fontForSupplementalLabel;
{
  //  return [UIFont fontWithName:self.defaultFontFamilyName size:11.];
  return self.titleFontForEditingLabel;
}

- (UIFont *)titleFontForEditingLabel;
{
  return [UIFont fontWithName:self.defaultFontFamilyName size:12.5];
}

- (UIFont *)descriptionFontForEditingLabel;
{
  return [UIFont fontWithName:@"HelveticaNeue" size:11.];
}

- (UIColor *)buttonBackgroundColor;
{
  return self.themeForegroundColor;
}

- (UIFont *)buttonTitleFont;
{
  return [UIFont fontWithName:self.defaultFontFamilyName size:13.];
}

- (UIColor *)buttonTitleColor;
{
  return self.themeForegroundColor;
}

- (UIColor *)titleColorForEditingLabel;
{
  return [UIColor colorForText];
}

- (UIColor *)descriptionColorForEditingLabel;
{
  return [[UIColor colorForText] colorWithAlphaComponent:0.8];
}

- (UIColor *)titleColorForDisabledEditingLabel;
{
  return [[UIColor colorForText] colorWithAlphaComponent:0.5];
}

- (UIColor *)descriptionColorForDisabledEditingLabel;
{
  return [[UIColor colorForText] colorWithAlphaComponent:0.5];
}

- (UIColor *)colorForDisabledIcon;
{
  return [UIColor skinColorForDisabledIcon];
}

- (UIColor *)editConfirmationViewAllScreenOptionHighlightColor;
{
  return JMHexColor(e0308f);
}

- (CGFloat)verticalTrackOffsetWithCompactOpenButton;
{
  return [Resources shouldAutoHideStatusBarWhenScrolling] ? 8. : 28.;
}

@end
