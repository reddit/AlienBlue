//
//  Comment+Preprocess.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "Comment.h"

@interface Comment (Preprocess)

- (void)preprocessLinksAndAttributedStyle;
- (void)preprocessLinksOnly;

@end
