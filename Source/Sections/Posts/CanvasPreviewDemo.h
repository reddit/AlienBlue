//
//  CanvasPreviewDemo.h
//  AlienBlue
//
//  Created by JM on 30/01/11.
//  Copyright 2011 The Design Shed. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CanvasPreviewDemo : UIViewController 
{
	IBOutlet UIImageView * imageView;
	IBOutlet UIButton * upgradeButton;	
	IBOutlet UILabel * iOS4RecommendedLabel;	
}

@property (nonatomic,strong) IBOutlet UIImageView * imageView;
@property (nonatomic,strong) IBOutlet UIButton * upgradeButton;
@property (nonatomic,strong) IBOutlet UILabel * iOS4RecommendedLabel;

- (void) closePanel:(id) sender;
- (void) upgradePressed:(id) sender;
@end
