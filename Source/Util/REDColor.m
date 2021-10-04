//  REDColor.m
//  RedditApp

#import "RedditApp/Util/REDColor.h"

#import "JMUICore/Extensions/UIKit/UIColor+JMAdditions.h"

@implementation REDColor

#pragma mark - Primary colpors

+ (UIColor *)blueColor {
  return [UIColor colorWithHex:0x24A0ED];
}

#pragma mark - Neutrals

+ (UIColor *)whiteColor {
  return [UIColor colorWithHex:0xFFFFFF];
}

+ (UIColor *)offWhiteColor {
  return [UIColor colorWithHex:0xFCFCFA];
}

+ (UIColor *)paleGreyColor {
  return [UIColor colorWithHex:0xEFEFED];
}

+ (UIColor *)neutralColor {
  return [UIColor colorWithHex:0xCCCCC8];
}

+ (UIColor *)greyColor {
  return [UIColor colorWithHex:0xA5A4A4];
}

+ (UIColor *)darkGreyColor {
  return [UIColor colorWithHex:0x545452];
}

+ (UIColor *)offBlackColor {
  return [UIColor colorWithHex:0x353535];
}

+ (UIColor *)semiBlackColor {
  return [UIColor colorWithHex:0x222222];
}

@end
