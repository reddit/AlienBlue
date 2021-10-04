#import <Foundation/Foundation.h>

@interface ReachabilityCoordinator : NSObject
@property (readonly) BOOL isReachable;
@property (readonly) NSString *statusSummary;
- (void)startMonitoringReachability;
- (void)handleApplicationBecomingActiveDoWhenReachable:(JMAction)onReachableAction;
- (void)handleApplicationBecomingInactive;
+ (ReachabilityCoordinator *)shared;
@end
