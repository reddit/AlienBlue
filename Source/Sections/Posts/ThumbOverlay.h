//
//  ThumbOverlay.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMViewOverlay.h"

@class Post;

@interface ThumbOverlay : JMViewOverlay

@property BOOL showRightArrow;
@property BOOL allowLocalImageReplacement;
@property (strong, readonly) NSString *url;

- (void)updateWithUrl:(NSString *)url fallbackUrl:(NSString *)fallbackUrl showRetinaVersion:(BOOL)showRetinaVersion;
- (void)updateWithPost:(Post *)post;

@end
