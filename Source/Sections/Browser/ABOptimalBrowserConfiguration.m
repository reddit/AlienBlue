#import "ABOptimalBrowserConfiguration.h"

@implementation ABOptimalBrowserConfiguration

- (UIColor *)optimalBrowserColorForBackground;
{
  return [UIColor colorForBackground];
}

- (UIColor *)optimalBrowserColorForText;
{
  return [UIColor colorForText];
}

- (UIColor *)optimalBrowserColorForHighlightedText;
{
  return [UIColor colorForHighlightedOptions];
}

- (UIColor *)optimalBrowserColorForEtchedDropShadow;
{
  return [UIColor colorForInsetDropShadow];
}

- (UIColor *)optimalBrowserColorForDivider;
{
  return [UIColor grayColor];
}

- (UIFont *)optimalBrowserTextFont;
{
  return [UIFont skinFontWithName:kBundleFontCommentBody];
}

- (UIColor *)optimalBrowserToolbarBackgroundColor;
{
  return [UIColor colorForBackgroundAlt];
}

@end
