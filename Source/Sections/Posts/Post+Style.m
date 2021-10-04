//
//  Post+Style.m
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Post+Style.h"
#import "Post+Style_iPad.h"
#import "Post+Style_iPhone.h"
#import "Resources.h"
#import "NSMutableAttributedString+ABAdditions.h"
#import "JMViewOverlay+NavigationButton.h"

@interface Post (Style_)
@property (nonatomic,strong) NSCache *heightCache;
@end

@implementation Post (Style)

SYNTHESIZE_ASSOCIATED_STRONG(NSCache, heightCache, HeightCache);

- (NSAttributedString *)styledTitle;
{
  if (!self.cachedStyledTitle)
  {
    CGFloat lineSpacing = [Resources compact] ? 0.4 : 4.;
    CGFloat kernFactor = 0.;
  
    CTParagraphStyleSetting paragraphSettings[1] =
    {
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing}
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphSettings, 1);
    
    NSString *fontKey = [UDefaults boolForKey:kABSettingKeyBoldPostTitles] ? kBundleFontPostTitleBold : kBundleFontPostTitle;
    UIFont *titleFont = [UIFont skinFontWithName:fontKey];
    UIColor *titleColor = self.visited ? [UIColor grayColor] : [UIColor colorForText];
    CTFontRef titleFontRef = [titleFont jm_fontRef];
  
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSNumber *kerning = [NSNumber numberWithFloat:-1 * titleFont.pointSize * kernFactor];
    [attributes setObject:kerning forKey:(id)kCTKernAttributeName];
    [attributes setObject:CFBridgingRelease(titleFontRef) forKey:(id)kCTFontAttributeName];
    [attributes setObject:(__bridge id)paragraphStyle forKey:(id)kCTParagraphStyleAttributeName];
    [attributes setObject:(id)titleColor.CGColor forKey:(id)kCTForegroundColorAttributeName];
    
    NSMutableAttributedString *styledText = [[NSMutableAttributedString alloc] initWithString:self.title attributes:attributes];
    
    CFRelease(paragraphStyle);
    self.cachedStyledTitle = styledText;
  }
  return self.cachedStyledTitle;
}

