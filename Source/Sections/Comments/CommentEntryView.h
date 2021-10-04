#import <UIKit/UIKit.h>
#import "JMTabView.h"
#import "CommentEntryTextView.h"
#import "CommentAssetSelectorView.h"

@protocol CommentEntryViewDelegate <NSObject>
- (NSString *)assetFolder;
- (id)commentCoordinator;
- (BOOL)isSmallWindow;
@end

@interface CommentEntryView : UIView <JMTabViewDelegate>
{
}

@property (assign) BOOL forceReposition;

@property (nonatomic,strong) JMTabView * switchTabView;
@property (nonatomic,strong) JMTabView * toolbar;
@property (nonatomic,strong) UIScrollView * commentContainer;
@property (nonatomic,strong) CommentAssetSelectorView * assetSelectorView;
@property (nonatomic,ab_weak) id<CommentEntryViewDelegate> delegate;
@property (nonatomic,strong) CommentEntryTextView * commentTextView;
@property (nonatomic,strong) CommentEntryTextView * parentTextView;

-(void)didSelectTagFromCarousel:(NSString *)tagName;
- (id)initWithFrame:(CGRect)frame delegate:(id<CommentEntryViewDelegate>)delegate;
- (void)externalSwitchToMyComment;

- (void)switchToParentComment;
- (void)switchToMyComment;
- (void)didSelectTagFromCarousel:(NSString *)tagName;
- (void)didSelectLOD;

@end
