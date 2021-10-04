//
//  CommentLink.m
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentLink.h"
#import "RedditAPI.h"
#import "NSString+ABLegacyLinkTypes.h"

@implementation CommentLink

+ (LinkType)linkTypeFromLegacyType:(NSString *)legacyType;
{
    if ([legacyType equalsString:@"image"])
        return LinkTypePhoto;
    else if ([legacyType equalsString:@"video"])
        return LinkTypeVideo;
    else if ([legacyType equalsString:@"self"])
        return LinkTypeSelf;
    else
        return LinkTypeArticle;
}

+ (LinkType)linkTypeFromUrl:(NSString *)url;
{    
    return [CommentLink linkTypeFromLegacyType:[NSString ab_getLinkType:url]];
}

+ (NSString *)friendlyNameFromLinkType:(LinkType)linkType;
{
    NSString *friendlyName = nil;
    if (linkType == LinkTypePhoto)
        friendlyName = @"Photo";
    else if (linkType == LinkTypeVideo)
        friendlyName = @"Video";
    else if (linkType == LinkTypeSelf)
        friendlyName = @"Self";
    else if (linkType == LinkTypeArticle)
        friendlyName = @"Article";
    return friendlyName;    
}

@end
