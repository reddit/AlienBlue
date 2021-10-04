//
//  JMTextFieldEntryCell.h
//  AlienBlue
//
//  Created by J M on 11/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMOutlineCell.h"

typedef void(^JMTextFieldEntryNodeCompleteAction)(NSString *text);

@interface JMTextFieldEntryNode : JMOutlineNode
+ (JMTextFieldEntryNode *)textEntryNodeOnComplete:(JMTextFieldEntryNodeCompleteAction)onComplete;
@property (strong) NSString *placeholder;
@property (strong) NSString *defaultText;
@property (strong) UIColor *textColor;
@property (strong) UIColor *backgroundColor;

@property UITextAutocapitalizationType capitalizationType;
@property UITextAutocorrectionType autoCorrectionType;

@property (copy) ABAction onCancel;
@property (copy) JMTextFieldEntryNodeCompleteAction onEndEditing;
@end

@interface JMTextFieldEntryCell : JMOutlineCell

@end
