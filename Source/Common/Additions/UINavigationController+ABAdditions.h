//
//  UINavigationController+ABAdditions.h
//  AlienBlue
//
//  Created by JM on 2/12/12.
//
//

#import <UIKit/UIKit.h>

@interface UINavigationController (ABAdditions)

+ (BOOL)ab_shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
+ (BOOL)ab_shouldAutorotate;
+ (NSUInteger)ab_supportedInterfaceOrientations;

@end
