#import <UIKit/UIKit.h>
#import "Template.h"

@interface TemplateSendModeSwitchView : UIControl

@property (readonly, strong) UIImageView *trackView;
@property (readonly, strong) UIImageView *leftIconView;
@property (readonly, strong) UIImageView *rightIconView;

@property (copy) void(^onSendSwitchChange)(TemplateSendPreference sendPref);
- (void)setDefaultSendSwitchPreference:(TemplateSendPreference)sendPref;

@end
