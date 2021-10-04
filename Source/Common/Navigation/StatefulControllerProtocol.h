//
//  StatefulControllerProtocol.h
//  AlienBlue
//
//  Created by J M on 7/02/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StatefulControllerProtocol <NSObject>
- (NSDictionary *)state;
- (id)initWithState:(NSDictionary *)state;
@end
