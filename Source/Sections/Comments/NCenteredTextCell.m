//
//  NCenteredTextCell.m
//  AlienBlue
//
//  Created by J M on 26/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "NCenteredTextCell.h"
#import "Resources.h"
#import "Post.h"

@implementation CenteredTextNode

+ (CenteredTextNode *)nodeWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle;
{
    CenteredTextNode *node = [[CenteredTextNode alloc] init];
    node.title = title;
    node.selectedTitle = selectedTitle;
    return node;
}

+ (CenteredTextNode *)nodeWithTitle:(NSString *)title;
{
    return [CenteredTextNode nodeWithTitle:title selectedTitle:title];
}

+ (Class)cellClass;
{
    return NSClassFromString(@"NCenteredTextCell");
}

- (Post *)post;
{
    return nil;
}

@end

@implementation NCenteredTextCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    if (node.hidden) return  0.;
    CenteredTextNode *textNode = JMCastOrNil(node, CenteredTextNode);
    if (textNode.customHeight > 0)
      return textNode.customHeight;
  
    return 34.;
}

- (void)createSubviews;
{
  [super createSubviews];
  [self setCellBackgroundColor:[UIColor colorForBackground]];
}

- (void)decorateCellBackground;
{
    CenteredTextNode *textNode = (CenteredTextNode *)self.node;
    if ([textNode.title isEmpty])
    {
        // blank row, just draw normal bg
        [[UIColor colorForBackground] set];
    }
    else
    {
        [[UIColor colorForBackgroundAlt] set];        
    }
  
    if (textNode.customBackgroundColor)
    {
      [textNode.customBackgroundColor set];
      if (self.highlighted)
      {
        [[textNode.customBackgroundColor colorWithAlphaComponent:0.7] set];
      }
    }

//    [[UIColor blackColor] set];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
  

//    CGRect bounds = self.bounds;
//    [[UIColor colorWithWhite:0. alpha:0.06] set];
//    [[UIBezierPath bezierPathWithRect:bounds] fill];
  
//    CGFloat shadowTransparency = [Resources isNight] ? 0.2 : 0.08;
//    // top shadow
//    [UIView drawGradientInRect:CGRectCropToTop(bounds, 3.) minHeight:0. startColor:[UIColor colorWithWhite:0. alpha:shadowTransparency] endColor:[UIColor clearColor]];
//    
//    // bottom shadow
//    [UIView drawGradientInRect:CGRectCropToBottom(bounds, 3.) minHeight:0. startColor:[UIColor clearColor] endColor:[UIColor colorWithWhite:0. alpha:shadowTransparency]];
  
//    if (![Resources isNight])
//    {
//      // inner shadow stroke
//      [[UIColor colorWithWhite:0. alpha:0.1] set];
//      [[UIBezierPath bezierPathWithRect:CGRectCropToTop(bounds, 1.)] fill];
//      
//      // drop shadow stroke
//      [[UIColor colorForInsetDropShadow] set];
//      [[UIBezierPath bezierPathWithRect:CGRectCropToBottom(bounds, 1.)] fill];
//    }

  
//    [[UIImage skinImageNamed:@"section/create-post/create-dark-cell-gradient-normal"] drawInRect:self.bounds];
}

- (void)decorateCell;
{
    CenteredTextNode *textNode = (CenteredTextNode *)self.node;
    UIColor *normalColor = (self.node.onSelect != nil) ? [UIColor colorForHighlightedOptions] : [UIColor colorForText];
    UIColor *textColor = (self.highlighted) ? [UIColor lightGrayColor] : normalColor;
    if (textNode.customTitleColor)
    {
      textColor = textNode.customTitleColor;
    }
//    [textColor set];
  
    UIFont *textFont = [UIFont skinFontWithName:kBundleFontPostSubtitleBold];
    if (textNode.customTitleFont)
    {
      textFont = textNode.customTitleFont;
    }
//    CGRect textRect = CGRectInsetTop(self.bounds, 10.);
  
    NSString *title = (textNode.selected) ? textNode.selectedTitle : textNode.title;
    [title jm_drawVerticallyCenteredInRect:self.bounds withFont:textFont color:textColor horizontalAlignment:NSTextAlignmentCenter];
//    [title drawInRect:textRect withFont:textFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
}

@end
