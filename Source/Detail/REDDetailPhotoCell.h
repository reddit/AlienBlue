//  REDDetailPhotoCell.h
//  RedditApp

#import "JMOutlineView/JMOutlineCell.h"
#import "JMOutlineView/JMOutlineNode.h"

@interface REDDetailPhotoCell : JMOutlineCell

@end

#pragma mark - view model

@interface REDDetailPhotoNode : JMOutlineNode

@property(nonatomic, copy) NSURL *mediaURL;
@property(nonatomic, assign) NSInteger mediaHeight;
@property(nonatomic, assign) NSInteger mediaWidth;
@property(nonatomic, assign) BOOL fromSelfText;
@property(nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithMediaURL:(NSURL *)mediaURL
                          height:(NSInteger)height
                           width:(NSInteger)width
                    fromSelfText:(BOOL)fromSelfText
                  viewController:(__weak UIViewController *)viewController;

@end
