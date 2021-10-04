//  REDNavigationBar.h
//  RedditApp

#import <UIKit/UIKit.h>

#import "iPhone/ABCustomOutlineNavigationBar.h"

@interface REDNavigationBar : ABCustomOutlineNavigationBar

@property(nonatomic, strong) UIView *titleView;

- (void)addLeftButton:(UIButton *)button;
- (void)addRightButton:(UIButton *)button;

@end
