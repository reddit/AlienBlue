//
//  MarkupEngine.m
//  AlienBlue
//
//  Created by JM on 13/11/10.
//  Copyright (c) 2010 The Design Shed. All rights reserved.
//

#import "MarkupEngine.h"
#import "Resources.h"
#import "ABBundleManager.h"
#import "SubredditManager.h"
#import "NSString+HTML.h"
#import "NSString+ABLegacyLinkTypes.h"

static CTParagraphStyleRef baseStyle;
static CTParagraphStyleRef quoteStyle;
static BOOL doesSupportMarkdown;

@implementation MarkupEngine

+ (void)initialize
{
	if (self == [MarkupEngine class]) 
  {
		doesSupportMarkdown = (NSClassFromString( @"NSAttributedString" ) != nil);
		[self refreshCoreTextStyles];
	}
}

+ (BOOL)doesSupportMarkdown
{
	return doesSupportMarkdown;
}

+ (NSString *)flattenHTML:(NSString *)html
{
  NSScanner *theScanner = [NSScanner scannerWithString:html];
  NSString *text = nil;

  while ([theScanner isAtEnd] == NO)
  {
    [theScanner scanUpToString:@"<" intoString:NULL] ;
    [theScanner scanUpToString:@">" intoString:&text] ;
    html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
  }
  return html;
}


+ (NSString *)removeUnnecessaryTags:(NSString *)html
{
  NSScanner *theScanner = [NSScanner scannerWithString:html];
  NSString *text = nil;

  while ([theScanner isAtEnd] == NO)
  {
    [theScanner scanUpToString:@"<" intoString:NULL];
    [theScanner scanUpToString:@">" intoString:&text];
  
    if ([text rangeOfString:@"blockquote"].location == NSNotFound
      && [text rangeOfString:@"strong"].location == NSNotFound
      && ![text isEqualToString:@"i"] && ![text isEqualToString:@"/i"])
    {
      html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
  }
  
  return html;
}

CTFontDescriptorRef CreateFontDescriptorFromFamilyAndTraits(CFStringRef iFamilyName, CTFontSymbolicTraits iTraits, CGFloat iSize)
{
  CTFontDescriptorRef descriptor = NULL;
  CFMutableDictionaryRef attributes;

  assert(iFamilyName != NULL);
  attributes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

  if (attributes != NULL)
  {
    CFMutableDictionaryRef traits;
    CFNumberRef symTraits;

    CFDictionaryAddValue(attributes, kCTFontFamilyNameAttribute, iFamilyName);
    symTraits = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &iTraits);

    if (symTraits != NULL)
    {
      traits = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
      if (traits != NULL)
      {
        CFDictionaryAddValue(traits, kCTFontSymbolicTrait, symTraits);
        CFDictionaryAddValue(attributes, kCTFontTraitsAttribute, traits);
        CFRelease(traits);
      }
      CFRelease(symTraits);
    }
    descriptor = CTFontDescriptorCreateWithAttributes(attributes);
    CFRelease(attributes);
  }
  return descriptor;
}

CTFontRef CreateFont(CTFontDescriptorRef iFontDescriptor, CGFloat iSize)
{
  return CTFontCreateWithFontDescriptor(iFontDescriptor, iSize, NULL);
}

+ (void)refreshCoreTextStyles
{
	if (![self doesSupportMarkdown])
		return;
	
	if (baseStyle)
	{
		CFRelease(baseStyle);
	}
	if (quoteStyle)
	{
		CFRelease(quoteStyle);
	}
	
  // Normal Formatting
	CGFloat lineSpacing = [Resources compact] ? 0.4 : 4.;
	CGFloat paragraphSpacing = 8.0f;	
	CFIndex numberOfBaseSettings = 3;
	CTParagraphStyleSetting baseSettings[2] =
	{
		{ kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing},
		{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(paragraphSpacing), &paragraphSpacing}
	};	
	baseStyle = CTParagraphStyleCreate(baseSettings, numberOfBaseSettings);

	//  Quote Formatting
	CGFloat headIndent = 14.0f;	
	CFIndex numberOfQuoteSettings = 5;
	CGFloat quoteParagraphSpacingAfter = 4.0f;	
	CTParagraphStyleSetting quoteSettings[4] =
	{
		{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(headIndent), &headIndent},
		{ kCTParagraphStyleSpecifierHeadIndent, sizeof(headIndent), &headIndent},
		{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(quoteParagraphSpacingAfter), &quoteParagraphSpacingAfter},
		{ kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing}
	};	
	quoteStyle = CTParagraphStyleCreate(quoteSettings, numberOfQuoteSettings);
}


