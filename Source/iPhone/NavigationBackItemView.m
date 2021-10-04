//
//  NavigationBackItemView.m
//  AlienBlue
//
//  Created by JM on 6/12/12.
//
//

#import "NavigationBackItemView.h"
#import "AlienBlueAppDelegate.h"
#import "Resources.h"

#define kNavigationBackItemViewTextLeftMargin 40.

@interface NavigationBackItemView()
@property (strong) NSString *title;
@property BOOL hidesBackButton;

@property UILabel *label;
@property UIImageView *backImageView;
@end

@implementation NavigationBackItemView

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kNightModeSwitchNotification object:nil];
}

//- (id)initWithFrame:(CGRect)frame
//{
//  self = [super initWithFrame:frame];
//  if (self)
//  {
//    self.backgroundColor = [UIColor orangeColor];
//  }
//  return self;
//}

- (id)initWithNavigationItem:(UINavigationItem *)navigationItem;
{
  self = [super initWithFrame:CGRectMake(0., 0., 40., 38.)];
  if (self)
  {
    NSString *title = navigationItem.title;
    
    if ([title equalsString:@"Browser"] || [title equalsString:@"Comments"])
    {
      title = @"";
    }
    
    self.title = title;
    self.hidesBackButton = [title equalsString:@"reddit"];
    
    self.backgroundColor = [UIColor clearColor];

    if (![Resources useActionMenu])
    {
      self.label = [UILabel new];
      self.label.text = self.title;
      self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.];
      self.label.backgroundColor = [UIColor clearColor];
      [self.label sizeToFit];
      [self addSubview:self.label];
      
      self.label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
      [self.label centerVerticallyInSuperView];
      self.label.top += 3.;
      self.label.left = (self.hidesBackButton) ? 9. : kNavigationBackItemViewTextLeftMargin;
    }
    
    self.backImageView = [UIImageView new];
    self.backImageView.image = [NavigationBackItemView imageForBackButton];
    [self.backImageView sizeToFit];
    self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.backImageView];
    [self.backImageView centerVerticallyInSuperView];
    self.backImageView.left = -5.;
    self.backImageView.top += 3.;
    self.backImageView.hidden = self.hidesBackButton;
    
    if (JMIsIOS7())
    {
      self.label.left -= 11;
      if (self.hidesBackButton)
      {
        self.label.left += 0.;
      }
      self.backImageView.left -= 11;
    }
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveLongTapGesture:)];
    gesture.minimumPressDuration = 0.7;
    [self addGestureRecognizer:gesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToStyleChangeNotification) name:kNightModeSwitchNotification object:nil];
    
    [self respondToStyleChangeNotification];
  }
  return self;
}

- (void)didReceiveLongTapGesture:(UILongPressGestureRecognizer *)gesture;
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
      [[NavigationManager shared] showNavigationStack];
    }
}

- (void)respondToStyleChangeNotification;
{
  self.backImageView.image = [NavigationBackItemView imageForBackButton];
  self.label.textColor = [UIColor colorForBarButtonItem];
  self.label.shadowColor = [UIColor colorForBarButtonItemShadow];
  self.label.shadowOffset = SkinShadowOffsetSize();
}

- (void)setHighlighted:(BOOL)highlighted;
{
  [super setHighlighted:highlighted];
  self.backImageView.alpha = highlighted ? 0.6 : 1.;
}

+ (UIImage *)imageForBackButton;
{
  return [UIImage jm_imageFromDrawingBlock:^(CGRect bounds) {
    [UIView jm_drawShadowed:^{
      [[UIColor colorForBarButtonItem] set];
      UIBezierPath *trianglePath = [UIBezierPath bezierPathWithTriangleCenter:CGPointMake(23., 16.) sideLength:11. angle:270.];
      [trianglePath fill];
      
//      UIBezierPath *gripPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(27., 6., 2.5, 2.5)];
//
//      for (int i=0; i<3; i++)
//      {
//        [gripPath fill];
//        [gripPath applyTransform:CGAffineTransformMakeTranslation(0., 6.)];
//      }
      
    } shadowColor:[UIColor colorForBarButtonItemShadow]];
    
  } withSize:CGSizeMake(70., 28.)];
}



@end
