//
//  NSURL+FHURLShim.h
//  FontHelper
//
//

#import <Foundation/Foundation.h>

@interface NSURL (FHURLShim)

#if (TARGET_OS_IPHONE && (__IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0)) || (!TARGET_OS_IPHONE && (MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_9))
#define DEFINE_URL_GETFSREPR_SHIM 1
- (BOOL) getFileSystemRepresentation:(char *)buffer maxLength:(NSUInteger)maxBufferLength;
#endif

@end
