#import "TemplateEditToolsView.h"
#import "Resources.h"

@interface TemplateEditToolsView()
@property (strong) ABButton *tokenButton;
@property (strong) TemplateSendModeSwitchView *switchView;
@property (strong) UILabel *switchLabel;
@end

@implementation TemplateEditToolsView

- (id)initWithFrame:(CGRect)frame;
{
  self = [super initWithFrame:frame];
  if (self)
  {
    self.contentMode = UIViewContentModeRedraw;
    
    self.tokenButton = [[ABButton alloc] initWithIcon:[UIImage skinEtchedIcon:@"template-insert-token-icon" withColor:[UIColor grayColor]]];
    [self addSubview:self.tokenButton];
    
    self.switchView = [TemplateSendModeSwitchView new];
    [self addSubview:self.switchView];
    self.switchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.switchView.right = self.bounds.size.width;
    
    self.switchLabel = [UILabel new];
    self.switchLabel.font = [UIFont skinFontWithName:kBundleFontPostSubtitleBold];
    self.switchLabel.text = @"Send as:";
    [self.switchLabel sizeToFit];
    [self addSubview:self.switchLabel];
    self.switchLabel.textColor = [UIColor grayColor];
    self.switchLabel.backgroundColor = [UIColor clearColor];
    self.switchLabel.shadowColor = [UIColor colorForInsetDropShadow];
    self.switchLabel.shadowOffset = CGSizeMake(0., 1.);
    self.switchLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  }
  return self;
}

- (void)layoutSubviews;
{
  [super layoutSubviews];
  self.switchLabel.hidden = self.bounds.size.width < 200.;

//  [self.tokenButton centerVerticallyInSuperView];
//  [self.switchView centerVerticallyInSuperView];
  self.tokenButton.top = -2;
  self.tokenButton.left = 10;
  self.switchView.top = -6;
  self.switchView.right = self.bounds.size.width;
  self.switchLabel.right = self.switchView.left - 3.;
  self.switchLabel.top = 7.;
  
//  CGAffineTransform trackRotation = CGAffineTransformMakeRotation(self.i_layoutVertically ? M_PI_2 : 0.);
//  CGAffineTransform trackScale = self.i_layoutVertically ? CGAffineTransformMakeScale(0.82, 0.82) : CGAffineTransformMakeScale(1., 1.);
//  CGAffineTransform tokenScale = self.i_layoutVertically ? CGAffineTransformMakeScale(0.7, 0.7) : CGAffineTransformMakeScale(1., 1.);
//  CGAffineTransform trackTransform = CGAffineTransformConcat(trackRotation, trackScale);
//  CGAffineTransform iconRotation = CGAffineTransformMakeRotation(self.i_layoutVertically ? -M_PI_2 : 0.);
  
//  self.switchView.transform = trackTransform;
//  self.switchView.leftIconView.transform = iconRotation;
//  self.switchView.rightIconView.transform = iconRotation;
//  self.tokenButton.transform = tokenScale;

//  if (self.i_layoutVertically)
//  {
//    self.tokenButton.top = 67.;
//    self.tokenButton.left = 4.;
//
//    self.switchView.top = -13.;
//    self.switchView.right = self.bounds.size.width;
//    self.switchView.rightIconView.top = 7.;
//    self.switchView.rightIconView.left = 74;
//    self.switchView.leftIconView.top = 7;
//    self.switchView.leftIconView.left = 10;
//  }
//  else
//  {
    self.tokenButton.left = 12.;
    self.tokenButton.top = -2.;
    self.switchView.top = -5;
    self.switchView.right = self.bounds.size.width;
    self.switchView.rightIconView.top = 8;
    self.switchView.rightIconView.left = 80;
    self.switchView.leftIconView.top = 8;
    self.switchView.leftIconView.left = 5;
    
    self.switchLabel.top = 8.;
    self.switchLabel.right = self.switchView.left - 3.;
//  }
}

- (void)drawRect:(CGRect)rect;
{
  if (![Resources isNight])
  {
    CGRect bgRect = CGRectInset(self.bounds, 2., 3.);
    [[UIColor colorForBackgroundAlt] set];
    [[UIBezierPath bezierPathWithRoundedRect:bgRect cornerRadius:5.] fill];
    [[UIImage skinIcon:@"dotted-separator-icon" withColor:[UIColor colorForDivider]] drawAtPoint:CGPointMake(36., 0.)];
  }
}

- (void)setSendSwitchPreference:(TemplateSendPreference)sendPref;
{

}

@end

