#import <UIKit/UIKit.h>
#import "ABOutlineViewController.h"

@class PhotoUploadViewController;

@protocol PhotoUploadDelegate <NSObject>
- (void)didUploadToImgurImage:(UIImage *)image withUrl:(NSString *)url;
@end

@interface PhotoUploadViewController : ABOutlineViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic,ab_weak) id<PhotoUploadDelegate> delegate;
@property (nonatomic,strong) NSString *propertyKey;
- (id)initWithDelegate:(id<PhotoUploadDelegate>)delegate propertyKey:(NSString *)propertyKey;
@end
