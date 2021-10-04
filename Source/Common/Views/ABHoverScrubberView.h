@interface ABHoverScrubberView : UIView

- (void)updateWithCurrentTouchCenterXOffset:(CGFloat)touchXOffset;
- (void)setStartingTouchCenterXOffset:(CGFloat)startingTouchXOffset;

- (void)updateIconForEndPoint:(UIImage *)iconForEndPoint;

@end
