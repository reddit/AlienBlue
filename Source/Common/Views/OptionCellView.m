//
//  OptionCellView.m
//  AlienBlue
//
//  Created by DS on 22/06/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "OptionCellView.h"
#import "Resources.h"
#import "OptionTableViewController.h"
#import "ABBundleManager.h"
#import "UIImage+Skin.h"
#import "UIColor+Hex.h"
#import "UIView+Additions.h"
#import "ThumbManager.h"
#import "OptionCell.h"

@interface OptionCellView()
@property BOOL shouldIgnoreNextTouchEnded;
@property (nonatomic,strong) NSMutableDictionary *option;
@end

@implementation OptionCellView
@synthesize option = option_;

- (void)setNewOption:(NSMutableDictionary *) newOption
{
	self.option = newOption;
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
  [super touchesMoved:touches withEvent:event];
  self.shouldIgnoreNextTouchEnded = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (!self.option)
      return;

  if (![self.option isKindOfClass:[NSDictionary class]])
      return;
    
	OptionTableViewController * oc = (OptionTableViewController *) [self.option objectForKey:kOptionCellKeyParentController];
	if (!oc)
		return;

	if (![oc isKindOfClass:[OptionTableViewController class]])
		return;
	
	if ([oc isScrolling])
		return;
  
  if (self.shouldIgnoreNextTouchEnded)
  {
    self.shouldIgnoreNextTouchEnded = NO;
    return;
  }
	
	if ([oc isEditing])
		return;
	
  OptionCell *optionCell = (OptionCell *)[self jm_firstParentOfClass:[OptionCell class]];
  if (optionCell.isEditing)
    return;
  
  CGRect optionBounds = CGRectInset(self.bounds, 16., 0);
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	
	if([[self.option valueForKey:kOptionCellKeyHasSecondaryOption] boolValue] && touchPoint.x > (optionBounds.size.width - 68))
	{
		[oc didChooseSecondaryOptionAtIndexPath:[self.option objectForKey:kOptionCellKeyIndexPath]];
	}	
	else if([[self.option valueForKey:kOptionCellKeyHasSecondaryOption] boolValue] && touchPoint.x > (optionBounds.size.width - 20))
	{
		[oc didChooseSecondaryOptionAtIndexPath:[self.option objectForKey:kOptionCellKeyIndexPath]];
	}
	else if (touchPoint.x > 2)
  {
    // provide a tiny bit of untappable space to the left (that we can use to pass scroll events to)
		[oc didChoosePrimaryOptionAtIndexPath:[self.option objectForKey:kOptionCellKeyIndexPath]];
	}
}

- (void)drawTitleBackground;
{
  CGRect bgRect = CGRectOffset(CGRectInset(self.bounds,0, 2.), 0, -10.);
  [[UIColor colorForBackground] set];
  [[UIBezierPath bezierPathWithRect:bgRect] fill];
  
  [[[UIColor colorForHighlightedText] colorWithAlphaComponent:0.5] set];
  [[UIBezierPath bezierPathWithRect:CGRectCropToBottom(bgRect, 0.5)] fill];
}

