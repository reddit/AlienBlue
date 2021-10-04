@interface PromptManager : NSObject

+ (void)addPrompt:(NSString *)prompt;
+ (void)showConnectionErrorHud;
+ (void)showMomentaryHudWithMessage:(NSString *)message;
+ (void)showMomentaryHudWithMessage:(NSString *)message minShowTime:(CGFloat)minShowTime;
+ (void)showHudWithMessage:(NSString *)message;
+ (void)hideHud;

@end
