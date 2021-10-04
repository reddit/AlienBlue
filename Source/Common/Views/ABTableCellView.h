#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "ABTableCellDrawerView.h"

@interface ABTableCellView : UIView {
	CGPoint currentTouchPoint;
	CGPoint gestureStartPoint;
	CGRect attributedContentRect;
	CTFrameRef _frame;
	CGContextRef _context;
//	CGPoint _baselineOrigin;
}

- (NSString *) checkForLinkInAttributedString:(NSAttributedString *) attributedString atTouchPoint:(CGPoint)touchPoint;
- (void) roundCornersForContext:(CGContextRef) c forRect:(CGRect) rect withRadius:(int) corner_radius;
- (void) drawAttributedString:(NSAttributedString *) attributedString inBounds:(CGRect) rect;


- (void)addDrawerView:(ABTableCellDrawerView *)drawerView;
- (void)removeDrawerView;
@end
