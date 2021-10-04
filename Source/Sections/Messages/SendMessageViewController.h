//
//  SendMessageViewController.h
//  AlienBlue
//
//  Created by J M on 25/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "ABOutlineViewController.h"
#import "JMTextView.h"

@interface SendMessageViewController : ABOutlineViewController <UITextViewDelegate>

@property (readonly,strong) JMTextView *messageTextView;
@property (readonly,strong) NSString *username;
@property (readonly,strong) NSString *subject;

- (id)initWithUsername:(NSString *)username;

@end
