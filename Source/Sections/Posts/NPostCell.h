#import "JMOutlineCell.h"
#import "Post.h"

#import "ThumbOverlay.h"
#import "VoteOverlay.h"
#import "ModButtonOverlay.h"

@class PostOptionsDrawerView;

@interface PostNode : JMOutlineNode
@property (strong) Post *post;
+ (PostNode *)nodeForPost:(Post *)post;
- (void)prefetchThumbnailToCache;
@end

@interface NPostCell : JMOutlineCell
@property (readonly) Post *post;
@property (strong) PostOptionsDrawerView *drawerView;
@property (strong) JMViewOverlay *commentButtonOverlay;
@property (strong) JMViewOverlay *linkFlairOverlay;
@property (strong) ThumbOverlay *thumbOverlay;
@property (strong) VoteOverlay *voteOverlay;
@property (strong) JMViewOverlay *titleOverlay;
@property (strong) JMViewOverlay *subdetailsOverlay;
@property (strong) ModButtonOverlay *modButtonOverlay;
@property (strong) JMViewOverlay *sectionDivider;
- (void)applyGestureRecognizers;
- (CGRect)rectForTitle;
+ (CGFloat)titleMarginForPost:(Post *)post;
+ (CGFloat)footerPadding;

- (void)didTapOnThumbOverlay;
- (void)didPressDownOnThumbOverlay;

@end
