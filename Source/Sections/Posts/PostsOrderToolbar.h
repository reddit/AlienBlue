#import <UIKit/UIKit.h>

#define kPostsOrderToolbarTrainingHasTappedModButtonPrefKey @"kPostsOrderToolbarTrainingHasTappedModButtonPrefKeyB"

@class PostsOrderToolbar;

@protocol PostsOrderToolbarDelegate <NSObject>
- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar willChangeSearchActive:(BOOL)searchActive animated:(BOOL)animated;
- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar didChangeSearchActive:(BOOL)searchActive animated:(BOOL)animated;
- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar didTapOrderButtonWithSearchActive:(BOOL)searchActive;
- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar didEnterSearchQuery:(NSString *)searchQuery;
- (void)postsOrderToolbarDidTapModerationButton:(PostsOrderToolbar *)postsOrderToolbar;
- (BOOL)postsOrderToolbarShouldShowScopeIcon:(PostsOrderToolbar *)postsOrderToolbar;
- (BOOL)postsOrderToolbarShouldShowModerationIcon:(PostsOrderToolbar *)postsOrderToolbar;
- (void)postsOrderToolbar:(PostsOrderToolbar *)postsOrderToolbar didChangeScopeRestriction:(BOOL)restrictScope;
@end

@interface PostsOrderToolbar : UIView

- (id)initWithFrame:(CGRect)frame delegate:(id<PostsOrderToolbarDelegate>)delegate;
- (void)setButtonTitle:(NSString *)title animated:(BOOL)animated;

- (void)cancelActiveSearch;
- (void)focusOnSearchField;

- (void)respondToStyleChangeNotification;
@end
