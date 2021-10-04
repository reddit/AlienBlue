//  REDDetailSelfTextCell.h
//  RedditApp

#import "JMOutlineView/JMOutlineCell.h"
#import "JMOutlineView/JMOutlineNode.h"

@interface REDDetailSelfTextCell : JMOutlineCell

@end

#pragma mark - view model

@interface REDDetailSelfTextNode : JMOutlineNode

@property(nonatomic, strong) NSString *markdown;
@property(nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithMarkdown:(NSString *)markdown
                  viewController:(__weak UIViewController *)viewController;

@end
