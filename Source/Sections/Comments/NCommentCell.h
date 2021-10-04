//
//  NCommentCell.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMOutlineCell.h"
#import "NBaseStyledTextCell.h"
#import "Comment.h"
#import "ThreadLinesOverlay.h"
#import "CommentSeparatorBar.h"
#import "CommentHeaderBarOverlay.h"
#import "VoteOverlay.h"

@interface NCommentCell : NBaseStyledTextCell
@property (readonly, strong) CommentHeaderBarOverlay *headerBar;
@property (readonly, strong) ThreadLinesOverlay *threadLinesOverlay;
@property (readonly, strong) CommentSeparatorBar *separatorBar;
@property (readonly, strong) JMViewOverlay *dottedLineSeparatorOverlay;
@property (readonly, strong) VoteOverlay *voteOverlay;
@property (readonly) Comment *comment;

@end