#pragma mark - Coretext Callbacks

void MyDeallocationCallback(void *refCon)
{
}

CGFloat MyGetAscentCallback(void *refCon)
{
	UIImage * image = (__bridge UIImage *) refCon;
	return [image size].height / 2;
}

CGFloat MyGetDescentCallback(void *refCon)
{
	UIImage * image = (__bridge UIImage *) refCon;
	return [image size].height / 2;
}

CGFloat MyGetWidthCallback(void* refCon)
{
	UIImage * image = (__bridge UIImage *) refCon;
	return [image size].width;
}

#pragma mark - Coretext Image Extension

+ (void)insertImage:(UIImage *)image inAttributedString:(NSMutableAttributedString *)attrString atIndex:(NSUInteger)atIndex
{
	if (!attrString)
		return;
	
	if (atIndex > [[attrString string] length])
		return;
	
	NSMutableDictionary * imageAttributeDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys: image, kABCoreTextImage, nil];
	
  CTRunDelegateCallbacks callbacks;
  callbacks.version = kCTRunDelegateCurrentVersion;
  callbacks.dealloc = MyDeallocationCallback;
  callbacks.getAscent = MyGetAscentCallback;
  callbacks.getDescent = MyGetDescentCallback;
  callbacks.getWidth = MyGetWidthCallback;
  CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)image);

	[imageAttributeDictionary setValue:(__bridge id)delegate forKey:(NSString *)kCTRunDelegateAttributeName];
	
	NSMutableAttributedString * imageAttribute = [[NSMutableAttributedString alloc] initWithString:@"\ufffc"];
	[imageAttribute setAttributes:imageAttributeDictionary range:NSMakeRange(0,1)];
	
	[attrString insertAttributedString:imageAttribute atIndex:atIndex];
  CFRelease(delegate);
}


