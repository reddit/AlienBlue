//
//  ABButton.m
//  AlienBlue
//
//  Created by JM on 3/01/11.
//  Copyright 2011 The Design Shed. All rights reserved.
//

#import "ABButton.h"
#import "ABBundleManager.h"
#import "UIControl+BlocksKit.h"

@interface ABButton()
@property CGFloat imageInset;
@end

@implementation ABButton

@synthesize imageName = imageName_;

- (void) dealloc
{
	self.imageName = nil;
}

- (id)initWithIcon:(UIImage *)icon;
{
  self = [super initWithFrame:CGRectZero];
  if (self)
  {
		self.imageName = nil;
    self.imageNormal = icon;
    self.imageHighlighted = self.imageNormal;
    self.backgroundColor = [UIColor clearColor];
    self.size = self.imageNormal.size;
  }
  return self;
}

- (id) initWithImageName:(NSString *) imageName;
{
    if ((self = [super initWithFrame:CGRectZero])) 
	{
		self.imageName = imageName;
		UIImage * highlightedImage = [[ABBundleManager sharedManager] imageNamed:[imageName stringByReplacingOccurrencesOfString:@"normal" withString:@"highlighted"]];		
        UIImage * normalImage = [[ABBundleManager sharedManager] imageNamed:imageName];

        self.imageNormal = normalImage;
        self.imageHighlighted = highlightedImage;
        self.imageSelected = highlightedImage;
        
        self.backgroundColor = [UIColor clearColor];
        self.size = normalImage.size;
        self.imageInset = 0;
                
//		[self setBackgroundImage:[[SkinManager sharedSkinManager] imageNamed:imageName] forState:UIControlStateNormal];
//		[self setBackgroundImage:highlightedImage forState:UIControlStateSelected];
//		[self setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
//        [self sizeToFit];
    }
    return self;
}

+ (ABButton *)buttonWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;
{
    ABButton *button = [[ABButton alloc] initWithImageName:imageName];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (ABButton *)buttonWithImageName:(NSString *)imageName onTap:(ABAction)onTap;
{
    ABButton *button = [[ABButton alloc] initWithImageName:imageName];
    [button addEventHandler:^(id sender) {
        if (onTap)
        {
            onTap();
        }
    } forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setHighlighted:(BOOL)highlighted;
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected;
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect;
{
    UIImage *image = nil;
    if (self.selected)
        image = self.imageSelected;
    else if (self.highlighted)
        image = self.imageHighlighted;
    else
        image = self.imageNormal;

    CGFloat opacity = 1.;
    // if the highlight image and normal image are the same, fade the
    // button on highlight to give the user an idea that the button
    // is responding to touch.
    if (self.highlighted && self.imageHighlighted == self.imageNormal)
    {
        opacity = 0.5;
    }

    CGRect imageRect = CGRectInset(self.bounds, self.imageInset, self.imageInset);
    [image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:opacity];
}

- (void)expandTouchAreaWithPadding:(CGFloat)padding;
{
    self.frame = CGRectInset(self.frame, -1. * padding, -1. * padding);
    self.imageInset = padding;
    [self setNeedsDisplay];
}

//- (id)initWithFrame:(CGRect)frame {
//    if ((self = [super initWithFrame:frame])) 
//	{
//		self.backgroundColor = [UIColor orangeColor];
//    }
//    return self;
//}

@end
