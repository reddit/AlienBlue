//
//  BlueImports.h
//  AlienBlue
//
//  Created by J M on 4/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#ifndef AlienBlue_BlueImports_h
#define AlienBlue_BlueImports_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>

#import "BlocksKit.h"
#import "BlocksKit+UIKit.h"
#import "AFNetworking.h"
#import "JMUICore.h"

#import "Foundation+Extensions.h"
#import "UIKit+Extensions.h"
#import "UIColor+Hex.h"
#import "UIColor+Skin.h"
#import "UIImage+Skin.h"
#import "UIImage+Assets.h"
#import "UIImage+ABDiskCache.h"
#import "UIFont+Skin.h"
#import "UIView+Additions.h"
#import "NSString+ABAdditions.h"
#import "NSAttributedString+ABAdditions.h"
#import "NSMutableString+ABAdditions.h"
#import "NSMutableAttributedString+ABAdditions.h"
#import "NSDictionary+UrlEncoding.h"
#import "JMSurfaceButton.h"
#import "NSDate+ABAdditions.h"
#import "NSArray+ABAdditions.h"
#import "NSMutableArray+ABAdditions.h"
#import "UIImageView+JMAFNetworking.h"
#import "UIBezierPath+Shapes.h"
#import "StatefulControllerProtocol.h"
#import "UIViewController+Additions.h"
#import "NSArray+BlocksKit.h"
#import "UIImage+ABAdditions.h"
#import "UIBarButtonItem+Skin.h"
#import "NSObject+Universal.h"

#import "App.h"
#import "ABSettings.h"
#import "ABGlobalNotificationKeys.h"
#import "PromptManager.h"
#import "ABAnalyticsManager.h"

#define ab_block copy
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
#define __ab_weak __weak
#define ab_weak weak
#else
#define __ab_weak __unsafe_unretained
#define ab_weak unsafe_unretained
#endif

#define JMRunBlock(BLOCK_NAME) if (BLOCK_NAME) BLOCK_NAME();
#define JMIsKindClassOrNil(OBJ, CLASS_NAME) (([OBJ isKindOfClass:[CLASS_NAME class]]) ? (CLASS_NAME *)OBJ : nil)

#define RETINA_ONLY if (!JMIsRetina()) return;
#define FAST_DEVICE_ONLY if ([UIDevice jm_isSlowDevice]) return;

///// authentication

#define REQUIRES_REDDIT_AUTHENTICATION \
if (![[RedditAPI shared] authenticated]) \
{ \
    [[RedditAPI shared] showAuthorisationRequiredDialog]; \
    return; \
} \

#define REQUIRES_PRO \
if (![MKStoreManager isProUpgraded]) \
{ \
    [MKStoreManager needProAlert]; \
    return; \
} \

typedef void(^ABAction)(void);

#define SET_IF_EMPTY(PARAM_NAME, PLACEHOLDER) \
if (!PARAM_NAME || [PARAM_NAME isKindOfClass:[NSNull class]] || ([PARAM_NAME isKindOfClass:[NSString class]] && [PARAM_NAME isEmpty])) \
PARAM_NAME = PLACEHOLDER;

#define SET_BLANK_IF_NIL(PARAM_NAME) SET_IF_EMPTY(PARAM_NAME, @"")

#undef JMIsNight
#define JMIsNight() [UDefaults boolForKey:kABSettingKeyNightMode]

#endif