+ (NSMutableAttributedString *)convertHTMLToCFAttributedString:(NSString *)html forSubreddit:(NSString *)subreddit
{
	NSMutableAttributedString * as = [[NSMutableAttributedString alloc] initWithString:html];
	CFMutableAttributedStringRef arf = (__bridge CFMutableAttributedStringRef) as;
  NSScanner *theScanner;
  NSString *text = nil;
		
	CFAttributedStringSetAttribute(arf, CFRangeMake(0, CFAttributedStringGetLength(arf)-1), kCTParagraphStyleAttributeName, baseStyle);
	CFAttributedStringSetAttribute(arf, CFRangeMake(0, CFAttributedStringGetLength(arf)-1), kCTFontAttributeName, [[ABBundleManager sharedManager] fontRefForKey:kBundleFontCommentBody]);
	CFAttributedStringSetAttribute(arf, CFRangeMake(0, CFAttributedStringGetLength(arf)-1), kCTForegroundColorAttributeName, [UIColor colorForText].CGColor);		
	
	theScanner = [NSScanner scannerWithString:html];
	int startTag = -1;
	int endTag = -1;
  while ([theScanner isAtEnd] == NO)
  {
    [theScanner scanUpToString:@"<" intoString:NULL];
    startTag = [theScanner scanLocation];
    [theScanner scanUpToString:@">" intoString:&text];

    if (!text)
        break;
  
    if ([text isEqualToString:@"<blockquote"])
    {
      [theScanner scanUpToString:@"/blockquote" intoString:NULL];
      endTag = [theScanner scanLocation];
      if (![theScanner isAtEnd] && endTag > startTag)
      {
        int taglength = 12; // includes < >
        CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag), kCTParagraphStyleAttributeName, quoteStyle);				
        CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag), kCTForegroundColorAttributeName, [UIColor grayColor].CGColor);
        [as deleteCharactersInRange:NSMakeRange(startTag, taglength)];
        theScanner = [NSScanner scannerWithString:[as string]];
        [theScanner setScanLocation:startTag + 1];
      }
    }
    else if ([text rangeOfString:@"<h"].location != NSNotFound)
    {
      [theScanner scanUpToString:@"/h" intoString:NULL];
      endTag = [theScanner scanLocation];
      if (![theScanner isAtEnd] && endTag > startTag)
      {
        int taglength = 4; // includes < >
        CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag), kCTFontAttributeName, [[ABBundleManager sharedManager] fontRefForKey:kBundleFontCommentBodyBold]);		
        CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag), kCTForegroundColorAttributeName, [UIColor grayColor].CGColor);
        if ([text equalsString:@"<h4"])
        {
          CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag), kCTForegroundColorAttributeName, [UIColor colorWithHex:0xad49e1].CGColor);
        }
        [as deleteCharactersInRange:NSMakeRange(startTag, taglength)];
        theScanner = [NSScanner scannerWithString:[as string]];
        [theScanner setScanLocation:startTag];
      }
    }
    else if ([text isEqualToString:@"<strong"])
    {
      [theScanner scanUpToString:@"/strong" intoString:NULL];
      endTag = [theScanner scanLocation];
      if (![theScanner isAtEnd] && endTag > startTag)
      {
        int taglength = 8; // includes < >
        CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag), kCTFontAttributeName, [[ABBundleManager sharedManager] fontRefForKey:kBundleFontCommentBodyBold]);		
        [as deleteCharactersInRange:NSMakeRange(startTag, taglength)];
        theScanner = [NSScanner scannerWithString:[as string]];
        [theScanner setScanLocation:startTag];
      }
    }
    else if ([text isEqualToString:@"<del"])
    {
      [theScanner scanUpToString:@"/del" intoString:NULL];
      endTag = [theScanner scanLocation];
      if (![theScanner isAtEnd] && endTag > startTag)
      {
        int taglength = 5; // includes < >
        NSRange rangeOfDeletedString = NSMakeRange(startTag + taglength, endTag - startTag - taglength - 1);
        NSString *deletedString = [as.string substringWithRange:rangeOfDeletedString];
        [as.mutableString replaceOccurrencesOfString:deletedString withString:[NSString stringWithFormat:@"[removed: %@]", deletedString] options:NSCaseInsensitiveSearch range:rangeOfDeletedString];
        CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag + 11), kCTForegroundColorAttributeName, [UIColor colorWithWhite:0.5 alpha:0.6].CGColor);
        [as deleteCharactersInRange:NSMakeRange(startTag, taglength)];
        theScanner = [NSScanner scannerWithString:[as string]];
        [theScanner setScanLocation:startTag];
      }
    }
    else if ([text isEqualToString:@"<em"])
    {
      [theScanner scanUpToString:@"/em" intoString:NULL];
      endTag = [theScanner scanLocation];
      if (![theScanner isAtEnd] && endTag > startTag)
      {
        int taglength = 4; // includes < >
        CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag), kCTFontAttributeName, [[ABBundleManager sharedManager] fontRefForKey:kBundleFontCommentBodyItalic]);
        [as deleteCharactersInRange:NSMakeRange(startTag, taglength)];
        theScanner = [NSScanner scannerWithString:[as string]];
        [theScanner setScanLocation:startTag];
      }
    }
    else if ([text isEqualToString:@"<table"])
    {
      [theScanner scanUpToString:@"/table" intoString:NULL];
      endTag = [theScanner scanLocation];
      if (![theScanner isAtEnd] && endTag > startTag)
      {
        int taglength = 7; // includes < >
        NSRange tableStringRange = NSMakeRange(startTag, endTag - startTag + taglength);
        NSString *tableString = [as.string substringWithRange:tableStringRange];
        [as deleteCharactersInRange:tableStringRange];
        
        NSString *htmlLink = [NSString stringWithFormat:@"html://%@", tableString];
        NSMutableAttributedString *showTableAttributedString = [[NSMutableAttributedString alloc] initWithString:@"Show Table"];
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)showTableAttributedString, CFRangeMake(0, CFAttributedStringGetLength((__bridge CFMutableAttributedStringRef)showTableAttributedString)), kCTFontAttributeName,
                                       [[ABBundleManager sharedManager] fontRefForKey:kBundleFontCommentBodyBold]
                                       );
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)showTableAttributedString, CFRangeMake(0, CFAttributedStringGetLength((__bridge CFMutableAttributedStringRef)showTableAttributedString)), kCTForegroundColorAttributeName, JMHexColor(da4aba).CGColor);
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)showTableAttributedString, CFRangeMake(0, CFAttributedStringGetLength((__bridge CFMutableAttributedStringRef)showTableAttributedString)), CFSTR("link_url"), (__bridge CFTypeRef)htmlLink);
        
        CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)showTableAttributedString, CFRangeMake(0, CFAttributedStringGetLength((__bridge CFMutableAttributedStringRef)showTableAttributedString)), kCTParagraphStyleAttributeName, baseStyle);
        
        [as insertAttributedString:showTableAttributedString atIndex:startTag];
        theScanner = [NSScanner scannerWithString:[as string]];
        [theScanner setScanLocation:startTag];
      }
    }
    else if ([text rangeOfString:@"<a href"].location != NSNotFound)
    {
      NSString * url = nil;
      [theScanner setScanLocation:startTag + 9];
      [theScanner scanUpToString:@"\"" intoString:&url];
    
      NSString * atagString = nil;
      NSString * caption = nil;
      NSMutableAttributedString * titleString = nil;
      UIImage * image = nil;
      [theScanner scanUpToString:@"/a>" intoString:&atagString];
      
      endTag = [theScanner scanLocation];
      if (![theScanner isAtEnd] && endTag > startTag)
      {
        if (url)
        {
          if ([atagString rangeOfString:@"title=\""].location != NSNotFound)
          {
            NSString * title = nil;							
            NSScanner * hrefScanner = [NSScanner scannerWithString:atagString];
            [hrefScanner scanUpToString:@"title=\"" intoString:nil];
            [hrefScanner setScanLocation:[hrefScanner scanLocation] + 7];
            [hrefScanner scanUpToString:@"\"" intoString:&title];
            
            titleString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"<p>\"%@\"</p>", title]];
            
            CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)titleString, CFRangeMake(0, CFAttributedStringGetLength((__bridge CFMutableAttributedStringRef)titleString)-1), kCTFontAttributeName,
                             [[ABBundleManager sharedManager] fontRefForKey:kBundleFontCommentBodyItalic]
                             );
            CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)titleString, CFRangeMake(0, CFAttributedStringGetLength((__bridge CFMutableAttributedStringRef)titleString)-1), kCTForegroundColorAttributeName, [UIColor colorForText].CGColor);
            
            if (![hrefScanner isAtEnd])
              [hrefScanner scanUpToString:@">" intoString:nil];
            if (![hrefScanner isAtEnd])
              [hrefScanner setScanLocation:[hrefScanner scanLocation] + 1];
            if (![hrefScanner isAtEnd])
              [hrefScanner scanUpToString:@"</a>" intoString:&caption];
            if (![hrefScanner isAtEnd])
              caption = [caption substringToIndex:[caption length] - 1];
          }
          
          if ([url length] > 0 && [url characterAtIndex:0] == '/')
          {
            if ([subreddit isKindOfClass:[NSString class]])
            {
                image = [[SubredditManager sharedSubredditManager] imageForTag:url inSubreddit:subreddit];
            }
          }
          
          CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag), CFSTR("link_url"), (__bridge CFTypeRef)([NSString ab_fixImgurLink:url]));
        }
                
        CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, endTag - startTag), kCTForegroundColorAttributeName, [UIColor colorForHighlightedText].CGColor);
        
        [as deleteCharactersInRange:NSMakeRange(startTag, [text length] + 1)];

        if (titleString)
        {
          if ([caption rangeOfString:@"spoiler" options:NSCaseInsensitiveSearch].location != NSNotFound || [url linkContainsSpoilerTag])
          {
            CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, [caption length]), CFSTR("link_url"), (__bridge CFTypeRef)([NSString stringWithFormat:@"Spoiler: %@", [titleString string]]));
            CFAttributedStringSetAttribute(arf, CFRangeMake(startTag, [caption length]), kCTFontAttributeName,
                             [[ABBundleManager sharedManager] fontRefForKey:kBundleFontCommentBodyBold]
                             );
          }
          else 
          {
            [as insertAttributedString:titleString atIndex:startTag];
          }
        }

        if (image)
        {
          [self insertImage:image inAttributedString:as atIndex:startTag];
        }
        
        
        theScanner = [NSScanner scannerWithString:[as string]];
        [theScanner setScanLocation:startTag];
      }
    }				
    else if (![theScanner isAtEnd] && startTag < [theScanner scanLocation])
    {
      [as deleteCharactersInRange:NSMakeRange(startTag, [theScanner scanLocation] - startTag + 1)];
      theScanner = [NSScanner scannerWithString:[as string]];			
      [theScanner setScanLocation:0];
    }
  } // while //
  
  return as;
}

