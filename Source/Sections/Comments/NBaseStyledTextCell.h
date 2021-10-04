//
//  NBaseStyledTextCell.h
//  AlienBlue
//
//  Created by J M on 19/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMOutlineCell.h"

#import "StyledTextOverlay.h"
#import "LinkThumbsOverlay.h"
#import "ThreadLinesOverlay.h"
#import "BaseStyledTextNode.h"
#import "CommentOptionsDrawerView.h"

@interface NBaseStyledTextCell : JMOutlineCell
@property (strong) StyledTextOverlay *bodyOverlay;
@property (strong) LinkThumbsOverlay *linkThumbsOverlay;
@property (strong) ABTableCellDrawerView *drawerView;

- (void)applyGestureRecognizers;

+ (CGSize)commentTextPadding;
+ (CGRect)rectForCommentBodyInNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
+ (CGFloat)minimumHeightForCellTextForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
+ (CGFloat)heightForCellHeaderForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
+ (CGFloat)heightForCellFooterForNode:(BaseStyledTextNode *)node bounds:(CGRect)bounds;
+ (CGFloat)heightForCellBody:(JMOutlineNode *)node tableView:(UITableView *)tableView;
+ (BOOL)shouldExpandTextToFullWidthWhenSelected;
@end
