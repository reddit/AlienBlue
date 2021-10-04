#import <UIKit/UIKit.h>


@class PhoneCommentEntryDrawer;

@protocol PhoneCommentEntryDrawerDelegate
- (void)drawerWillExpand:(PhoneCommentEntryDrawer *)drawer;
- (void)drawerWillCollapse:(PhoneCommentEntryDrawer *)drawer;
@end

@interface PhoneCommentEntryDrawer : UIView <UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (ab_weak) NSObject<PhoneCommentEntryDrawerDelegate> * delegate;
- (void)setCenterView:(UIView *)view;
- (void)setLeftView:(UIView *)view;
- (void)setRightView:(UIView *)view;
- (void)toggleDrawerAnimated:(BOOL)animated;

- (void)fadeGripsIn;
- (void)fadeGripsOut;

@end


