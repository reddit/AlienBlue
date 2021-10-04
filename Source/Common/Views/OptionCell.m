//
//  OptionCell.m
//  AlienBlue
//
//  Created by DS on 20/06/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "OptionCell.h"
#import "Resources.h"
#import "OptionCellView_iPad.h"

@interface OptionCell()
@property (strong) OptionCellView *optionCellView;
@end

@implementation OptionCell

@synthesize optionCellView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
  {
		CGRect cellViewFrame = self.contentView.bounds;
    Class cellViewClass = [Resources isIPAD] ? NSClassFromString(@"OptionCellView_iPad") : NSClassFromString(@"OptionCellView");
		self.optionCellView = [[cellViewClass alloc] initWithFrame:cellViewFrame];
		self.optionCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.optionCellView setContentMode:UIViewContentModeRedraw];
		[self.contentView addSubview:self.optionCellView];

    self.opaque = YES;

    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
		[self setClipsToBounds:YES];
	}
	return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
{
  [super setHighlighted:highlighted animated:animated];
  if(highlighted)
  {
    UIColor * highlightColor = [UIColor colorForRowHighlight];
    self.backgroundColor = highlightColor;
    self.optionCellView.backgroundColor = highlightColor;
  }
  else
  {
    [self refreshBackground];
  }
}

- (void)setOption:(NSMutableDictionary *) option
{
	[self.optionCellView setNewOption:option];
}

- (void)refreshBackground
{
    UIColor *bgColor = [UIColor colorForBackground];
    self.backgroundColor = bgColor;
    self.contentView.backgroundColor = bgColor;
    self.optionCellView.backgroundColor = bgColor;
}

- (BOOL)isTicked
{
	return [[[self.optionCellView option] valueForKey:kOptionCellKeyShowTick] boolValue];
}

@end
