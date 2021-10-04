#import <Foundation/Foundation.h>

@interface TiltManager : NSObject

- (void)activateTiltCalibrationMode;
- (void)startMonitoringAccelerometer;

+ (TiltManager *)shared;

@end
