//
//  StyledTextOverlay.h
//  AlienBlue
//
//  Created by J M on 16/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "JMViewOverlay.h"

typedef void (^LinkTappedAction)(NSString *link, CGPoint touchPoint);

@class NCommentCell;

@interface StyledTextOverlay : JMViewOverlay
@property (nonatomic, copy) LinkTappedAction linkTapped;
@property (nonatomic, copy) LinkTappedAction linkPressed;
- (void)updateWithAttributedString:(NSAttributedString *)attributedString;
@end
