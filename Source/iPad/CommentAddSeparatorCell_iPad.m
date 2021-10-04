//
//  CommentAddSeparatorCell_iPad.m
//  AlienBlue
//
//  Created by J M on 23/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "CommentAddSeparatorCell_iPad.h"

@implementation CommentAddSeparatorNode

+ (Class)cellClass;
{
    return NSClassFromString(@"CommentAddSeparatorCell_iPad");
}

@end

@interface CommentAddSeparatorCell_iPad()
@property (strong) JMViewOverlay *addCommentButton;
@property (strong) JMViewOverlay *commentsTitle;
@end

@implementation CommentAddSeparatorCell_iPad

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    if (node.hidden) return 0.;
    return 56.;
}

- (void)createSubviews;
{
    [super createSubviews];
    self.cellBackgroundColor = [UIColor colorForBackground];
  
    self.commentsTitle = [JMViewOverlay overlayWithFrame:CGRectMake(24., 19., 200., 20.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [[UIColor colorForText] set];
        [UIView startEtchedDraw];
        [@"Comments" drawAtPoint:CGPointZero withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.]];
        [UIView endEtchedDraw];
    }];
    [self.containerView addOverlay:self.commentsTitle];
    
    BSELF(CommentAddSeparatorCell_iPad);
    self.addCommentButton = [JMViewOverlay overlayWithFrame:CGRectMake(0., 12., 110., 35.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        CGRect buttonFrame = CGRectInset(bounds, 3., 3.);
        UIColor *buttonColor = highlighted ? [UIColor colorWithHex:0x555555] : [UIColor colorWithHex:0x757575];
        [buttonColor set];

        [UIView startShadowedDraw];
        [[UIBezierPath bezierPathWithRoundedRect:buttonFrame cornerRadius:3.] fill];
        [UIView endShadowedDraw];
        
        [[UIColor whiteColor] set];
        [@"Add Comment" drawAtPoint:CGPointMake(16., 10.) withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.]];
    } onTap:^(CGPoint touchPoint) {
        [blockSelf.node.delegate performSelector:@selector(addNewComment) withObject:nil];
    }];
    self.addCommentButton.right = self.width - 15.;
    self.addCommentButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.containerView addOverlay:self.addCommentButton];
}

- (void)decorateCellBackground;
{
    [[UIColor colorForBackground] set];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    
    [[UIColor colorForSoftDivider] set];
    [[UIBezierPath bezierPathWithRect:CGRectMake(20., 4., self.width - 40., 1.)] fill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(20., self.height - 1., self.width - 40., 1.)] fill];
}

@end
