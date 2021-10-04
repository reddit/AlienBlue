//
//  Comment+Style.m
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Comment+Style.h"
#import "MarkupEngine.h"

@interface Comment (Style_)
@property (nonatomic,strong) NSCache *heightCache;
@end

@implementation Comment (Style)

SYNTHESIZE_ASSOCIATED_STRONG(NSCache, heightCache, HeightCache);

- (NSAttributedString *)styledBody;
{
    if (!self.cachedStyledBody)
    {
//        CGFloat lineSpacing = 4.0f;
//        CTParagraphStyleSetting paragraphSettings[1] =
//        {
//            { kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing}
//        };
//        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphSettings, 1);
//        
//        UIFont *titleFont = [UIFont skinFontWithName:kBundleFontPostTitle];
//        CTFontRef titleFontRef = [UIFont skinFontRefWithName:kBundleFontPostTitle];
//        UIColor *titleColor = [UIColor colorForText];
//        
//        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
//        NSNumber *kerning = [NSNumber numberWithFloat:-1 * titleFont.pointSize * 0.02];
//        [attributes setObject:kerning forKey:(id)kCTKernAttributeName];
//        [attributes setObject:(__bridge id)titleFontRef forKey:(id)kCTFontAttributeName];
//        [attributes setObject:(__bridge id)paragraphStyle forKey:(id)kCTParagraphStyleAttributeName];
//        [attributes setObject:(id)titleColor.CGColor forKey:(id)kCTForegroundColorAttributeName];
//        
//        NSMutableAttributedString *styledText = [[NSMutableAttributedString alloc] initWithString:self.title attributes:attributes];
//        
//        CFRelease(paragraphStyle);
        NSMutableAttributedString *styledText = [MarkupEngine markDownHTML:self.bodyHTML forSubreddit:self.subreddit];
        self.cachedStyledBody = styledText;
    }
    return self.cachedStyledBody;
}

- (CGFloat)heightForBodyConstrainedToWidth:(CGFloat)width;
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
        CGFloat height = [MarkupEngine heightOfAttributedString:(__bridge CFAttributedStringRef)[self.styledBody copy] constrainedToWidth:width];
        NSNumber *cachedHeight = [NSNumber numberWithFloat:height];
        [self.heightCache setObject:cachedHeight forKey:cacheKey];
        return height;
    }
}

- (void)flushCachedStyles;
{
    self.cachedStyledBody = nil;
    [self.heightCache removeAllObjects];
}


@end
