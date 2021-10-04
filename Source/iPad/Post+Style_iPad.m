//
//  Post+Style_iPad.m
//  AlienBlue
//
//  Created by J M on 20/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "Post+Style_iPad.h"
#import "Post+Style.h"
#import "Resources.h"

@implementation Post (Style_iPad)

- (void)drawSubdetailsInRect_iPad:(CGRect)rect context:(CGContextRef)context;
{
  UIColor *subredditColor = [UIColor colorForHighlightedText];
  UIColor *otherDetailsColor = [Resources isNight] ? [UIColor colorWithHex:0x9c9c9c] : [UIColor colorWithHex:0x999999];
  UIColor *separatorColor = [UIColor colorWithWhite:0.5 alpha:0.2];

  NSString *separator = @" • ";
  
  UIFont *font;
  font = [UIFont skinFontWithName:kBundleFontPostSubtitle_iPad];
  
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
  
  if (!JMIsEmpty(self.tinyDomain) && ![self.tinyDomain contains:@"self"])
  {
    [separatorColor set];
    [separator drawAtPoint:CGPointMake(xOffset, yOffset) withFont:font];
    xOffset += separatorWidth;
    
    [otherDetailsColor set];
    NSString *domain = self.tinyDomain;
    [domain drawAtPoint:CGPointMake(xOffset, yOffset) withFont:font];
    xOffset += [domain widthWithFont:font];
  }
  
  CGFloat maxWidth = rect.size.width - 10.;
  if (self.thumbnail != nil)
  {
    maxWidth -= 60.;
  }
  
  if (self.nsfw || self.stickied)
  {
    maxWidth -= 50.;
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

- (NSAttributedString *)styledTitleWithDetails_iPad;
{
  NSMutableAttributedString *styledText = [[NSMutableAttributedString alloc] init];
  [styledText appendAttributedString:[self styledTitle]];
  
  UIColor *titleColor = [UIColor colorForText];
  CTFontRef fontRef = [UIFont skinFontRefWithName:kBundleFontPostTitleBold_iPad];
  
  [styledText applyAttribute:(id)kCTForegroundColorAttributeName value:(id)titleColor.CGColor];
  [styledText applyAttribute:(id)kCTFontAttributeName value:(__bridge id)fontRef];
  
  NSString *leadingSpace = @"";
  NSString *commentIconStr = @"comments";
  NSString *subdetails = [NSString stringWithFormat:@"\n%@%@   •   %d %@", leadingSpace, self.domain, self.numComments, commentIconStr];
  
  NSMutableAttributedString *styledSubdetails = [[NSMutableAttributedString alloc] initWithString:subdetails];
  
  UIColor *subtitleColor = [UIColor grayColor];
  CTFontRef subtitleFontRef;
  
  subtitleFontRef = [UIFont skinFontRefWithName:kBundleFontPostSubtitle];
  
  [styledSubdetails applyAttribute:(id)kCTForegroundColorAttributeName value:(id)subtitleColor.CGColor];
  [styledSubdetails applyAttribute:(id)kCTFontAttributeName value:(__bridge id)subtitleFontRef];
  
  CGFloat lineSpacing = 4.;
  
  CTParagraphStyleSetting paragraphSettings[1] =
  {
    { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(lineSpacing), &lineSpacing}
  };
  CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphSettings, 1);
  [styledSubdetails applyAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)paragraphStyle];
  CFRelease(paragraphStyle);
  
  [styledText appendAttributedString:styledSubdetails];
  
  return styledText;
}

@end
