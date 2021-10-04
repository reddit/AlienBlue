#import "MessageBoxTabItem.h"
#import "JMTabConstants.h"
#import "Resources.h"

@interface MessageBoxTabItem()
@property (strong) NSString *skinIconName;
@end

@implementation MessageBoxTabItem

- (id)initWithTitle:(NSString *)title skinIconName:(NSString *)iconName;
{
  UIImage *icon = [UIImage skinIcon:iconName];
  self = [super initWithTitle:title icon:icon];
  if (self)
  {
    self.skinIconName = iconName;
  }
  return self;
}

- (void)drawRect:(CGRect)rect;
{
  if (self.highlighted)
  {
    CGRect bounds = CGRectInset(rect, 6., 10.);
    bounds = CGRectOffset(bounds, 0., -1.);
    CGFloat radius = 0.5f * CGRectGetHeight(bounds);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];
    [[UIColor colorWithWhite:0.5 alpha:0.2] set];
    [path setLineWidth:2.];
    [path stroke];
  }
  
  UIColor *unselectedColor = self.forceHighlightColor ?: [UIColor skinColorForDisabledIcon];
  
  UIColor *iconColor = self.isSelectedTabItem ? [UIColor colorForTint] : unselectedColor;
  
  CGFloat xOffset = kTabItemPadding.width;
  
  if (self.icon)
  {
    UIImage *icon = [UIImage skinIcon:self.skinIconName withColor:iconColor];
    [icon drawAtPoint:CGPointMake(xOffset, 7.)];
    xOffset += [icon size].width + kTabItemIconMargin;
  }
  
  [iconColor set];
  
  CGFloat heightTitle = [self.title sizeWithFont:kTabItemFont].height;
  CGFloat titleYOffset = (self.bounds.size.height - heightTitle) / 2;
  titleYOffset -= 1;
  xOffset -= 6.;
  BSELF(MessageBoxTabItem);
  [UIView jm_drawShadowed:^{
    [blockSelf.title drawAtPoint:CGPointMake(xOffset, titleYOffset) withFont:kTabItemFont];
  } shadowColor:[UIColor colorForInsetDropShadow]];
}

@end
