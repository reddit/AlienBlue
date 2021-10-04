#import "Comment.h"

@interface Message : Comment

@property BOOL wasComment;
@property NSUInteger firstMessageIdent;
@property (copy) NSString *firstMessageName;
@property (copy) NSString *destinationUser;
@property (copy) NSString *subject;
@property (copy) NSString *contextUrl;
@property (copy) NSString *linkTitle;
@property BOOL isUnread;

@property (readonly) NSString *titleForPresentation;
@property (readonly) NSString *metadataForPresentation;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)markAsRead;
- (void)preprocessStyles;

@property BOOL i_isModMail;
@property (weak) Message *i_parentMessage;

@end
