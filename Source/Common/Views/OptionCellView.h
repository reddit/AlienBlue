#import <UIKit/UIKit.h>

#define kOptionCellKeyBold @"kOptionCellKeyBold"
#define kOptionCellKeyShowNextPageIndicator @"kOptionCellKeyShowNextPageIndicator"
#define kOptionCellKeyShowProFeatureLabel @"kOptionCellKeyShowProFeatureLabel"
#define kOptionCellKeyHasSecondaryOption @"kOptionCellKeyHasSecondaryOption"
#define kOptionCellKeyShowStarFilled @"kOptionCellKeyShowStarFilled"
#define kOptionCellKeyShowStarEmpty @"kOptionCellKeyShowStarEmpty"
#define kOptionCellKeyShowTick @"kOptionCellKeyShowTick"
#define kOptionCellKeyDisabled @"kOptionCellKeyDisabled"
#define kOptionCellKeyShowThemePalette @"kOptionCellKeyShowThemePalette"
#define kOptionCellKeyOptionValue @"kOptionCellKeyOptionValue"
#define kOptionCellKeyHighlight @"kOptionCellKeyHighlight"
#define kOptionCellKeyShowHelpIcon @"kOptionCellKeyShowHelpIcon"
#define kOptionCellKeyTitle @"kOptionCellKeyTitle"
#define kOptionCellKeyIcon @"kOptionCellKeyIcon"
#define kOptionCellKeyLabel @"kOptionCellKeyLabel"
#define kOptionCellKeyParentController @"kOptionCellKeyParentController"
#define kOptionCellKeyIndexPath @"kOptionCellKeyIndexPath"

@interface OptionCellView : UIView {
	NSMutableDictionary * option_;
}
@property (readonly, strong) NSMutableDictionary *option;
- (void)setNewOption:(NSMutableDictionary *)newOption;

@end
