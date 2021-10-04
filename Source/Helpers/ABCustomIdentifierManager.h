@interface ABCustomIdentifierManager : NSObject

+ (ABCustomIdentifierManager *)sharedManager;

@property (readonly) NSUUID *advertisingIdentifier;
@property (readonly,getter=isAdvertisingTrackingEnabled) BOOL advertisingTrackingEnabled;

@end
