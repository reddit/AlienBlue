//
//  Comment+Preprocess.m
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Comment+Preprocess.h"
#import "CommentLink.h"
#import "RedditAPI.h"
#import "Comment+Style.h"
#import "NSString+ABLegacyLinkTypes.h"
#import "NSString+HTML.h"

@interface Comment (_Preprocess)
- (NSMutableArray *)parseBodyForUndescribedLinks;
- (NSMutableArray *)parseBodyForDescribedLinks;
- (void)processLinks;
@end


@implementation Comment (Preprocess)

- (void)preprocessLinksAndAttributedStyle;
{
    [self processLinks];

    // pre-cache the attributed string version of the comment
  [self styledBody];
}

- (void)preprocessLinksOnly;
{
  [self processLinks];
}

- (void)processLinks;
{
    NSMutableArray *links = [NSMutableArray array];
    [links addObjectsFromArray:[self parseBodyForDescribedLinks]];
    [links addObjectsFromArray:[self parseBodyForUndescribedLinks]];
    self.links = links;
}

- (NSMutableArray *)parseBodyForUndescribedLinks;
{
	NSMutableString * body = [NSMutableString stringWithString:self.body];
    [body appendString:@"\n"];
	NSMutableArray * links = [NSMutableArray array];
	NSInteger bodyLength = [body length];
	NSInteger pos = 0;
	NSInteger start_link_pos = 0;
	NSInteger end_link_pos = 0;
	NSInteger link_counter = 0;
	BOOL linksAvailable = TRUE;
	while (linksAvailable) {
		start_link_pos = [body rangeOfString:@"http" options:NSCaseInsensitiveSearch range:NSMakeRange (pos, bodyLength - pos)].location;
		if (start_link_pos == NSNotFound)
			break;

    BOOL hasValidSuffix = NO;
    NSRange postHttpSuffixRange = NSMakeRange(start_link_pos + @"http".length, 3);
    if (postHttpSuffixRange.location + postHttpSuffixRange.length <= bodyLength)
    {
      NSString *postHttpSuffix = [body substringWithRange:postHttpSuffixRange];
      hasValidSuffix = [postHttpSuffix jm_contains:@"://"] || [postHttpSuffix jm_contains:@"s:/"];
    }
    
		end_link_pos = [body rangeOfString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange (start_link_pos, bodyLength - start_link_pos)].location;
		// also try newline character if space is not found
		NSInteger new_line_pos = [body rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange (start_link_pos, bodyLength - start_link_pos)].location;
		// use the one that is closest to the http
		if (new_line_pos != NSNotFound)
		{
			if (new_line_pos < end_link_pos)
				end_link_pos = new_line_pos;
		}

		if (start_link_pos != NSNotFound && end_link_pos != NSNotFound)
		{
			link_counter++;
			NSString * linkURL = [body substringWithRange:NSMakeRange(start_link_pos, end_link_pos - start_link_pos)];
            
			// we need to ignore described links here, because they're already processed in another
			// method.. we can tell described links, because they will have a ")" when processed here
			if ([linkURL rangeOfString:@")" options:NSCaseInsensitiveSearch].location == NSNotFound && hasValidSuffix)
			{
                CommentLink *link = [[CommentLink alloc] init];
                link.caption = [linkURL domainFromUrl];
                link.originalUrl = linkURL;
                link.url = [NSString ab_fixImgurLink:linkURL];
                link.linkType = [CommentLink linkTypeFromLegacyType:[NSString ab_getLinkType:linkURL]];
                link.isDescribed = NO;                
                
                SET_IF_EMPTY(link.caption, @"");
                SET_IF_EMPTY(link.originalUrl, @"");
                SET_IF_EMPTY(link.url, @"");
                if (![link.url contains:@"/b "] && ![link.url contains:@"/s "] && ![link.url contains:@"/g "])
                {
                    [links addObject:link];
                }
			}
			pos = end_link_pos;
		}
		else
    {
			linksAvailable = FALSE;
    }
	}
	return links;
}

- (NSMutableArray *)parseBodyForDescribedLinks;
{
	NSMutableString * body = [NSMutableString stringWithString:self.body];
  [body appendString:@"\n"];
    //	NSMutableArray * links = [[NSMutableArray alloc] init];
	NSMutableArray * links = [NSMutableArray array];	
	NSInteger bodyLength = [body length];
	NSInteger pos = 0;
	// left square bracket position
	NSInteger lsqb = 0;
	NSInteger rsqb = 0;
    
	// left round bracket
	NSInteger lrb = 0;
	NSInteger rrb = 0;
	NSInteger link_counter = 0;
	BOOL linksAvailable = TRUE;
    
	if (bodyLength == 0)
		return links;
	
	while (linksAvailable) {
		lsqb = [body rangeOfString:@"[" options:NSCaseInsensitiveSearch range:NSMakeRange (pos, bodyLength - pos)].location;
		if (lsqb == NSNotFound)
			break;
		else
			lsqb += 1;
        
		rsqb = [body rangeOfString:@"](" options:NSCaseInsensitiveSearch range:NSMakeRange (lsqb, bodyLength - lsqb)].location;
		if (rsqb == NSNotFound)
			break;
		else
			lrb = rsqb + 2;
		
		rrb = [body rangeOfString:@")" options:NSCaseInsensitiveSearch range:NSMakeRange (lrb, bodyLength - lrb)].location;

    BOOL isInTable = NO;
    if (lsqb != NSNotFound && lsqb > 2)
    {
      NSString *characterBeforeLinkTag = [body substringWithRange:NSMakeRange(lsqb - 2, 1)];
      isInTable = [characterBeforeLinkTag jm_matches:@"|"];
    }
    
    if (lsqb != NSNotFound && rsqb != NSNotFound && rrb != NSNotFound && !isInTable)
		{
			link_counter++;
			NSString * linkName = [body substringWithRange:NSMakeRange(lsqb, rsqb - lsqb)];
      linkName = [linkName stringByDecodingHTMLEntities];
      
			NSString * linkURL = [body substringWithRange:NSMakeRange(lrb, rrb - lrb)];
            
            CommentLink *link = [[CommentLink alloc] init];
            link.caption = linkName;
            link.originalUrl = linkURL;
            link.url = [NSString ab_fixImgurLink:linkURL];
            link.linkType = [CommentLink linkTypeFromLegacyType:[NSString ab_getLinkType:linkURL]];

			// some links have a description that is the same as the URL
			// technically these are not described.
            link.isDescribed = ![linkName isEqualToString:linkURL];
			
            SET_IF_EMPTY(link.caption, @"");
            SET_IF_EMPTY(link.originalUrl, @"");
            SET_IF_EMPTY(link.url, @"");

			if (linkName && [linkName length] > 0 && ![link.url contains:@"/b "] && ![link.url contains:@"/s "] && ![link.url contains:@"/g "])
			{
				[links addObject:link];
			}
			pos = rrb;
		}
		else
			linksAvailable = false;
	}
	return links;
}


@end
