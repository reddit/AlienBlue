@interface ImgurUploadRecord : NSObject

@property (copy, readonly) NSString *smallThumbnailUrl;
@property (copy, readonly) NSString *originalImageUrl;
@property (copy, readonly) NSString *deleteHash;

+ (NSString *)originalImageUrlFromImgurResponseDictionary:(NSDictionary *)dictionary;

+ (void)storeUploadRecordWithImgurResponseDictionary:(NSDictionary *)dictionary;
+ (void)removeStoredUploadRecordForRecord:(ImgurUploadRecord *)record;

+ (NSArray *)imgurUploadRecords;

@end
