//
//  PhotoProcessing.h
//  AlienBlue
//
//  Created by Jason Morrissey on 16/06/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhotoProcessing : NSObject {

}

+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;
+ (UIImage * )scaleAndRotateImage:(UIImage *)image ToMaxResolution:(int) kMaxResolution;
+ (UIImage *) processPhotoFromInfo:(NSDictionary *)info;

@end
