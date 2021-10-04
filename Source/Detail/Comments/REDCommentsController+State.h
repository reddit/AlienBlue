//  REDCommentsController+State.h
//  RedditApp

#import "RedditApp/Detail/Comments/REDCommentsController.h"

@interface REDCommentsController (State)<StatefulControllerProtocol>
- (void)handleRestoringStateAutoscroll;
@end
