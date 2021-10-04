#import "ABOutlineViewController.h"
#import "TemplatePrefs.h"
#import "TemplateCell.h"

@interface TemplatesViewController : ABOutlineViewController

@property (readonly, strong) TemplatePrefs *tPrefs;
@property (readonly, strong) TemplateGroup *group;
@property (copy) ABAction onDismiss;

- (id)initWithDefaultGroupIdent:(NSString *)groupIdent;

// points for customisation
- (void)enableEditMode;
- (void)disableEditMode;
- (TemplateNode *)generateTemplateNodeForTemplate:(Template *)tPlate;
- (NSArray *)tokensWhenEditing;
- (void)reloadTemplatePreferences;

@property (readonly) NSString *tokenReplacerPosterUsername;
@property (readonly) NSString *tokenReplacerLinkToPost;
@property (readonly) NSString *tokenReplacerLinkToSubreddit;
@property (readonly) NSString *tokenReplacerLinkToSidebar;
@property (readonly) NSString *tokenReplacerLinkToWiki;
@property (readonly) NSString *tokenReplacerModeratorUsername;

@end
