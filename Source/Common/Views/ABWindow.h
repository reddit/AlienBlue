#import <UIKit/UIKit.h>

@interface ABWindow : UIWindow

@property (copy) BOOL(^customEventHandlerAction)(UIEvent *event);

+ (void)dimToAlpha:(CGFloat)alpha;
+ (void)removeDim;
+ (void)bringDimmingOverlayToFrontIfNecessary;
@end
