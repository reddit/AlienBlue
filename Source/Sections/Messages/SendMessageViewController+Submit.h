//
//  SendMessageViewController+Submit.h
//  AlienBlue
//
//  Created by J M on 27/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SendMessageViewController.h"
#import "CaptchaEntryViewController.h"

@interface SendMessageViewController (Submit) <CaptchaEntryDelegate>

- (void)submit;

@end
