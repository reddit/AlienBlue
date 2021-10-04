#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//extern static CGRect CGRectCenter(CGRect bounds, CGRect objectRect);
//extern void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);

extern CGSize SkinShadowOffsetSize();

@interface UIView (UIView_Additions)

- (void) drawRectangleWithRect:(CGRect)rect withColor:(UIColor *) color;
- (void) drawNoise;
- (void) drawTapGlowAtPoint:(CGPoint) touchPoint;
- (void) drawInnerShadowInRect:(CGRect)rect fillColor:(UIColor *)fillColor;
- (void) clearSubviews;
- (UIColor *)colorOfPoint:(CGPoint)point;
- (UIView *)findFirstResponder;

+ (void) startShadowedDraw;
+ (void) startShadowedDrawWithShadowColor:(UIColor *)shadowColor;
+ (void) startShadowedDrawWithOpacity:(CGFloat)opacity;
+ (void) endShadowedDraw;

+ (void)startEtchedDraw;
+ (void)endEtchedDraw;


+ (void)startEtchedInnerShadowDraw;
+ (void)startEtchedInnerShadowDrawWithColor:(UIColor *)color;
+ (void)endEtchedInnerShadowDraw;
+ (void)startEtchedDropShadowDraw;
+ (void)endEtchedDropShadowDraw;

+ (void)addRoundedRectToPathForContext:(CGContextRef)context rect:(CGRect)rect ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;

+ (void)drawGradientInRect:(CGRect)rect minHeight:(CGFloat)minHeight startColor:(UIColor *)startColor endColor:(UIColor *)endColor;
+ (void)drawGradientBackgroundInRect:(CGRect)rect;

+ (void)drawVerticalText:(NSString *)value context:(CGContextRef)context point:(CGPoint)point font:(UIFont *)font;

- (UIImage *)imageRepresentation;
- (UIImageView *)imageViewRepresentation;

- (UIView *)firstSubviewOfClass:(Class)klass;
- (NSArray *)subviewsOfClass:(Class)klass;
- (NSArray *)subviewsMatchingValidation:(BOOL(^)(UIView *view))validation;

+ (void)jm_animateFast:(void (^)(void))animations completion:(void (^)(void))completion animated:(BOOL)animated;
+ (void)jm_animateSlow:(void (^)(void))animations completion:(void (^)(void))completion animated:(BOOL)animated;

@end
