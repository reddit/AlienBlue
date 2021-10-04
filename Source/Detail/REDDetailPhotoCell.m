//  REDDetailPhotoCell.m
//  RedditApp

#import "RedditApp/Detail/REDDetailPhotoCell.h"

#import "JMUICore/Extensions/UIKit/UIImageView+JMRemote.h"
#import "RedditApp/REDPopoutImageView.h"

static const CGFloat SelfTextPhotoMaxHeight = 200.0;

@interface REDDetailPhotoCell ()

// A weak reference, downcasted from self.node, is kept for convenience.
@property(nonatomic, weak) REDDetailPhotoNode *detailPhotoNode;
@property(nonatomic, strong) REDPopoutImageView *popoutImageView;

@end

@implementation REDDetailPhotoCell

- (void)updateWithNode:(JMOutlineNode *)node {
  NSAssert([node isKindOfClass:[REDDetailPhotoNode class]], @"Wrong node type.");
  self.detailPhotoNode = (REDDetailPhotoNode *)node;

  if (!self.popoutImageView) {
    self.popoutImageView = [[REDPopoutImageView alloc] init];
    self.popoutImageView.viewController = self.detailPhotoNode.viewController;
    self.popoutImageView.backgroundColor = [UIColor blackColor];
    self.popoutImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.popoutImageView];
  }

  if (self.detailPhotoNode.fromSelfText) {
    self.popoutImageView.contentMode = UIViewContentModeScaleAspectFill;
  } else {
    self.popoutImageView.contentMode = UIViewContentModeScaleAspectFit;
  }

  [self.popoutImageView jm_setRemoteImageWithURL:self.detailPhotoNode.mediaURL
                                     placeholder:nil
                                       decorator:nil
                                      onProgress:nil
                                      onComplete:nil
                                       onFailure:nil];

  [super updateWithNode:node];
}

#pragma mark - sizing and layout

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView {
  NSAssert([node isKindOfClass:[REDDetailPhotoNode class]], @"Wrong node type.");
  REDDetailPhotoNode *detailPhotoNode = (REDDetailPhotoNode *)node;

  CGFloat ratio = (float)detailPhotoNode.mediaHeight / (float)detailPhotoNode.mediaWidth;
  CGFloat height = tableView.frame.size.height;
  CGFloat width = tableView.frame.size.width;
  if (detailPhotoNode.fromSelfText) {
    height = SelfTextPhotoMaxHeight;
  } else {
    height = ratio * width;
  }

  return height;
}

- (void)layoutCellOverlays {
  if (self.detailPhotoNode.fromSelfText) {
    // TODO(sharkey): Crop photos correctly.
    //    CGFloat heightPercentage = SelfTextPhotoMaxHeight / self.viewModel.mediaHeight;
    //    self.imageNode.cropRect = CGRectMake(0, 0.5, 0, heightPercentage);
  }
  self.popoutImageView.frame = (CGRect){CGPointZero, self.frame.size};
}

@end

#pragma mark - REDDetailPhotoNode

@implementation REDDetailPhotoNode

- (instancetype)initWithMediaURL:(NSURL *)mediaURL
                          height:(NSInteger)height
                           width:(NSInteger)width
                    fromSelfText:(BOOL)fromSelfText
                  viewController:(UIViewController *)viewController {
  if (self = [super init]) {
    _mediaURL = [mediaURL copy];
    _mediaHeight = height;
    _mediaWidth = width;
    _fromSelfText = fromSelfText;
    _viewController = viewController;
  }
  return self;
}

+ (Class)cellClass {
  return [REDDetailPhotoCell class];
}

@end