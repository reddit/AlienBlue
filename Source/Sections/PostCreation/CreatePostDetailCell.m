#import "CreatePostDetailCell.h"
#import "UIImage+Skin.h"
#import "PostDetailNode.h"
#import "UIColor+Hex.h"

@implementation CreatePostDetailCell

- (void)decorateCell;
{
    PostDetailNode *node = JMCastOrNil(self.node, PostDetailNode);
    CGFloat width = self.bounds.size.width;
  
    UIColor *bgColor = self.highlighted ? [UIColor colorForBackgroundAlt] : [UIColor colorForBackground];
    [bgColor set];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
  
    [UIView jm_drawVerticalDottedLineInRect:CGRectMake(60., 30., 2, self.bounds.size.height - 60.) lineWidth:1. lineColor:[UIColor colorForDottedDivider]];

    [[UIColor colorForText] set];
    [node.title drawInRect:CGRectMake(80, 22, 240, 30.) withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.]];

    UIColor *valueColor = [UIColor colorWithWhite:0.5 alpha:0.7];
    [valueColor set];

    NSString *value = (node.value && [node.value length] > 0) ? node.value : node.placeholder;
    [value drawInRect:CGRectMake(80, 44, width - 120., 26.) withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.]];
    
    UIImage *decoratedIcon = [UIImage jm_coloredImageFromImage:node.icon fillColor:valueColor];
    CGRect iconAreaRect = CGRectCropToLeft(self.bounds, 60.);
    [decoratedIcon jm_drawCenteredInRect:iconAreaRect];
  
    CGPoint disclosureCenter = CGPointMake(width - 28, 41);
    UIImage *disclosureIcon = (node.disclosureIcon.size.width > 35) ? node.disclosureIcon : [UIImage jm_coloredImageFromImage:node.disclosureIcon fillColor:[UIColor skinColorForDisabledIcon]];
    [disclosureIcon drawAtPoint:CGPointMake(disclosureCenter.x - disclosureIcon.size.width / 2., disclosureCenter.y - disclosureIcon.size.height / 2.)];

    [[UIColor colorForSoftDivider] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectCropToTop(self.bounds, 1.)] fill];
}

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
  return 88.;
}

@end
