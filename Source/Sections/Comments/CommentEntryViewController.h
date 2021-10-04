#import <UIKit/UIKit.h>
#import "CommentEntryView.h"


@protocol CommentEntryDelegate <NSObject>
-(void) commentExited:(NSDictionary *)dictionary;
-(void) commentEntered:(NSDictionary *)dictionary;
@end

@interface CommentEntryViewController : UIViewController <CommentEntryViewDelegate>

-(void) showPopup;
-(void) showAddImagePopup;

+ (CommentEntryViewController *) viewControllerForDelegate:(id<CommentEntryDelegate>)delegate withComment:(NSMutableDictionary *)comment editing:(BOOL)editing message:(BOOL)message;
+ (UINavigationController *) viewControllerWithNavigationForDelegate:(id<CommentEntryDelegate>)delegate withComment:(NSMutableDictionary *)comment editing:(BOOL)editing message:(BOOL)message;

@end
