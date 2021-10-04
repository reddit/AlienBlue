#import "JMOutlineCell.h"
#import "ImgurUploadRecord.h"

@interface ImgurUploadNode : JMOutlineNode
@property (copy) JMAction onGearIconTapAction;
@property (strong, readonly) ImgurUploadRecord *uploadRecord;

- (id)initWithUploadRecord:(ImgurUploadRecord *)uploadRecord;
@end

@interface ImgurUploadCell : JMOutlineCell

@end
