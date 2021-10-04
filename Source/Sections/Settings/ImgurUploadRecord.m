#import "ImgurUploadRecord.h"

#define kImgurUploadRecordDefaultKeySmallThumbnailUrl @"small_thumbnail"
#define kImgurUploadRecordDefaultKeyOriginalImageUrl @"original_image"
#define kImgurUploadRecordDefaultKeyDeleteHash @"delete_hash"

@interface ImgurUploadRecord()
@property (copy) NSString *smallThumbnailUrl;
@property (copy) NSString *originalImageUrl;
@property (copy) NSString *deleteHash;
@end

@implementation ImgurUploadRecord

- (id)initWithImgurResponseDictionary:(NSDictionary *)dictionary;
{
  JM_SUPER_INIT(init);
  self.smallThumbnailUrl = [dictionary valueForKey:kImgurUploadRecordDefaultKeySmallThumbnailUrl];
  self.originalImageUrl = [dictionary valueForKey:kImgurUploadRecordDefaultKeyOriginalImageUrl];
  self.deleteHash = [dictionary valueForKey:kImgurUploadRecordDefaultKeyDeleteHash];
  return self;
}

+ (NSString *)originalImageUrlFromImgurResponseDictionary:(NSDictionary *)dictionary;
{
  if (!dictionary || !JMIsClass(dictionary, [NSDictionary class]))
    return nil;

  return dictionary[kImgurUploadRecordDefaultKeyOriginalImageUrl];
}

+ (void)storeUploadRecordWithImgurResponseDictionary:(NSDictionary *)dictionary;
{
  if (!dictionary || !JMIsClass(dictionary, [NSDictionary class]))
    return;

  NSMutableArray *imgurList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyImgurUploadsList]];
  [imgurList addObject:[NSDictionary dictionaryWithDictionary:dictionary]];
  [UDefaults setObject:imgurList forKey:kABSettingKeyImgurUploadsList];
  [UDefaults synchronize];
}

+ (void)removeStoredUploadRecordForRecord:(ImgurUploadRecord *)record;
{
  NSMutableArray *imgurList = [NSMutableArray arrayWithArray:[UDefaults objectForKey:kABSettingKeyImgurUploadsList]];
  NSDictionary *matchingRecord = [imgurList match:^BOOL(NSDictionary *responseDictionary) {
    return [record.deleteHash jm_matches:responseDictionary[kImgurUploadRecordDefaultKeyDeleteHash]];
  }];
  if (matchingRecord)
  {
    [imgurList removeObject:matchingRecord];
  }
  [UDefaults setObject:imgurList forKey:kABSettingKeyImgurUploadsList];
  [UDefaults synchronize];
}

+ (NSArray *)imgurUploadRecords;
{
  NSArray *imgurResponses = [UDefaults objectForKey:kABSettingKeyImgurUploadsList];
  NSArray *uploadRecords = [imgurResponses map:^id(NSDictionary *uploadResponseDictionary) {
    return [[ImgurUploadRecord alloc] initWithImgurResponseDictionary:uploadResponseDictionary];
  }];
  return uploadRecords;
}

@end
