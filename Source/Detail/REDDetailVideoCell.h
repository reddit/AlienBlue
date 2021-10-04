//  REDDetailVideoCell.h
//  RedditApp

#import "JMOutlineView/JMOutlineCell.h"
#import "JMOutlineView/JMOutlineNode.h"

@interface REDDetailVideoCell : JMOutlineCell

@end

#pragma mark - view model

@interface REDDetailVideoNode : JMOutlineNode

@property(nonatomic, copy) NSString *URL;
@property(nonatomic, strong) NSURL *thumbnailUrl;
@property(nonatomic, assign) CGSize thumbnailSize;
@property(nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithURL:(NSString *)URL
               thumbnailUrl:(NSURL *)thumbnailUrl
              thumbnailSize:(CGSize)thumbnailSize
             viewController:(__weak UIViewController *)viewController;

@end
