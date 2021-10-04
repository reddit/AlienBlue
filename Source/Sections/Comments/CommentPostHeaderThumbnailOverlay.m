#import "CommentPostHeaderThumbnailOverlay.h"

@interface CommentPostHeaderThumbnailOverlay()
@property (strong) UIImage *blurredImage;
@end

@implementation CommentPostHeaderThumbnailOverlay

- (void)drawArrowInsideImageRect:(CGRect)imageRect;
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);

  UIImage *disclosureArrow = [UIImage skinIcon:@"thin-right-arrow" withColor:[UIColor whiteColor]];
  CGContextSetShadowWithColor(context, CGSizeZero, 2., [UIColor colorWithWhite:0. alpha:0.6].CGColor);
  CGPoint arrowOrigin = CGRectCenterWithSize(imageRect, disclosureArrow.size).origin;
  arrowOrigin.x -= 2.;
  [disclosureArrow drawAtPoint:arrowOrigin];
  CGContextRestoreGState(context);
}

- (void)drawWithRetrievedThumbnailImage:(UIImage *)thumbnailImage;
{
  CGRect verticalLineRect = CGRectCropToLeft(self.bounds, 2.);
  [UIView jm_drawVerticalDottedLineInRect:verticalLineRect lineWidth:0.5 lineColor:[UIColor colorForDottedDivider]];
  
  CGRect imageRect = CGRectInset(self.bounds, 12., 0.);
  imageRect.origin.x += 1.;
  
  BSELF(CommentPostHeaderThumbnailOverlay);
  if (thumbnailImage && (!self.blurredImage || self.blurredImage.height != imageRect.size.height))
  {
    DO_IN_BACKGROUND(^{
      UIImage *aspectScaledImage = JMAspectScaleToFillImageToSize(thumbnailImage, imageRect.size);
      blockSelf.blurredImage = [aspectScaledImage jm_applyBlurWithRadius:6 tintColor:[[UIColor colorForBackground] colorWithAlphaComponent:0.4] saturationDeltaFactor:1. maskImage:nil opaque:YES];
      DO_IN_MAIN(^{
        [blockSelf setNeedsDisplay];
      });
    });
  }
  
  if (self.blurredImage)
  {
    [self.blurredImage drawAtPoint:imageRect.origin];
    [self drawArrowInsideImageRect:imageRect];
  }
  else
  {
    UIImage *placeholderIcon = [UIImage placeholderThumbImageForUrl:self.url];
    CGRect placeholderRect = CGRectCenterWithSize(imageRect, placeholderIcon.size);
    [placeholderIcon drawAtPoint:placeholderRect.origin];
  }
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGFloat shadowOutlineWidth = 5.;
  UIBezierPath *innerShadowPath = [UIBezierPath bezierPathWithRect:CGRectInset(imageRect, -shadowOutlineWidth / 2., -shadowOutlineWidth / 2.)];
  innerShadowPath.lineWidth = shadowOutlineWidth;
  UIColor *shadowColor = [UIColor colorWithWhite:0. alpha:(self.highlighted ? 0.6 : 0.3)];
  CGContextSetShadowWithColor(context, CGSizeZero, 2., shadowColor.CGColor);
  CGContextClipToRect(context, imageRect);
  [innerShadowPath stroke];
  CGContextRestoreGState(context);
}

@end
