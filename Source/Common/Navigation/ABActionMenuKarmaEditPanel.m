#import "ABActionMenuKarmaEditPanel.h"
#import "ABActionMenuThemeConfiguration.h"

@interface ABActionMenuKarmaEditPanel()
@property (strong) UISwitch *truncateSwitch;
@end

@implementation ABActionMenuKarmaEditPanel

- (void)createSubviews;
{
  [super createSubviews];
  
  UILabel *panelTitleLabel = [UILabel new];
  panelTitleLabel.text = @"Would you like Alien Blue to truncate your Karma (eg 1.2k) for improved visual layout?";
  panelTitleLabel.numberOfLines = 2;
  panelTitleLabel.size = CGSizeMake(240., 40.);
  panelTitleLabel.font = self.themeConfiguration.fontForCustomEditPanelText;
  panelTitleLabel.textAlignment = NSTextAlignmentCenter;
  panelTitleLabel.autoresizingMask = JMFlexibleHorizontalMarginMask;
  panelTitleLabel.textColor = self.themeConfiguration.titleColorForEditingLabel;
  [self addSubview:panelTitleLabel];
  [panelTitleLabel centerHorizontallyInSuperView];
  
  self.truncateSwitch = [UISwitch new];
  self.truncateSwitch.on = [(NSNumber *)self.userInfo boolValue];
  self.truncateSwitch.top = panelTitleLabel.bottom + 10.;
  self.truncateSwitch.autoresizingMask = JMFlexibleHorizontalMarginMask;
  [self addSubview:self.truncateSwitch];
  [self.truncateSwitch centerHorizontallyInSuperView];
  [self.truncateSwitch setOnTintColor:self.themeConfiguration.themeForegroundColor];
  [self.truncateSwitch setTintColor:[UIColor grayColor]];
}

- (CGFloat)recommendedHeight;
{
  return 110.;
}

- (NSObject<NSCoding> *)generateUpdatedUserInfo;
{
  return [NSNumber numberWithBool:self.truncateSwitch.on];
}

@end
