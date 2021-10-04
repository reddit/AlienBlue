#import "ABActionMenuFavoriteLinkEditPanel.h"
#import "ABActionMenuThemeConfiguration.h"

@interface ABActionMenuFavoriteLinkEditPanel() <UITextFieldDelegate>
@property (strong) UITextField *textField;
@end

@implementation ABActionMenuFavoriteLinkEditPanel

- (void)createSubviews;
{
  [super createSubviews];
  
  UILabel *panelTitleLabel = [UILabel new];
  panelTitleLabel.text = @"Which subreddit would you like this shortcut to take you to?";
  panelTitleLabel.numberOfLines = 2;
  panelTitleLabel.size = CGSizeMake(240., 40.);
  panelTitleLabel.font = self.themeConfiguration.fontForCustomEditPanelText;
  panelTitleLabel.textAlignment = NSTextAlignmentCenter;
  panelTitleLabel.autoresizingMask = JMFlexibleHorizontalMarginMask;
  panelTitleLabel.textColor = self.themeConfiguration.titleColorForEditingLabel;
  [self addSubview:panelTitleLabel];
  [panelTitleLabel centerHorizontallyInSuperView];
  
  self.textField = [UITextField new];
  self.textField.size = CGSizeMake(240., 40.);
  self.textField.top = panelTitleLabel.bottom + 10.;
  self.textField.autoresizingMask = JMFlexibleHorizontalMarginMask;
  [self addSubview:self.textField];
  [self.textField centerHorizontallyInSuperView];
  self.textField.backgroundColor = JMHexColor(cecece);
  self.textField.delegate = self;
  self.textField.textAlignment = NSTextAlignmentCenter;
  self.textField.text = (NSString *)self.userInfo;
  self.textField.textColor = self.themeConfiguration.titleColorForEditingLabel;
  self.textField.returnKeyType = UIReturnKeyDone;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return NO;
}

- (CGFloat)recommendedHeight;
{
  return 120.;
}

- (NSObject<NSCoding> *)generateUpdatedUserInfo;
{
  return self.textField.text;
}

@end
