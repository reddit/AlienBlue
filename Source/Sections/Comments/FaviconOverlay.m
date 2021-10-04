#import "FaviconOverlay.h"
#import "ThumbManager.h"

@interface FaviconOverlay()
@property (strong) UIImage *icon;
@end

@implementation FaviconOverlay

- (id)init;
{
  if ((self = [super initWithFrame:CGRectMake(0., 0., 11., 11.)]))
  {
  }
  return self;
}

- (void)updateWithUrl:(NSString *)url;
{
  if (!url || [url isEmpty] || [url contains:@"reddit"])
  {
    self.hidden = YES;
    return;
  }
  else
  {
    self.hidden = NO;
  }
  
  BSELF(FaviconOverlay);
  NSString *iconUrl = [NSString stringWithFormat:@"http://%@/favicon.ico", [url domainFromUrl]];
  self.icon = [[ThumbManager manager] imageForUrl:iconUrl scaleToFitWidth:self.bounds.size.width onComplete:^(UIImage *image) {
    blockSelf.icon = image;
  }];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect;
{
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:2.];
  [path addClip];

  if (!self.icon)
  {
    [[UIColor colorWithWhite:0.5 alpha:0.2] set];
    [path fill];
    
    [[UIColor colorWithWhite:0. alpha:0.2] set];
    [path stroke];
  }
  else
  {
    [self.icon drawAtPoint:CGPointZero];
  }
  
}

@end
