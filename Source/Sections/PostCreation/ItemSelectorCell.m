#import "ItemSelectorCell.h"
#import "ItemSelectorNode.h"
#import "UIImage+Skin.h"
#import "UIColor+Hex.h"
#import "Resources.h"

@implementation ItemSelectorCell

- (void)dealloc;
{
  ItemSelectorNode *node = (ItemSelectorNode *)self.node;
  [UIImage jm_cancelRemoteImageLoadForURL:[node.thumbUrl URL]];
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
	float fw, fh;
	if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
	}
	CGContextSaveGState(context);
	CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM (context, ovalWidth, ovalHeight);
	fw = CGRectGetWidth (rect) / ovalWidth;
	fh = CGRectGetHeight (rect) / ovalHeight;
	CGContextMoveToPoint(context, fw, fh/2);
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

- (void)drawThumbnail;
{
  ItemSelectorNode *node = (ItemSelectorNode *)self.node;
  BSELF(ItemSelectorCell);

  UIImage *thumb = [UIImage jm_remoteImageWithURL:[node.thumbUrl URL] onRetrieveComplete:^(UIImage *image) {
    [blockSelf setNeedsDisplay];
  }];
  
	if (thumb)
	{
    CGRect thumbRect = CGRectCenterWithSize(self.containerView.bounds, thumb.size);
    thumbRect.origin.x = 14.;
    
//		CGContextRef context = UIGraphicsGetCurrentContext();
//		CGContextSaveGState(context);
//		addRoundedRectToPath(context, thumbFrame, 8, 8);
//		CGContextClip(context);

    [thumb drawAtPoint:thumbRect.origin];
    
//		CGContextRestoreGState(context);
    
//    UIImage *border = [UIImage skinImageNamed:@"backgrounds/thumbnail-border.png"];
//    CGRect borderFrame = CGRectInset(thumbFrame, -2., -2.);
//    [border drawInRect:borderFrame];
  }
}

- (void)decorateCell;
{
  ItemSelectorNode *node = JMCastOrNil(self.node, ItemSelectorNode);
  [[UIColor colorForText] set];
  
  [node.title drawInRect:CGRectMake(60, 16, 240, 30.) withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.]];
  
  if (node.thumbUrl)
  {
      [self drawThumbnail];
  }
  else if (node.icon)
  {
    CGRect iconRect = CGRectCenterWithSize(self.containerView.bounds, node.icon.size);
    iconRect.origin.x = 14.;
    [node.icon drawAtPoint:iconRect.origin];
  }
}

- (void)decorateCellBackground;
{
  UIColor *bgColor = self.highlighted ? [UIColor colorForBackgroundAlt] : [UIColor colorForBackground];
  [bgColor setFill];
  [[UIBezierPath bezierPathWithRect:self.containerView.bounds] fill];
}

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
  return 50.;
}

@end