- (void)drawRect:(CGRect)rect {
	
	if (!self.option)
		return;
  
  CGRect optionBounds = CGRectInset(self.bounds, 16., 0);
  optionBounds.origin.y = 4.;
  optionBounds.size.width += 16.;

  [UIView startEtchedDraw];
    
	float horizontalOffset = optionBounds.origin.x;
	
	if([self.option objectForKey:kOptionCellKeyIcon])
	{
		[[self.option objectForKey:kOptionCellKeyIcon] drawInRect:CGRectMake(15, optionBounds.origin.y + 4, 26, 26)];
		horizontalOffset += 36;
	}
	
  [[UIColor colorForText] set];
  UIFont *font = [[ABBundleManager sharedManager] fontForKey:kBundleFontOptionTitle];
  
	if ([[self.option valueForKey:kOptionCellKeyBold] boolValue])
  {
		font = [[ABBundleManager sharedManager] fontForKey:kBundleFontOptionTitleBold];
  }

	if([[self.option valueForKey:kOptionCellKeyDisabled] boolValue])
  {
    UIColor *disabledColor = JMIsNight() ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
    [disabledColor set];
  }
	
	if([[self.option valueForKey:kOptionCellKeyHighlight] boolValue])
  {
    [[UIColor colorForHighlightedOptions] set];
  }

	[[self.option valueForKey:kOptionCellKeyLabel] drawInRect:CGRectMake(horizontalOffset, optionBounds.origin.y + 10., optionBounds.size.width - 40 - horizontalOffset, 15) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];

	if ([self.option objectForKey:kOptionCellKeyTitle])
	{
    [self drawTitleBackground];
    [[UIColor colorForSectionTitle] set];
		UIFont * sectionTitleFont = [[ABBundleManager sharedManager] fontForKey:kBundleFontOptionSectionTitle];
    [[self.option valueForKey:kOptionCellKeyTitle] drawInRect:CGRectMake(16, optionBounds.origin.y + 10, self.bounds.size.width - 60, 15) withFont:sectionTitleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
  }
	
	if([self.option objectForKey:kOptionCellKeyOptionValue])
  {
		[[self.option valueForKey:kOptionCellKeyOptionValue] drawInRect:CGRectMake(optionBounds.size.width - 200 , optionBounds.origin.y + 10, 195, 15) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
  }
	
	if([[self.option valueForKey:kOptionCellKeyShowTick] boolValue])
  {
    UIImage *tickIcon = [UIImage imageNamed:@"tick-icon.png"];
		[tickIcon drawAtPoint:CGPointMake(optionBounds.size.width - 26, optionBounds.origin.y + 8)];
  }
	
	if([[self.option valueForKey:kOptionCellKeyShowHelpIcon] boolValue])
  {
    UIImage *helpIcon = [UIImage skinImageNamed:@"instructions/help-icon.png" withColor:[UIColor colorForHighlightedText]];
    [helpIcon drawAtPoint:CGPointMake(optionBounds.size.width - 22, optionBounds.origin.y + 8)];
  }
	
	if([[self.option valueForKey:kOptionCellKeyShowThemePalette] boolValue])
  {
    UIImage *paletteIcon = [UIImage skinImageNamed:@"icons/theme-palette.png"];
    [paletteIcon drawAtPoint:CGPointMake(optionBounds.size.width - 62, optionBounds.origin.y + 10)];
  }

  if([[self.option valueForKey:kOptionCellKeyShowStarEmpty] boolValue])
  {
    UIImage *starIcon = [UIImage imageNamed:@"star-icon-unselected.png"];
    [starIcon drawAtPoint:CGPointMake(optionBounds.size.width - 30, optionBounds.origin.y + 3)];
  }

	if([[self.option valueForKey:kOptionCellKeyShowStarFilled] boolValue])
  {
    [[UIImage skinIcon:@"self-icon" withColor:[UIColor colorForHighlightedOptions]] drawAtPoint:CGPointMake(optionBounds.size.width - 29, optionBounds.origin.y + 4)];
  }
	
	if([[self.option valueForKey:kOptionCellKeyShowProFeatureLabel] boolValue])
  {
    UIImage *proLabel = [UIImage skinImageNamed:@"instructions/pro-feature-label.png" withColor:[UIColor colorForHighlightedOptions]];
    if([[self.option valueForKey:kOptionCellKeyShowNextPageIndicator] boolValue])
    {
      [proLabel drawAtPoint:CGPointMake(optionBounds.size.width - 90, optionBounds.origin.y + 13)];
    }
    else
    {
      [proLabel drawAtPoint:CGPointMake(optionBounds.size.width - 70, optionBounds.origin.y + 13)];
    }
  }

	if([[self.option valueForKey:kOptionCellKeyShowNextPageIndicator] boolValue])
  {
    UIImage *disclosureImage = [UIImage skinImageNamed:@"icons/disclosure-arrow.png" withColor:[UIColor colorForHighlightedText]];
    [disclosureImage drawAtPoint:CGPointMake(optionBounds.size.width - 12, optionBounds.origin.y + 12) blendMode:kCGBlendModeNormal alpha:0.7];
  }
	
  if (![self.option objectForKey:kOptionCellKeyTitle])
  {
    [[UIColor colorForSoftDivider] set];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, optionBounds.size.height - 1., optionBounds.size.width, 1.)] fill];
  }
	
  [UIView endEtchedDraw];
}

@end
