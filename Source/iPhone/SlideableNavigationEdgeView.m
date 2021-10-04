#import "SlideableNavigationEdgeView.h"
#import <QuartzCore/QuartzCore.h>

@interface SlideableNavigationEdgeView()
@property (strong) UILabel *instructionLabel;
@property (strong) UIImageView *iconView;
@property (strong) UIView *highlightView;
@end

@implementation SlideableNavigationEdgeView

- (id)initWithFrame:(CGRect)frame;
{
  self = [super initWithFrame:frame];
  if (self)
  {
//    self.instructionLabel = [UILabel new];
    self.iconView = [UIImageView new];
      
    self.iconView.top = 80.;
    self.iconView.size = CGSizeMake(30., 30.);
    [self addSubview:self.iconView];
    self.iconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.iconView.contentMode = UIViewContentModeCenter;
    [self.iconView centerHorizontallyInSuperView];
    
    self.highlightView = [UIView new];
    self.highlightView.autoresizingMask = self.iconView.autoresizingMask;
//    self.highlightView.frame = CGRectOffset(self.iconView.frame, 0., 2.);
    self.highlightView.frame = CGRectInset(self.iconView.frame, 3., 0.);
    self.highlightView.height = 2.;
    self.highlightView.top = self.iconView.bottom;
    self.highlightView.layer.borderColor = [UIColor colorForHighlightedOptions].CGColor;
    self.highlightView.layer.borderWidth = 2.;
    self.highlightView.layer.cornerRadius = 1;
    [self addSubview:self.highlightView];
    
    
//    self.instructionLabel.backgroundColor = [UIColor clearColor];
//    self.instructionLabel.top = 120.;
//    self.instructionLabel.size = CGSizeMake(120, 50.);
//    self.instructionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    self.instructionLabel.font = [UIFont boldSystemFontOfSize:10.];
//    self.instructionLabel.numberOfLines = 1;
//    self.instructionLabel.textAlignment = UITextAlignmentLeft;
//    self.instructionLabel.shadowColor = [UIColor blackColor];
//    self.instructionLabel.shadowOffset = CGSizeMake(0., 1.);
//    self.instructionLabel.textColor = [UIColor whiteColor];
//    self.instructionLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
//    [self addSubview:self.instructionLabel];
//    [self.instructionLabel centerHorizontallyInSuperView];
  }
  return self;
}

@end