- (NSAttributedString *)styledTitleWithDetails;
{
    NSMutableAttributedString *styledText = [[NSMutableAttributedString alloc] init];
    [styledText appendAttributedString:[self styledTitle]];
    
    UIColor *titleColor = [UIColor colorForText];
    CTFontRef fontRef = [UIFont skinFontRefWithName:kBundleFontCommentBody];

    [styledText applyAttribute:(id)kCTForegroundColorAttributeName value:(id)titleColor.CGColor];
    [styledText applyAttribute:(id)kCTFontAttributeName value:(__bridge id)fontRef];
  
//    // leading space is used to make way for a favicon
//    NSString *leadingSpace = (self.linkType != LinkTypeSelf && ![self.url contains:@"reddit"]) ? @"      " : @"";
    NSString *leadingSpace = @"";
    NSString *domainName = [self.domain jm_truncateToLength:20];
    NSString *subdetails = [NSString stringWithFormat:@"\n%@%@ ┊ %d comments", leadingSpace, domainName, self.numComments];
  
    NSMutableAttributedString *styledSubdetails = [[NSMutableAttributedString alloc] initWithString:subdetails];
    
    UIColor *subtitleColor = [UIColor grayColor];
    CTFontRef subtitleFontRef;
    
    if (JMIsRetina())
    {
        subtitleFontRef = [UIFont skinFontRefWithName:kBundleFontPostSubtitle];
    }
    else
    {
        subtitleFontRef = [UIFont skinFontRefWithName:kBundleFontPostSubtitleBold];        
    }

//  ┊
//  BOX DRAWINGS LIGHT QUADRUPLE DASH VERTICAL
//Unicode: U+250A, UTF-8: E2 94 8A
//    [styledSubdetails applyAttribute:(id)kCTForegroundColorAttributeName value:(id)subtitleColor.CGColor];
    [styledSubdetails applyAttribute:(id)kCTFontAttributeName value:(__bridge id)subtitleFontRef];
    [styledSubdetails jm_applyColor:subtitleColor];
    [styledSubdetails jm_applyColor:[subtitleColor colorWithAlphaComponent:0.5] toString:@"┊"];

//  ⦙
//  DOTTED FENCE
//Unicode: U+2999, UTF-8: E2 A6 99
  CGFloat lineSpacing = 3.;
  
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

- (void)flushCachedStyles;
{
  [self updateVisitedStatus];
  self.cachedStyledTitle = nil;
  [self.heightCache removeAllObjects];
}

- (void)preprocessStyles;
{
  [self styledTitle];
}

- (CGFloat)_heightForTitleConstrainedToWidth:(CGFloat)width;
{
  if (JMIsEmpty(self.title))
    return 0.;
  
  return [self.styledTitle heightConstrainedToWidth:width];
}


- (CGFloat)titleHeightConstrainedToWidth:(CGFloat)width;
{
  if (!self.heightCache)
  {
    self.heightCache = [[NSCache alloc] init];
  }
  
  NSString *cacheKey = [NSString stringWithFormat:@"%0.f", width];
  NSNumber *cachedHeight = [self.heightCache objectForKey:cacheKey];

  if (cachedHeight)
  {
    return [cachedHeight floatValue];
  }
  else
  {
    CGFloat height = [self _heightForTitleConstrainedToWidth:width];
    NSNumber *cachedHeight = [NSNumber numberWithFloat:height];
    [self.heightCache setObject:cachedHeight forKey:cacheKey];
    return height;
  }
}

- (void)drawTitleCenteredVerticallyInRect:(CGRect)rect context:(CGContextRef)context;
{
  CGRect titleRect = rect;
  [self.styledTitle drawCenteredVerticallyInRect:titleRect];
}

- (void)drawCommentCountInRect:(CGRect)rect context:(CGContextRef)context;
{
  UIColor *textColor = [UIColor colorForHighlightedText];
  UIFont *font = [UIFont skinFontWithName:kBundleFontPostSubtitleBold];

  BOOL shouldDecimalize = self.numComments < 10000;
  NSString *commentCount = [NSString shortFormattedStringFromNumber:self.numComments shouldDecimilaze:shouldDecimalize];

  [UIView jm_drawShadowed:^{
    [textColor set];
    [commentCount drawInRect:rect withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
  } shadowColor:[UIColor colorForInsetDropShadow]];
}

- (void)drawTimeAgoInRect:(CGRect)rect context:(CGContextRef)context;
{
  UIColor *textColor = [Resources isNight] ? [UIColor colorWithHex:0xacacac] : [UIColor colorWithHex:0x8c8c8c];
  UIFont *font = [UIFont skinFontWithName:kBundleFontPostSubtitle];
  
  [textColor set];
  [self.tinyTimeAgo drawInRect:rect withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

- (void)drawSubdetailsInRect:(CGRect)rect context:(CGContextRef)context;
{
  if (JMIsIpad())
  {
    [self drawSubdetailsInRect_iPad:rect context:context];
  }
  else
  {
    [self drawSubdetailsInRect_iPhone:rect context:context];
  }
}

- (UIColor *)linkFlairBackgroundColorForPresentation;
{
  if ([UDefaults boolForKey:kABSettingKeyShowNSFWRibbon] && self.needsNSFWWarning)
  {
    return JMHexColor(960000);
  }
  
  if (self.stickied)
  {
    return [UIColor skinColorForConstructive];
  }
  
  if (self.promoted)
  {
    return [UIColor colorForHighlightedOptions];
  }
  
  if ([UDefaults boolForKey:kABSettingKeyShowPostFlair] && !JMIsEmpty(self.linkFlairText))
  {
    return [UIColor colorWithWhite:0.5 alpha:0.5];
  }
  
  return nil;
}

@end
