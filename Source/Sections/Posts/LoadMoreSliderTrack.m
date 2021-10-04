#import "LoadMoreSliderTrack.h"
#import "Resources.h"
#import "JMSliderConstants.h"

@interface LoadMoreSliderTrack()
@end

@implementation LoadMoreSliderTrack

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame forSlider:(JMSlider *)slider;
{
  self = [super initWithFrame:frame forSlider:slider];
  if (self)
  {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];        
  }
  return self;
}

- (void)defaultsChanged:(NSNotification *)notification 
{
  // listen for changes in SkinTheme
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect;
{
//  UIColor *sectionHeaderBackgroundColor = kJMSliderTrackColor;
//  UIColor * backgroundColor = [Resources isNight] ? [UIColor darkGrayColor] : sectionHeaderBackgroundColor;
  [kJMSliderTrackColor set];
  
  CGFloat trackSize = 0.5;
  CGFloat buttonWidth = [self.slider centerViewWidth];
  CGFloat lowCenter = [self.slider trackLowCenter];
  
  CGRect trackRect = CGRectInset(self.bounds, lowCenter + kJMSliderTrackEdgeRadius - (buttonWidth / 4.), (rect.size.height - trackSize) / 2);
  UIBezierPath * trackPath = [UIBezierPath bezierPathWithRoundedRect:trackRect cornerRadius:2.];
  [trackPath fill];
  
  if (self.highlighted)
  {
    CGRect leftEdgeRect = CGRectMake(CGRectGetMinX(trackRect) - kJMSliderTrackEdgeRadius, CGRectGetMidY(trackRect) - 0.5, 1., 1.);
    UIBezierPath * leftEdgePath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(leftEdgeRect, -1. * kJMSliderTrackEdgeRadius, -1. * kJMSliderTrackEdgeRadius)];
    [leftEdgePath fill];
    
    CGRect rightEdgeRect = CGRectMake(CGRectGetMaxX(trackRect) + kJMSliderTrackEdgeRadius, CGRectGetMidY(trackRect) - 0.5, 1., 1.);
    UIBezierPath * rightEdgePath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rightEdgeRect, -1. * kJMSliderTrackEdgeRadius, -1. * kJMSliderTrackEdgeRadius)];
    [rightEdgePath fill];
  }
}

@end
