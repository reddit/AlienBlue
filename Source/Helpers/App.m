#import "App.h"
#import "NavigationManager.h"

@implementation App

+ (void)initialize
{
  if (self == [App class])
  {
//#ifdef DEBUG
//    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
//    [notifyCenter addObserverForName:nil
//                              object:nil
//                               queue:nil
//                          usingBlock:^(NSNotification* notification){
//                            if ([notification.name hasPrefix:@"AV"])
//                            {
//                              DLog(@"Notification found with:"
//                                    "\r\n     name:     %@"
//                                    "\r\n     object:   %@"
//                                    "\r\n     userInfo: %@",
//                                    [notification name],
//                                    [notification object],
//                                    [notification userInfo]);
//
////                              DLog(@"%@", notification.name);
//                            }
//                          }];
//#endif
  }
}

void DO_WHILE_TRAINING(NSString *prefKey, NSUInteger trainUpToNumber, dispatch_block_t block)
{
  NSUInteger doneTimes = [UDefaults integerForKey:prefKey];
  if (doneTimes < trainUpToNumber)
  {
//    DLog(@"doing while training %d :: %@", doneTimes, prefKey);
    
    doneTimes++;
    [UDefaults setInteger:doneTimes forKey:prefKey];
    
    block();
  }
}

void DONT_DO_WHILE_TRAINING(NSString *prefKey, NSUInteger trainUpToNumber, dispatch_block_t block)
{
  NSUInteger doneTimes = [UDefaults integerForKey:prefKey];
  if (doneTimes < trainUpToNumber)
  {
//    DLog(@"omitting while training %d :: %@", doneTimes, prefKey);
    
    doneTimes++;
    [UDefaults setInteger:doneTimes forKey:prefKey];
  }
  else
  {
    block();
  }
}

@end
