//
//  CommentPostHeaderNode.m
//  AlienBlue
//
//  Created by J M on 19/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentPostHeaderNode.h"
#import "Comment+Preprocess.h"
#import "Comment+Style.h"
#import "Resources.h"

@implementation CommentPostHeaderNode

+ (CommentPostHeaderNode *)nodeForHeaderPost:(Post *)post;
{
    CommentPostHeaderNode *node = [[CommentPostHeaderNode alloc] init];
    node.post = post;

    // populate the body of the 'comment' aspect of this node with the self text, so that we can
    // benefit from the preprocessing of rich text/links.
    
    NSMutableDictionary *commentDictionary = [NSMutableDictionary dictionaryWithDictionary:[post.legacyDictionary copy]];
    [commentDictionary setObject:post.selftext forKey:@"body"];
    [commentDictionary setObject:post.selftextHtml forKey:@"body_html"];
    Comment *comment = [Comment commentFromDictionary:commentDictionary];
    [comment preprocessLinksAndAttributedStyle];
  
    node.comment = comment;
    
    return node;
}

+ (CommentPostHeaderNode *)placeholderNodeForPost:(Post *)post;
{
    SET_IF_EMPTY(post.title, @"Loading");
    SET_IF_EMPTY(post.subreddit, @"");
    SET_IF_EMPTY(post.timeAgo, @"");
    SET_IF_EMPTY(post.domain, @"reddit.com");
    SET_IF_EMPTY(post.author, @"");
    SET_IF_EMPTY(post.selftext, @"");
    SET_IF_EMPTY(post.selftextHtml, @"");
    SET_IF_EMPTY(post.domain, @"...");
    
    CommentPostHeaderNode *node = [CommentPostHeaderNode nodeForHeaderPost:post];
    node.isPlaceholderPost = YES;
    return node;
}

+ (Class)cellClass;
{
    return [Resources isIPAD] ? NSClassFromString(@"NCommentPostHeaderCell_iPad") : NSClassFromString(@"NCommentPostHeaderCell");
}

// Base Styled Text Node overrides

- (BOOL)containsNSFWContent;
{
    return ([self.comment.body contains:@"nsfw"]  || [self.comment.body contains:@"nsfl"]);
}

- (BOOL)containsRestrictedContent;
{
    return (self.comment.score < 0 || [self containsNSFWContent]);
}

- (NSString *)elementId;
{
    return [self.comment ident];
}

- (NSAttributedString *)styledText;
{
    return [self.comment styledBody];
}

- (CGFloat)heightForBodyConstrainedToWidth:(CGFloat)width;
{
    return [self.comment heightForBodyConstrainedToWidth:width];
}

- (NSArray *)thumbLinks;
{
    if ([self.comment.links count] > 4)
        return [self.comment.links subarrayWithRange:NSMakeRange(0, 4)];
    else
        return [self.comment links];
}

@end
