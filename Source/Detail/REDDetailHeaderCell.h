//  REDDetailHeaderCell.h
//  RedditApp

#import <UIKit/UIKit.h>

#import "JMOutlineView/JMOutlineCell.h"
#import "JMOutlineView/JMOutlineNode.h"

@class Post;
@class REDDetailViewController;

@interface REDDetailHeaderCell : JMOutlineCell

@end

#pragma mark - view model

@interface REDDetailHeaderNode : JMOutlineNode

@property(nonatomic, strong) Post *post;
@property(nonatomic, weak) REDDetailViewController *viewController;

- (instancetype)initWithPost:(Post *)post
              viewController:(__weak REDDetailViewController *)viewController;

@end
