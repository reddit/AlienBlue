//
//  Post+Style_iPhone.m
//  AlienBlue
//
//  Created by JM on 28/12/12.
//
//

#import "Post+Style_iPhone.h"
#import "Resources.h"

@implementation Post (Style_iPhone)

- (void)drawSubdetailsInRect_iPhone:(CGRect)rect context:(CGContextRef)context;
{
  UIColor *subredditColor = [UIColor colorForHighlightedText];
  UIColor *otherDetailsColor = [Resources isNight] ? [UIColor colorWithHex:0x9c9c9c] : [UIColor colorWithHex:0x999999];
  UIColor *separatorColor = [UIColor colorWithWhite:0.5 alpha:0.2];

  NSString *separator = @" • ";
  
  UIFont *font;
  font = JMIsRetina() ? [UIFont skinFontWithName:kBundleFontPostSubtitle] : [UIFont skinFontWithName:kBundleFontPostSubtitleBold];
  
  CGFloat separatorWidth = [separator widthWithFont:font];
  if (JMIsIOS7() && ![NSThread isMainThread])
  {
    separatorWidth += 3.;
  }
  
  CGFloat xOffset = rect.origin.x + 7.;
  CGFloat yOffset = rect.origin.y;
  
  NSString *subreddit = self.subreddit;
  if (self.thumbnail)
  {
    subreddit = [subreddit limitToLength:15];
  }
  
  [subredditColor set];
  [subreddit drawAtPoint:CGPointMake(xOffset, yOffset) withFont:font];
  xOffset += [subreddit widthWithFont:font];
  
  CGFloat maxWidth = (JMPortrait() ? 255. : MAXFLOAT);
  if (self.thumbnail != nil)
  {
    maxWidth -= 60.;
  }
  
  if (self.nsfw || self.stickied || !JMIsEmpty(self.linkFlairTextForPresentation))
  {
    maxWidth -= 70.;
  }
  
  if (!JMIsEmpty(self.tinyDomain) && ![self.tinyDomain contains:@"self"])
  {
    [separatorColor set];
    [separator drawAtPoint:CGPointMake(xOffset, yOffset) withFont:font];
    xOffset += separatorWidth;
    
    [otherDetailsColor set];
    NSUInteger limitDomainToLength = (maxWidth < 180) ? 13 : 20;
    NSString *domain = [self.tinyDomain limitToLength:limitDomainToLength];
    [domain drawAtPoint:CGPointMake(xOffset, yOffset) withFont:font];
    xOffset += [domain widthWithFont:font];
  }
  
  NSString *author = [self.author limitToLength:14];
  CGFloat authorWidth = [author widthWithFont:font];
  
  if (!JMIsEmpty(author) && (xOffset + separatorWidth + authorWidth) < maxWidth)
  {
    [separatorColor set];
    [separator drawAtPoint:CGPointMake(xOffset, yOffset) withFont:font];
    xOffset += separatorWidth;
    
    [otherDetailsColor set];
    [author drawAtPoint:CGPointMake(xOffset, yOffset) withFont:font];
  }
}

@end
