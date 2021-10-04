//
//  LinkThumbsLayouts.h
//  AlienBlue
//
//  Created by J M on 21/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseStyledTextNode.h"
#import "CommentLink.h"
#import "LinkThumbsOverlay.h"

typedef CGFloat (^TileDrawerHeightCalculator)(BaseStyledTextNode *commentNode, CGFloat boundWidth, CGFloat textWidth);
typedef CGRect (^TileRectForCommentLink)(CommentLink *commentLink, BaseStyledTextNode *commentNode, CGRect paneBounds);
typedef void (^TileDrawForCommentLink)(CommentLink *commentLink, LinkThumbsOverlay *thumbsOverlay, BaseStyledTextNode *commentNode, CGRect tileRect);
typedef void (^HandleTouchForCommentLink)(CommentLink *commentLink, LinkThumbsOverlay *thumbsOverlay, BaseStyledTextNode *commentNode, CGPoint touchPoint);

extern TileDrawerHeightCalculator Grid_tileDrawerHeight;
extern TileRectForCommentLink Grid_tileRectForCommentLink;
extern TileDrawForCommentLink Grid_tileDrawForCommentLink;
extern CGSize tileSize();

@interface LinkThumbsLayouts : NSObject
+ (CGFloat)heightForTileDrawer:(BaseStyledTextNode *)commentNode constrainedToWidth:(CGFloat)width textWidth:(CGFloat)textWidth;
+ (CGRect)rectForTileCommentLink:(CommentLink *)commentLink commentNode:(BaseStyledTextNode *)commentNode paneBounds:(CGRect)paneBounds;
+ (void)drawTileForCommentLink:(CommentLink *)commentLink thumbsOverlay:(LinkThumbsOverlay *)thumbsOverlay commentNode:(BaseStyledTextNode *)commentNode tileRect:(CGRect)tileRect;
+ (void)handleTouchForCommentLink:(CommentLink *)commentLink thumbsOverlay:(LinkThumbsOverlay *)thumbsOverlay commentNode:(BaseStyledTextNode *)commentNode touchPoint:(CGPoint)touchPoint;
@end
