//
//  NCommentCell_iPad.m
//  AlienBlue
//
//  Created by J M on 20/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "NCommentCell_iPad.h"
#import "ThumbManager.h"

@implementation NCommentCell_iPad

- (void)createSubviews;
{
    [super createSubviews];
    self.headerBar.horizontalPadding = 16.;
}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];
    self.threadLinesOverlay.left = 14.;
}

- (void)updateWithNode:(JMOutlineNode *)node;
{
    [super updateWithNode:node];
    self.separatorBar.hidden = YES;
}

//+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
//{
//    CGFloat height = [NCommentCell heightForNode:node tableView:tableView];
//    CommentNode *commentNode = (CommentNode *)node;
//    return height;
//}

+ (CGSize)commentTextPadding;
{
    return CGSizeMake(23. ,  10.);
}

- (void)applyGestureRecognizers;
{
    [super applyGestureRecognizers];
    BSELF(NCommentCell_iPad);  
    
    UILongPressGestureRecognizer *doubleLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithActionBlock:^(UILongPressGestureRecognizer *gesture) {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            [[(CommentNode *)blockSelf.node thumbLinks] each:^(CommentLink *commentLink){
                [[ThumbManager manager] forceCreateResizeServerThumbnailForUrl:commentLink.url onComplete:^(UIImage *image) {
                    [blockSelf.containerView setNeedsDisplay];
                }];
            }];
        }
    }];
    doubleLongPressGesture.numberOfTouchesRequired = 2;
    doubleLongPressGesture.minimumPressDuration = 1.5;
    doubleLongPressGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:doubleLongPressGesture];

    
//    UISwipeGestureRecognizer *twoFingerLeftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:^(UISwipeGestureRecognizer *gesture) {
//        [blockSelf.node.delegate performSelector:@selector(collapseToRootCommentNode:) withObject:blockSelf.node];
//
//    }];
//    twoFingerLeftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//    twoFingerLeftSwipeGesture.numberOfTouchesRequired = 2;
//    twoFingerLeftSwipeGesture.delegate = self.containerView;
//    twoFingerLeftSwipeGesture.delaysTouchesBegan = YES;
//    twoFingerLeftSwipeGesture.cancelsTouchesInView = YES;
//    [self.containerView addGestureRecognizer:twoFingerLeftSwipeGesture];
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
//{
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
//        return NO;
//    
//    return [super gestureRecognizerShouldBegin:gestureRecognizer];
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
//{
//    DLog(@"%@ with %@", gestureRecognizer, otherGestureRecognizer);
//    return YES;
//}
//
@end
