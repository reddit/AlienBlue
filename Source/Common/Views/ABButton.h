//
//  ABButton.h
//  AlienBlue
//
//  Created by JM on 3/01/11.
//  Copyright 2011 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ABButton : UIControl
{
	NSString * __ab_weak imageName_;
}

@property (nonatomic,ab_weak) NSString * imageName;

@property (strong) UIImage *imageHighlighted;
@property (strong) UIImage *imageNormal;
@property (strong) UIImage *imageSelected;

- (id)initWithImageName:(NSString *) imageName;
- (id)initWithIcon:(UIImage *)icon;

+ (ABButton *) buttonWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;
+ (ABButton *) buttonWithImageName:(NSString *)imageName onTap:(ABAction)onTap;
- (void)expandTouchAreaWithPadding:(CGFloat)padding;
@end
