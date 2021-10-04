//
//  CommentNode.m
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "CommentNode.h"
#import "Comment+Style.h"
#import "ThumbManager.h"
#import "Resources.h"

@implementation CommentNode

- (id)initWithComment:(Comment *)comment level:(NSUInteger)level;
{
  JM_SUPER_INIT(init);
  self.comment = comment;
  self.level = level;
  return self;
}

+ (CommentNode *)nodeForComment:(Comment *)comment level:(NSUInteger)level;
{
  return [[CommentNode alloc] initWithComment:comment level:level];
}

+ (Class)cellClass;
{
    return [Resources isIPAD] ? NSClassFromString(@"NCommentCell_iPad") : NSClassFromString(@"NCommentCell");
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

- (void)prefetchThumbnails
{
    if (![self containsNSFWContent])
    {
        [[self thumbLinks] each:^(CommentLink *commentLink) {
            [[ThumbManager manager] thumbnailForUrl:commentLink.url fallbackUrl:nil useFaviconWhenAvailable:YES onComplete:^(UIImage *image) {}];
        }];
//            [blockSelf setNeedsDisplay];
//        }];
    }
}



@end
