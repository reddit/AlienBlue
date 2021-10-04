#import "NPostCell_iPhone.h"
#import "Resources.h"
#import "Post+Style_iPhone.h"
#import "ABTableCellDrawerView.h"

@implementation NPostCell_iPhone

- (void)applyGestureRecognizers;
{
  [super applyGestureRecognizers];
  
  BSELF(NPostCell);
  GestureActionBlock selectAction = ^(UIGestureRecognizer *gesture) {
    if (([gesture isKindOfClass:[UISwipeGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateEnded) ||
        ([gesture isKindOfClass:[UILongPressGestureRecognizer class]] && gesture.state == UIGestureRecognizerStateBegan))
      [blockSelf.node.delegate selectNode:blockSelf.node];
  };
  
  UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:selectAction];
  rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
  rightSwipeGesture.delegate = self.containerView;
  [self.containerView addGestureRecognizer:rightSwipeGesture];
  
  UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithActionBlock:selectAction];
  leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
  leftSwipeGesture.delegate = self.containerView;
  [self.containerView addGestureRecognizer:leftSwipeGesture];
}

@end
