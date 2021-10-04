//
//  BaseStyledTextNode.h
//  AlienBlue
//
//  Created by J M on 19/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMOutlineNode.h"

@interface BaseStyledTextNode : JMOutlineNode

@property (readonly) NSString *elementId;

@property (readonly) NSArray *thumbLinks;

@property (readonly) NSAttributedString *styledText;
- (CGFloat)heightForBodyConstrainedToWidth:(CGFloat)width;
- (BOOL)containsNSFWContent;
- (BOOL)containsRestrictedContent;

- (void)prefetchThumbnailsToCacheOnComplete:(ABAction)onComplete;
@end
