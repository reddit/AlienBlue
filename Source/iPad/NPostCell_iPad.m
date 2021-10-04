#import "NPostCell_iPad.h"
#import "PostsViewController_iPad.h"
#import "Post+Style_iPad.h"
#import "ABTableCellDrawerView.h"
#import "ThumbManager.h"
#import "Resources.h"

#define kPostCellMinimumHeightWithThumbnail 84.
#define kPostCellMinimumHeightWithoutThumbnail 54.
#define kPostCellMinimiumHeightWithVoteIcons 70.

@interface NPostCell_iPad()
@property (readonly) BOOL isPaneFocussed;
@end

@implementation NPostCell_iPad

+ (CGFloat)footerPadding;
{
    return 8.;
}

+ (CGFloat)titleMarginForPost:(Post *)post;
{
  CGFloat defaultMargin = [[NPostCell class] titleMarginForPost:post];
  defaultMargin += 10.;
  return defaultMargin;
}

- (CGRect)rectForTitle;
{
    CGRect titleRect = [super rectForTitle];
    CGFloat xOffset = (self.post.thumbnail != nil) ? 10. : 0.;
    titleRect = CGRectOffset(titleRect, xOffset, 4.);
    return titleRect;
}

- (void)layoutCellOverlays;
{
    [super layoutCellOverlays];
  
    self.sectionDivider.right = self.commentButtonOverlay.left - 4.;
    CGRect modOverlayRect = CGRectCenterWithSize(self.sectionDivider.frame, self.modButtonOverlay.size);
    self.modButtonOverlay.top = modOverlayRect.origin.y;
    self.modButtonOverlay.left = modOverlayRect.origin.x;
}

- (BOOL)isPaneFocussed;
{
    return [(PostsViewController_iPad *)self.node.delegate isContentPaneOpenForPost:self.post];
}

- (void)decorateCellBackground;
{
    CGRect bounds = self.bounds;
    if (self.node.selected)
    {
        bounds.size.height -= kABTableCellDrawerHeight;
    }
  
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorForBackground] set];
    CGContextFillRect(context, bounds);

    if (self.isPaneFocussed)
    {
        UIColor *bgColor = [UIColor colorForRowHighlight];
        [bgColor set];
        CGContextFillRect(context, bounds);        
    }
    else if (self.highlighted || self.node.selected)
    {
        UIColor *bgColor = [Resources isNight] ? [UIColor colorWithWhite:0. alpha:0.08] : [UIColor colorWithWhite:0. alpha:0.02];
        [bgColor set];
        CGContextFillRect(context, bounds);
    }

    [[UIColor colorForSoftDivider] set];
    [[UIBezierPath bezierPathWithRect:CGRectMake(15., self.containerView.height - 1., self.containerView.width - 30., 1.)] fill];
}

+ (CGFloat)minimumHeightForPost:(Post *)post;
{
    CGFloat minimumHeight;
    if (post.thumbnail)
        minimumHeight = kPostCellMinimumHeightWithThumbnail;
    else if ([Resources showPostVotingIcons])
        minimumHeight = kPostCellMinimiumHeightWithVoteIcons;
    else
        minimumHeight = kPostCellMinimumHeightWithoutThumbnail;
    
    return minimumHeight;
}

- (void)applyGestureRecognizers;
{
    [super applyGestureRecognizers];
    
    BSELF(NPostCell_iPad);
    GestureActionBlock selectAction = ^(UIGestureRecognizer *gesture) {
        if (([gesture isKindOfClass:[UISwipeGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateEnded) ||
            ([gesture isKindOfClass:[UILongPressGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateBegan))
            [blockSelf.node.delegate selectNode:blockSelf.node];
    };    

    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:selectAction];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeGesture.numberOfTouchesRequired = 2;
    rightSwipeGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:rightSwipeGesture];
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:selectAction];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeGesture.numberOfTouchesRequired = 2;
    leftSwipeGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:leftSwipeGesture];
    
    UILongPressGestureRecognizer *doubleLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithActionBlock:^(UILongPressGestureRecognizer *gesture) {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            [[ThumbManager manager] forceCreateResizeServerThumbnailForUrl:blockSelf.post.url onComplete:^(UIImage *image) {
                [blockSelf.node refresh];
            }];
        }
    }];
    doubleLongPressGesture.numberOfTouchesRequired = 2;
    doubleLongPressGesture.minimumPressDuration = 1.5;
    doubleLongPressGesture.delegate = self.containerView;
    [self.containerView addGestureRecognizer:doubleLongPressGesture];
}

@end
