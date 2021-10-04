#import <UIKit/UIKit.h>
#import "Template.h"
#import "ABButton.h"
#import "TemplateSendModeSwitchView.h"


@interface TemplateEditToolsView : UIView

@property (readonly, strong) ABButton *tokenButton;
@property (readonly, strong) TemplateSendModeSwitchView *switchView;

@end
