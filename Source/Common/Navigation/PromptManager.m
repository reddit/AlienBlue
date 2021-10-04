#import "PromptManager.h"
#import "NavigationManager.h"
#import "Resources.h"
#import "MBProgressHUD.h"

@interface NavigationManager()
- (void)handleShowPromptNotification:(NSString *)prompt;
- (void)handleHidePromptNotification;
@end

@interface PromptManager()
@property (strong) NSMutableArray *promptQueue;
@property (strong) NSTimer *promptQueueTimer;
@end

@implementation PromptManager

+ (PromptManager *)shared
{
  JM_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

- (id)init;
{
  JM_SUPER_INIT(init);
  self.promptQueue = [NSMutableArray new];
  self.promptQueueTimer = [NSTimer scheduledTimerWithTimeInterval:1.3 target:self selector:@selector(processPromptQueue:) userInfo:nil repeats:YES];
  return self;
}

- (void)processPromptQueue:(NSTimer *)theTimer
{
  if (self.promptQueue.count == 0)
  {
    [[NavigationManager shared] handleHidePromptNotification];
    return;
  }
  
  NSString *promptString = [self.promptQueue objectAtIndex:0];
  [[NavigationManager shared] handleShowPromptNotification:promptString];
  [self.promptQueue removeObjectAtIndex:0];
}

- (void)i_addPrompt:(NSString *)prompt
{
  [self.promptQueue addObject:prompt];
}

+ (void)addPrompt:(NSString *)prompt;
{
  [[PromptManager shared] i_addPrompt:prompt];
}

#pragma Mark - 
#pragma Mark - HUD Support

+ (void)showConnectionErrorHud;
{
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[NavigationManager mainView] animated:NO];
  [hud setMinShowTime:2.];
  [hud hide:NO];
  [hud setUserInteractionEnabled:NO];
  [hud setAnimationType:MBProgressHUDAnimationZoom];
  [hud setPanelBackgroundColor:[UIColor colorWithHex:0x780000]];
  [hud setMode:MBProgressHUDModeDeterminate];
  [hud setLabelText:@"Please check your internet connection."];
  [hud setLabelFont:[UIFont boldSystemFontOfSize:12.]];
  [hud show:YES];
}

+ (void)showMomentaryHudWithMessage:(NSString *)message;
{
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[NavigationManager mainView] animated:NO];
  [hud setMinShowTime:1.3];
  [hud hide:NO];
  [hud setUserInteractionEnabled:NO];
  [hud setAnimationType:MBProgressHUDAnimationZoom];
  [hud setPanelBackgroundColor:[UIColor grayColor]];
  [hud setMode:MBProgressHUDModeIndeterminate];
  [hud setLabelText:message];
  [hud setLabelFont:[UIFont boldSystemFontOfSize:12.]];
  [hud show:YES];
}

+ (void)showMomentaryHudWithMessage:(NSString *)message minShowTime:(CGFloat)minShowTime;
{
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[NavigationManager mainView] animated:NO];
  [hud setMinShowTime:minShowTime];
  [hud hide:NO];
  [hud setUserInteractionEnabled:NO];
  [hud setAnimationType:MBProgressHUDAnimationZoom];
  [hud setPanelBackgroundColor:[UIColor tintColorWithAlpha:0.8]];
  [hud setLabelText:message];
  [hud setLabelFont:[UIFont boldSystemFontOfSize:12.]];
  UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.,0., 1., 1.)];
  customView.backgroundColor = [UIColor clearColor];
  [hud setCustomView:customView];
  [hud setMode:MBProgressHUDModeCustomView];
  [hud show:YES];
}

+ (void)showHudWithMessage:(NSString *)message;
{
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[NavigationManager mainView] animated:NO];
  [hud hide:NO];
  [hud setLabelText:message];
  [hud setUserInteractionEnabled:NO];
  [hud setAnimationType:MBProgressHUDAnimationFade];
  [hud show:YES];
}

+ (void)hideHud;
{
  [MBProgressHUD hideHUDForView:[NavigationManager mainView] animated:YES];
  [MBProgressHUD hideHUDForView:[NavigationManager shared].postsNavigation.view animated:YES];
}

@end
