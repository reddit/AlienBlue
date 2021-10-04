//  REDDetailWebsiteCell.h
//  RedditApp

#import "JMOutlineView/JMOutlineCell.h"
#import "JMOutlineView/JMOutlineNode.h"

@class REDDetailViewController;

@interface REDDetailWebsiteCell : JMOutlineCell

@end

#pragma mark - view model

@interface REDDetailWebsiteNode : JMOutlineNode

@property(nonatomic, strong) NSURL *URL;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *webDomain;
@property(nonatomic, strong) NSURL *thumbnailUrl;
@property(nonatomic, assign) CGSize thumbnailSize;
@property(nonatomic, weak) REDDetailViewController *viewController;

- (instancetype)initWithURL:(NSURL *)URL
                      title:(NSString *)title
                  webDomain:(NSString *)webDomain
               thumbnailUrl:(NSURL *)thumbnailUrl
              thumbnailSize:(CGSize)thumbnailSize
             viewController:(__weak REDDetailViewController *)viewController;

@end