+ (CGFloat)heightOfAttributedString:(CFAttributedStringRef)as constrainedToWidth:(CGFloat)width
{
	if (!as)
		return 0;
    
  CGSize newSize = CGSizeZero;
	CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
  @synchronized((__bridge NSAttributedString *)as)
  {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(as);
    newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, maxSize, NULL);
    CFRelease(framesetter);
  }
	return roundf(newSize.height);
}

+ (NSMutableAttributedString *)markDownHTML:(NSString *)html forSubreddit:(NSString *)subreddit
{
	if (html && [html isKindOfClass:[NSString class]] && [html length] > 0)
	{
		NSMutableString * ms = [NSMutableString stringWithString:html];
        
    [ms jm_mutableReplaceString:@"&lt;" withString:@"<"];
    [ms jm_mutableReplaceString:@"&gt;" withString:@">"];
    [ms jm_mutableReplaceString:@"&amp;" withString:@"&"];

    [ms jm_mutableReplaceString:@"<li>" withString:@"· "];
    [ms jm_mutableRemoveOccurrencesOfString:@"<ul>\n"];
    [ms jm_mutableRemoveOccurrencesOfString:@"\n</ul>\n"];
    [ms jm_mutableRemoveOccurrencesOfString:@"<ol>\n"];
    [ms jm_mutableRemoveOccurrencesOfString:@"\n</ol>\n"];

    [ms jm_mutableRemoveOccurrencesOfString:@"<hr />\n\n"];
    [ms jm_mutableRemoveOccurrencesOfString:@"<hr/>"];
    [ms jm_mutableRemoveOccurrencesOfString:@"<hr />"];

    [ms jm_mutableReplaceString:@"<strong> <" withString:@"<strong><"];
    [ms jm_mutableReplaceString:@"> </strong>" withString:@"></strong>"];
    [ms jm_mutableReplaceString:@"<blockquote>\n<p>" withString:@"<blockquote>"];
    [ms jm_mutableReplaceString:@"</p>\n</blockquote>" withString:@" </blockquote>"];
    [ms jm_mutableReplaceString:@"<blockquote><em>" withString:@"<blockquote> <em>"];
    [ms jm_mutableReplaceString:@"<blockquote><del>" withString:@"<blockquote> <del>"];
    [ms jm_mutableReplaceString:@"<blockquote><strong>" withString:@"<blockquote> <strong>"];
    [ms jm_mutableReplaceString:@"<blockquote><a href" withString:@"<blockquote> <a href"];
    
    [ms jm_mutableReplaceString:@"\n\n\n" withString:@"\n"];
    [ms jm_mutableReplaceString:@"\n\n" withString:@"\n"];
    [ms jm_mutableReplaceString:@"\n\n" withString:@"\n"];
    
		NSMutableAttributedString *arf = [self convertHTMLToCFAttributedString:ms forSubreddit:subreddit];

    [arf.mutableString jm_mutableReplacePattern:@"&.+?;" replaceInReverseOrder:YES withTransformation:^NSString *(NSString *originalMatch) {
        return [originalMatch stringByDecodingHTMLEntities];
    }];
    
		return arf;
	}
	else
  {
		return [[NSMutableAttributedString alloc] initWithString:@""];
	}
    
}

@end
