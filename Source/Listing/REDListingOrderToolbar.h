//  REDListingOrderToolbar.h
//  RedditApp

#import <UIKit/UIKit.h>

#define kREDListingOrderToolbarTrainingHasTappedModButtonPrefKey \
  @"kREDListingOrderToolbarTrainingHasTappedModButtonPrefKeyB"

@class REDListingOrderToolbar;

@protocol REDListingOrderToolbarDelegate<NSObject>
- (void)listingOrderToolbar:(REDListingOrderToolbar *)listingOrderToolbar
    didTapOrderButtonWithSearchActive:(BOOL)searchActive;
- (void)listingOrderToolbarDidTapModerationButton:(REDListingOrderToolbar *)listingOrderToolbar;
- (BOOL)listingOrderToolbarShouldShowModerationIcon:(REDListingOrderToolbar *)listingOrderToolbar;
@end

@interface REDListingOrderToolbar : UIView

- (id)initWithFrame:(CGRect)frame delegate:(id<REDListingOrderToolbarDelegate>)delegate;
- (void)setButtonTitle:(NSString *)title animated:(BOOL)animated;

- (void)respondToStyleChangeNotification;
@end
