//
//  NoteEntryToolbar
//  AlienBlue
//
//  Created by JM on 29/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteEntryToolbar.h"
#import "ABBundleManager.h"
#import "Resources.h"

@implementation NoteEntryToolbar

@synthesize controlDelegate = controlDelegate_;

- (id)initWithFrame:(CGRect)frame 
{
  self = [super initWithFrame:frame];
  if (self) 
	{
		self.backgroundColor = [UIColor clearColor];
		NSMutableArray * iconArray = [NSMutableArray arrayWithCapacity:10];
		self.items = iconArray;
  }
  return self;
}

- (void)addBarItem:(UIBarButtonItem *)barButtonItem;
{
	NSMutableArray * iconArray = [NSMutableArray arrayWithArray:self.items];	
	[iconArray addObject:barButtonItem];
	self.items = iconArray;
}

- (void)addTextMessage:(NSString *)text;
{
	UILabel * label = [[UILabel alloc] init];
	label.backgroundColor = [UIColor clearColor];
	label.text = text;
	label.textColor = [UIColor colorForBarButtonItem];
	label.shadowOffset = CGSizeMake(1., 1.);
	label.shadowColor = [UIColor colorForInsetDropShadow];
	label.font = [UIFont systemFontOfSize:12.];
	label.frame = CGRectMake(0, 0, 200., 30.);

	UIBarButtonItem * textItem = [[UIBarButtonItem alloc] initWithCustomView:label];
	[self addBarItem:textItem];
}

- (void)addPhotoOptions;
{
	UIBarButtonItem * flexibleWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem * addPhotoItem = [[UIBarButtonItem alloc] initWithImage:[[ABBundleManager sharedManager] imageNamed:@"icons/add-photo-button.png"] style:UIBarButtonItemStylePlain target:self.controlDelegate action:@selector(showAddPhotoActionSheet:)];
	[self addBarItem:flexibleWidth];
	[self addBarItem:addPhotoItem];
}

- (void)drawShadowInRect:(CGRect)rect
{
	UIImage * shadowMask = [[ABBundleManager sharedManager] imageNamed:@"common/fade-to-black-gradient.png"];
	[shadowMask drawInRect:rect];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	if (!self.items || [self.items count] == 0)
	{
		return CGSizeMake(size.width, 0);
	}
	else 
	{
		return CGSizeMake(size.width, 40.);
	}
}

@end
