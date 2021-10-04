#import "ABActionMenuHost.h"

@interface CommentsActionMenuHost : ABActionMenuHost

+ (JMActionMenuNode *)generateContentUpvoteNode;
+ (JMActionMenuNode *)generateContentDownvoteNode;
+ (JMActionMenuNode *)generateContentSaveNode;
+ (JMActionMenuNode *)generateContentHideNode;
+ (JMActionMenuNode *)generateContentReportNode;


@end
