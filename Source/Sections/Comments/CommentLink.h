//
//  CommentLink.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LinkTypeArticle = 0,
    LinkTypePhoto,
    LinkTypeVideo,
    LinkTypeSelf
} LinkType;

@interface CommentLink : NSObject
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *originalUrl;
@property (nonatomic,strong) NSString *caption;
@property (nonatomic) LinkType linkType;
@property (nonatomic) BOOL isDescribed;

+ (LinkType)linkTypeFromLegacyType:(NSString *)legacyType;
+ (LinkType)linkTypeFromUrl:(NSString *)url;
+ (NSString *)friendlyNameFromLinkType:(LinkType)linkType;

@end
