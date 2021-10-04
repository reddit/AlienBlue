#import "ABCustomIdentifierManager.h"
#import "ABRemotelyManagedFeatures.h"

#import <AdSupport/AdSupport.h>

@interface ABCustomIdentifierManager()
@property (readonly) BOOL allowsAccessToDeviceIdentifier;
@end

@implementation ABCustomIdentifierManager

+ (ABCustomIdentifierManager *)sharedManager;
{
  JM_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

- (NSUUID *)advertisingIdentifier;
{
  if (!self.allowsAccessToDeviceIdentifier)
  {
    return nil;
  }
  
  if (![self isAdvertisingTrackingEnabled])
  {
    return nil;
  }
  
  return [[ASIdentifierManager sharedManager] advertisingIdentifier];
}

- (BOOL)isAdvertisingTrackingEnabled;
{
  if (!self.allowsAccessToDeviceIdentifier)
  {
    return NO;
  }
  
  return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}

- (BOOL)advertisingTrackingEnabled;
{
  if (!self.allowsAccessToDeviceIdentifier)
  {
    return NO;
  }

  return [ASIdentifierManager sharedManager].advertisingTrackingEnabled;
}

- (BOOL)allowsAccessToDeviceIdentifier;
{
  return [ABRemotelyManagedFeatures isAllowedToUseDeviceAdvertisingIdentifier];
}

@end
