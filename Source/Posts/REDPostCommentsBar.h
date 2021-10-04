//  REDPostCommentsBar.h
//  RedditApp

#import <UIKit/UIKit.h>

#import "JMOutlineView/JMOutlineCell.h"
#import "JMOutlineView/JMOutlineNode.h"

@class Post;

@interface REDPostCommentsBar : UIView

+ (CGFloat)height;

- (instancetype)initWithPost:(Post *)post NS_DESIGNATED_INITIALIZER;

@end
