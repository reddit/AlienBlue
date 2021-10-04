//
//  CommentsViewController+State.m
//  AlienBlue
//
//  Created by J M on 7/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "CommentsViewController+State.h"
#import "CommentNode.h"

@interface CommentsViewController (State_)
@property (strong) NSString *autoscrollToCommentName;
@end

@implementation CommentsViewController (State)

SYNTHESIZE_ASSOCIATED_STRONG(NSString, autoscrollToCommentName,AutoscrollToCommentName);

- (id)initWithState:(NSDictionary *)state;
{
    NSDictionary *legacyPostDictionary = [state objectForKey:@"legacyPostDictionary"];
    Post *post = [Post postFromDictionary:legacyPostDictionary];
    self = [self initWithPost:post];
    self.autoscrollToCommentName = [state objectForKey:@"autoscrollToCommentName"];
    return self;
}

- (NSDictionary *)state;
{
    NSMutableDictionary *state = [NSMutableDictionary dictionary];

    [state setObject:self.post.legacyDictionary forKey:@"legacyPostDictionary"];
    
    // find the top visible comment
    CGPoint cellPoint = CGPointMake(0., self.tableView.contentOffset.y + 20.);
    NSIndexPath *topIndex = [self.tableView indexPathForRowAtPoint:cellPoint];
    BSELF(CommentsViewController);
    if (topIndex)
    {
        JMOutlineNode *node = [blockSelf nodeForRow:topIndex.row];
        if ([node isKindOfClass:[CommentNode class]])
        {
            CommentNode *commentNode = (CommentNode *)node;
            [state setObject:commentNode.comment.name forKey:@"autoscrollToCommentName"];
        }
    }
    
    return state;
}

- (void)handleRestoringStateAutoscroll;
{
    if (!self.autoscrollToCommentName)
        return;
    
    BSELF(CommentsViewController);
    
    CommentNode *matchingNode = [self.nodes first:^BOOL(JMOutlineNode *node) {
        if (![node isKindOfClass:[CommentNode class]])
            return NO;
        
        CommentNode *commentNode = (CommentNode *)node;
        return [commentNode.comment.name equalsString:blockSelf.autoscrollToCommentName];
    }];
    
    self.autoscrollToCommentName = nil;
    
    if (matchingNode)
    {
        [self scrollToNode:matchingNode];
    }
}

@end


