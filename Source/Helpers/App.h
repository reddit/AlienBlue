#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface App : NSObject

extern void DO_WHILE_TRAINING(NSString *prefKey, NSUInteger trainUpToNumber, dispatch_block_t block);
extern void DONT_DO_WHILE_TRAINING(NSString *prefKey, NSUInteger trainUpToNumber, dispatch_block_t block);

@end
