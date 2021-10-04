#import "SplashView.h"
#import "AlienBlueAppDelegate.h"
#import "Resources.h"

#define kSplashViewTag 234123
#define kSplashViewAnimation @"kSplashViewAnimation"


@interface SplashView()
@property (nonatomic,strong) UIImageView * splashImageView;
@end

@implementation SplashView

@synthesize splashImageView = splashImageView_;

static SplashView *s_lastPresentedSplashView = nil;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.autoresizingMask = JMFlexibleSizeMask;
        self.backgroundColor = [UIColor blackColor];
        self.splashImageView = [[UIImageView alloc] init];
        self.splashImageView.contentMode = UIViewContentModeCenter;
        self.splashImageView.autoresizingMask = JMFlexibleSizeMask;
        [self addSubview:self.splashImageView];
    }
    return self;
}

- (void)layoutSubviews;
{
    UIImage * splashPng;
    if ([Resources isIPAD])
    {
        splashPng = (JMLandscape()) ? [UIImage imageNamed:@"Default-Landscape"] : [UIImage imageNamed:@"Default-Portrait"];
    }
    else if (JMIsIphone5())
    {
        splashPng = [UIImage imageNamed:@"Default-568h"];
    }
    else if (JMIsIphone6())
    {
      splashPng = [UIImage imageNamed:@"Default-1334h"];
    }
    else if (JMIsIphone6Plus())
    {
      splashPng = [UIImage imageNamed:@"Default-2208h"];
    }
    else
    {
        splashPng = [UIImage imageNamed:@"Default"];
    }
  
  
  CGSize attachedViewSize = [SplashView viewToAttach].size;
  CGFloat yOffset = (attachedViewSize.width == 748 || attachedViewSize.height == 1004) ? -20. : 0.;
  if (JMIsIOS8())
  {
    yOffset = (attachedViewSize.height == 748 || attachedViewSize.height == 1004) ? -20. : 0.;
  }
  
  self.splashImageView.image = splashPng;
  self.splashImageView.frame = CGRectMake(0., yOffset, splashPng.size.width, splashPng.size.height);
  
//    DLog(@"laying out splash in bounds : %@", NSStringFromCGRect(self.superview.superview.frame));
}

- (void)startHiding;
{
    [SplashView hide];    
}

+ (UIView *) viewToAttach;
{
  UIView *viewToAttach = [UIApplication sharedApplication].keyWindow.rootViewController.view;
  return viewToAttach;
}

+ (void)show
{
    if (s_lastPresentedSplashView)
    {
      [s_lastPresentedSplashView removeFromSuperview];
      s_lastPresentedSplashView = nil;
    }
  
    UIView * parentView = [SplashView viewToAttach];
    SplashView * splashView = [[SplashView alloc] initWithFrame:parentView.bounds];
    splashView.tag = kSplashViewTag;
    [parentView addSubview:splashView];
    [splashView setNeedsLayout];
    s_lastPresentedSplashView = splashView;
  
//    if (JMIsIOS8() && JMIsIpad() && JMLandscape())
//    {
//      [splashView layoutSubviews];
//    }
//    [splashView performSelector:@selector(startHiding) withObject:nil afterDelay:1.];
}

+ (void)bringSplashToFront;
{
  UIView * parentView = [SplashView viewToAttach];
  SplashView * splashView = (SplashView *) [parentView viewWithTag:kSplashViewTag];
  [parentView bringSubviewToFront:splashView];
  [splashView setNeedsLayout];
}

+ (void)hide
{
  UIView * parentView = [SplashView viewToAttach];
  SplashView * splashView = (SplashView *) [parentView viewWithTag:kSplashViewTag];
  [UIView beginAnimations:kSplashViewAnimation context:(__bridge void *)splashView];
  [UIView setAnimationDuration:1.8];
  splashView.alpha = 0.;    
  [UIView commitAnimations];
  [splashView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2.5];
}

- (void)removeFromSuperview;
{
  s_lastPresentedSplashView = nil;
  [super removeFromSuperview];
}

@end
