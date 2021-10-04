//  REDNavigationBar.m
//  RedditApp

#import "RedditApp/REDNavigationBar.h"

#import "JMOutlineView/JMOutlineViewController.h"

static const int kFirstCenterX = 25;
static const int kSpacingX = 40;

@interface REDNavigationBar ()

// Create a reference to the superclass's button, just to hide it.
@property(nonatomic, strong) UIButton *modalCloseButton;
@property(nonatomic, strong) UIButton *RED_modalCloseButton;
@property(nonatomic, strong) NSMutableArray *leftButtons;
@property(nonatomic, strong) NSMutableArray *rightButtons;

@end

@implementation REDNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.leftButtons = [NSMutableArray array];
    self.rightButtons = [NSMutableArray array];
  }
  return self;
}

- (void)addLeftButton:(UIButton *)button {
  [self.leftButtons addObject:button];
  [self addSubview:button];
}

- (void)addRightButton:(UIButton *)button {
  [self.rightButtons addObject:button];
  [self addSubview:button];
}

#pragma mark - ABCustomOutlineNavigationBar

- (BOOL)hidesStatusBarOnCompact {
  return NO;
}

- (void)parentControllerWillBecomeVisible;
{
  self.backButton.hidden = YES;
  self.modalCloseButton.hidden = YES;

  BOOL parentIsTopAndOnlyController =
      self.parentViewController.navigationController.viewControllers.count == 1;
  if (!parentIsTopAndOnlyController) {
    // TODO(sharkey): add back button.
  }
  if (self.parentViewController.presentingViewController) {
    [self addModalCloseButton];
  }
}

#pragma mark - UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat midY = self.recommendedVerticalCenterForBarItems;

  self.titleView.centerY = midY;
  [self.titleView centerHorizontallyInSuperView];

  CGFloat xPos = kFirstCenterX;
  for (UIButton *button in self.leftButtons) {
    button.centerY = midY;
    button.centerX = xPos;
    xPos += kSpacingX;
  }

  xPos = self.frame.size.width - kFirstCenterX;
  for (UIButton *button in self.rightButtons) {
    button.centerY = midY;
    button.centerX = xPos;
    xPos -= kSpacingX;
  }
}

#pragma mark - private

- (void)addModalCloseButton {
  if (!self.RED_modalCloseButton) {
    self.RED_modalCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.RED_modalCloseButton addTarget:self
                                  action:@selector(didPressModalCloseButton)
                        forControlEvents:UIControlEventTouchUpInside];
    [self.RED_modalCloseButton setImage:[UIImage imageNamed:@"btn_downarrow_nav_white"]
                               forState:UIControlStateNormal];
    [self.RED_modalCloseButton sizeToFit];
    [self addLeftButton:self.RED_modalCloseButton];
  }
}

- (void)didPressModalCloseButton {
  [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - accessors

- (void)setTitleView:(UIView *)titleView {
  [_titleView removeFromSuperview];
  _titleView = titleView;
  [self addSubview:_titleView];
  [self setNeedsLayout];
}

@end
