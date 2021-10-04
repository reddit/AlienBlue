//
//  Post.h
//  AlienBlue
//
//  Created by J M on 3/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VotableElement.h"
#import "CommentLink.h"

@interface Post : VotableElement <NSCoding>
@property (nonatomic,strong) NSString *title;

@property (nonatomic,strong) NSString *selftext;
@property (nonatomic,strong) NSString *selftextHtml;
@property (nonatomic,strong) NSString *linkFlairText;

@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *domain;
@property (readonly) NSString *tinyDomain;

@property (nonatomic,strong) NSString *rawThumbnail;
@property (readonly) NSString *thumbnail;
@property (nonatomic,strong) NSDictionary *preview;
@property (nonatomic,strong) NSDictionary *subredditDetail;

@property (readonly) LinkType linkType;
@property (readonly) BOOL needsNSFWWarning;

@property (readonly) NSString *linkTypeIconName;

@property BOOL stickied;
@property BOOL nsfw;
@property BOOL saved;
@property BOOL hidden;
@property BOOL selfPost;
@property (nonatomic) BOOL visited;
@property BOOL reported;
@property BOOL promoted;
@property (readonly) BOOL hasExternalLink;
@property NSUInteger gilded;

@property NSInteger numComments;
@property NSUInteger numberOfImagesInCommentThread;

@property (readonly) NSString *linkFlairTextForPresentation;

@property (nonatomic,strong) NSAttributedString *cachedStyledTitle;

@property (strong) NSString *contextCommentIdent;

+ (Post *)postFromDictionary:(NSDictionary *)dictionary;
+ (Post *)postSkeletonFromRedditUrl:(NSString *)threadUrl;

- (BOOL)isInVisitedList;
- (void)markVisited;
- (void)updateVisitedStatus;

@end
