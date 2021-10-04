//
//  PhotoProcessing.m
//  AlienBlue
//
//  Created by Jason Morrissey on 16/06/10.
//  Copyright 2010 The Design Shed. All rights reserved.
//

#import "PhotoProcessing.h"


@implementation PhotoProcessing


+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
} 

+ (UIImage *) processPhotoFromInfo:(NSDictionary *)info
{
	NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
	
	UIImage * oImg = (UIImage *) [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	
	if(oImg != nil)
	{
	//	NSLog(@"processing image..");
		
		// Here's what's going on:
		// First we re-orient the original picture
		// Then we crop it to the user's preference
		// Finally we resize it before uploading.
		
		
		// re-orient image
		UIImage * img = [self scaleAndRotateImage:oImg ToMaxResolution:10000];
		
		// crop if necessary
		if ([prefs boolForKey:kABSettingKeyCropImageUploads])
			 img = [self imageFromImage:img inRect:[[info objectForKey:@"UIImagePickerControllerCropRect"] CGRectValue]];
		
		// resize if necessary
		if ([prefs boolForKey:kABSettingKeyResizeImageUploads])
			img = [self scaleAndRotateImage:img ToMaxResolution:1200];
		
//		UIImage * img = 
//		[self scaleAndRotateImage:
//		 [self imageFromImage:[self scaleAndRotateImage:oImg ToMaxResolution:10000] inRect:[[info objectForKey:@"UIImagePickerControllerCropRect"] CGRectValue]]
//				  ToMaxResolution:1200];
	
		UIImage * chosenPhoto = [[UIImage alloc] initWithData:UIImageJPEGRepresentation(img, 0.9)];	
		return chosenPhoto;
	}
	return nil;
	
}

+ (UIImage * )scaleAndRotateImage:(UIImage *)image ToMaxResolution:(int) kMaxResolution
{
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}


@end
