#import "ABButton.h"
#import "CommentEntryView.h"
#import "PhoneCommentEntryDrawer.h"

@interface PhoneCommentEntryView : CommentEntryView <PhoneCommentEntryDrawerDelegate>

@property (nonatomic,strong, readonly) PhoneCommentEntryDrawer *drawer;

@end
