#import "JMTextViewController.h"
#import "Template.h"

typedef enum TemplateDetailMode {
  TemplateDetailModeTemplateEdit,
  TemplateDetailModeExpanded,
} TemplateDetailMode;

@interface TemplateDetailViewController : JMTextViewController

@property (copy) void(^onTemplateEditComplete)(NSString *templateTitle, NSString *body, TemplateSendPreference sendPreference);
@property BOOL useSendAsDoneButtonTitle;
@property BOOL hidesNavbarTextField;
@property (strong) NSString *defaultTemplateTitle;

- (id)initWithTemplate:(Template *)tPlate mode:(TemplateDetailMode)mode tokens:(NSArray *)tokens;

@end
