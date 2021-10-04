//
//  LoginPasswordController_iPad.h
//  AlienBlue
//
//  Created by J M on 4/03/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "ABOutlineViewController.h"

@interface LoginPasswordController_iPad : ABOutlineViewController
- (id)initWithUsername:(NSString *)username password:(NSString *)password;
- (void)setCallbackTarget:(id)callbackTarget forAccountIndex:(NSInteger)accountIndex;
@end
