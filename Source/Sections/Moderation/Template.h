#import <Foundation/Foundation.h>

typedef enum TemplateSendPreference {
  TemplateSendPreferencePersonalMessage = 0,
  TemplateSendPreferenceComment
} TemplateSendPreference;

@interface Template : NSObject <NSCoding>

@property (strong) NSString *body;
@property (strong) NSString *title;
@property TemplateSendPreference sendPreference;

@property BOOL removed;
@property BOOL stockTemplate;

+ (Template *)templateWithTitle:(NSString *)title body:(NSString *)body;

@end
